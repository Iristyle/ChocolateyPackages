$package = 'Sickbeard'

try {

  function Get-CurrentDirectory
  {
    $thisName = $MyInvocation.MyCommand.Name
    [IO.Path]::GetDirectoryName((Get-Content function:$thisName).File)
  }

  # load INI parser
  . (Join-Path (Get-CurrentDirectory) 'Get-IniContent.ps1')
  . (Join-Path (Get-CurrentDirectory) 'Out-IniFile.ps1')

  #simulate the unix command for finding things in path
  #http://stackoverflow.com/questions/63805/equivalent-of-nix-which-command-in-powershell
  function Which([string]$cmd)
  {
    Get-Command -ErrorAction "SilentlyContinue" $cmd |
      Select -ExpandProperty Definition
  }

  function WaitService([string]$name, [int]$seconds)
  {
    Write-Host "Waiting up to $($seconds)s for $name to start..."
    $result = 0..($seconds * 2) |
      % {
        $service = Get-Service $name -ErrorAction SilentlyContinue
        if ($service -and ($service.Status -eq 'Running'))
          { return $true }
        elseif ($service)
          { Start-Sleep -Milliseconds 500 }
        return $false
      } |
      Select -Last 1

    return $result
  }

  # Use PYTHONHOME if it exists, or fallback to 'Where' to search PATH
  if ($Env:PYTHONHOME) { $localPython = Join-Path $Env:PYTHONHOME 'python.exe' }

  if (!$Env:PYTHONHOME -or !(Test-Path $localPython))
    { $localPython = Which python.exe }

  if (!(Test-Path $localPython))
  {
    Write-ChocolateyFailure 'SickBeard requires a Python runtime to install'
    return
  }

  $pythonRoot = Split-Path $localPython

  $sitePackages = (Join-Path (Join-Path $pythonRoot 'Lib') 'site-packages')
  if (!(Test-Path $sitePackages))
  {
    Write-ChocolateyFailure 'Could not find Python site-packages directory'
    return
  }

  # grab the latest sources if not present
  Push-Location $sitePackages
  $git = Which git
  $sickBeardPath = (Join-Path $sitePackages 'Sick-Beard')
  if (Test-Path $sickBeardPath)
  {
    Write-ChocolateySuccess 'SickBeard already installed!'
    return
  }
  else
  {
    Write-ChocolateySuccess 'Cloning SickBeard source from GitHub'
    &git clone https://github.com/midgetspy/Sick-Beard
  }

  # Read SABNzbd+ config file to find scripts directory
  $sabDataPath = Join-Path $Env:LOCALAPPDATA 'sabnzbd'
  $sabIniPath = Join-Path $sabDataPath 'sabnzbd.ini'
  if (Test-Path $sabIniPath)
  {
    Write-Host "Reading SABnzbd+ config file at $sabIniPath"
    $sabConfig = Get-IniContent $sabIniPath

    # 3 options - missing script_dir, script_dir set to "", or configured script_dir
    if (!$sabConfig.misc.script_dir -or `
      ($sabConfig.misc.script_dir -eq "`"`""))
    {
      $scriptDir = (Join-Path $sabDataPath 'scripts')
      Write-Host "Configured SABnzbd+ script_dir to $scriptDir"
      $sabConfig.misc.script_dir = $scriptDir
      $sabConfig | Out-IniFile -FilePath $sabIniPath -Force
    }

    if (!(Test-Path $sabConfig.misc.script_dir))
    {
      [Void]New-Item -Path $sabConfig.misc.script_dir -Type Directory
    }

    # copy and configure autoprocessing scripts in SABNzbd+ scripts directory
    Write-Host "Copying SickBeard post-processing scripts to SABnzbd+"
    $sourceScripts = (Join-Path $sickBeardPath 'autoProcessTV')
    Get-ChildItem $sourceScripts |
      ? { !(Test-Path (Join-Path $sabConfig.misc.script_dir $_.Name)) } |
      Copy-Item -Destination $sabConfig.misc.script_dir

    if (!$sabconfig.categories.tv)
    {
      Write-Host "Configuring tv category inside SABnzbd+"
      $tv = New-Object Collections.Specialized.OrderedDictionary
      $tv.priority = 0;
      $tv.pp = 3; # Download + Unpack +Repair +Delete
      $tv.name = 'tv';
      $tv.script = 'sabToSickBeard.py';
      $tv.newzbin = '';
      $tv.dir = 'tv';
      $sabconfig.categories.tv = $tv
    }

    if (([string]::IsNullOrEmpty($sabconfig.categories.tv.script)) -or `
      ($sabconfig.categories.tv.script -ieq 'None'))
    {
      $sabconfig.categories.tv.script = 'sabToSickBeard.py'
    }

    Write-Host 'Configured tv category in SABnzbd+'
    $sabConfig | Out-IniFile -FilePath $sabIniPath -Force
  }

  # regardless of sabnzbd+ install status, .PY should be executable
  if (($ENV:PATHEXT -split ';') -inotcontains '.PY')
  {
    Write-Host 'Adding .PY to PATHEXT'
    $ENV:PATHEXT += ';.PY'
    [Environment]::SetEnvironmentVariable('PATHEXT', $ENV:PATHEXT, 'Machine')
  }

  # find resource kit tools and configure sickbeard as a service
  # http://htpcbuild.com/htpc-software/sickbeard/sickbeard-service/
  # http://stackoverflow.com/questions/32404/can-i-run-a-python-script-as-a-service-in-windows-how
  $resourceKit = ${Env:ProgramFiles(x86)}, $Env:ProgramFiles |
    % { Join-Path (Join-Path $_ 'Windows Resource Kits') 'Tools' } |
    ? { Test-Path $_ } |
    Select -First 1

  if ($resourceKit)
  {
    Write-Host "Found resource kit - registering SickBeard as a service"
    Push-Location $resourceKit
    $srvAny = Join-Path $resourceKit 'srvany.exe'
    .\instsrv SickBeard $srvany

    # Set-Service cmdlet doesn't have depend OR delayed start :(
    Write-Host "Configuring service delayed auto with Tcpip dependency"
    sc.exe config SickBeard depend= Tcpip
    sc.exe config SickBeard start= delayed-auto

    New-Item HKLM:\SYSTEM\CurrentControlSet\Services -Name SickBeard `
      -ErrorAction SilentlyContinue | Out-Null
    New-Item HKLM:\SYSTEM\CurrentControlSet\Services\SickBeard `
      -Name Parameters -ErrorAction SilentlyContinue | Out-Null
    $sickParams = Get-Item HKLM:\SYSTEM\CurrentControlSet\Services\SickBeard\Parameters
    New-ItemProperty -Path $sickParams.PSPath -PropertyType String `
      -Name 'AppDirectory' -Value $pythonRoot -Force | Out-Null
    $pythonW = (Join-Path $pythonRoot 'pythonw.exe')
    New-ItemProperty -Path $sickParams.PSPath -PropertyType String `
      -Name 'Application' -Value $pythonW -Force | Out-Null
    $startSickBeard = (Join-Path $sickBeardPath 'sickbeard.py')
    New-ItemProperty -Path $sickParams.PSPath -PropertyType String `
      -Name 'AppParameters' -Value $startSickBeard  -Force | Out-Null

    Start-Service SickBeard

    # config files are created on first start-up
    if (WaitService 'SickBeard', 20)
    {
      $configPath = (Join-Path $sickBeardPath 'config.ini')
      $sickBeardConfig = Get-IniContent $configPath

      Write-Host "Configuring Windows Firewall for the SickBeard port"
      # configure windows firewall
      netsh advfirewall firewall delete rule name="SickBeard"
      # program="$pythonW"
      $port = $sickBeardConfig.General.web_port
      netsh advfirewall firewall add rule name="SickBeard" dir=in protocol=tcp localport=$port action=allow

      # http://forums.sabnzbd.org/viewtopic.php?t=3072&start=855
      $sickBeardConfig.General.git_path = $git
      $sickBeardConfig.General.launch_browser = 0
      $sickBeardConfig.General.use_api = 1
      $sickBeardConfig.General.process_automatically = 0
      $sickBeardConfig.General.move_associated_files = 1
      $sickBeardConfig.General.api_key = [Guid]::NewGuid().ToString('n')
      $sickBeardConfig.General.metadata_xbmc = '1|1|1|1|1|1'
      $sickBeardConfig.General.naming_pattern = '%SN - %Sx%0E - %EN'
      #range like x03-05
      $sickBeardConfig.General.naming_multi_ep = 8

      # configure for XBMC with default user / pass of xbmc / xbmc
      $sickBeardConfig.XBMC.use_xbmc = 1
      $sickBeardConfig.XBMC.xbmc_update_library = 1
      $sickBeardConfig.XBMC.xbmc_host = 'localhost:9090'
      $sickBeardConfig.XBMC.xbmc_username = 'xbmc'
      $sickBeardConfig.XBMC.xbmc_password = 'xbmc'

      # configure SickBeard to use SABNzbd
      $sickBeardConfig.General.nzb_method = 'sabnzbd'
      $sickBeardConfig.SABnzbd.sab_username = $sabConfig.misc.username
      $sickBeardConfig.SABnzbd.sab_password = $sabConfig.misc.password
      $sickBeardConfig.SABnzbd.sab_apikey = $sabConfig.misc.api_key
      $sickBeardConfig.SABnzbd.sab_category = 'tv'
      $sickBeardConfig.SABnzbd.sab_host = "http://localhost:$($sabConfig.misc.port)/"

      $sickBeardConfig | Out-IniFile -File $configPath -Force -Encoding ASCII

      Stop-Service SickBeard
      Start-Service SickBeard
    }

    $autoConfig = Join-Path $sabConfig.misc.script_dir 'autoProcessTV.cfg'
    if (!(Test-Path $autoConfig))
    {
      $processConfig = @{
        'SickBeard' = @{
          host = $sickBeardConfig.General.web_host;
          port = $sickBeardConfig.General.web_port;
          username = $sickBeardConfig.General.web_username;
          password = $sickBeardConfig.General.web_password;
          web_root = $sickBeardConfig.General.web_root;
          ssl = 0;
        }
      }
      $processConfig | Out-IniFile -FilePath $autoConfig
      Write-Host @"
SickBeard SABNzbd+ post-processing scripts configured
  If SickBeard is reconfigured with a username or password or another
  host then those same changes must be made to $sickBeardConfig
"@
    }

    Write-Host 'Restarting SABnzbd+ to accept configuration changes'
    $url = ("http://localhost:$($sabConfig.misc.port)/api?mode=restart" +
      "&apikey=$($sabConfig.misc.api_key)")
    (New-Object Net.WebClient).DownloadString($url)

    #wait up to 5 seconds for service to fire up
    if (WaitService 'SickBeard' 5)
    {
      #launch local default browser for additional config
      [Diagnostics.Process]::Start("http://localhost:$($sickBeardConfig.General.web_port)")
    }

    Pop-Location
  }

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
