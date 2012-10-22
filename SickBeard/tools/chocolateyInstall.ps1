$package = 'Sickbeard'

try {

  function Get-CurrentDirectory
  {
    $thisName = $MyInvocation.MyCommand.Name
    [IO.Path]::GetDirectoryName((Get-Content function:$thisName).File)
  }

  . (Join-Path (Get-CurrentDirectory) 'Get-IniContent.ps1')
  . (Join-Path (Get-CurrentDirectory) 'Out-IniFile.ps1')
  . (Join-Path (Get-CurrentDirectory) 'WaitForSuccess.ps1')

  #simulate the unix command for finding things in path
  #http://stackoverflow.com/questions/63805/equivalent-of-nix-which-command-in-powershell
  function Which([string]$cmd)
  {
    Get-Command -ErrorAction "SilentlyContinue" $cmd |
      Select -ExpandProperty Definition
  }

  $sickBeardRunning = {
    $service = Get-Service 'SickBeard' -ErrorAction SilentlyContinue
    return ($service -and ($service.Status -eq 'Running'))
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

  # as we're running a service as SYSTEM, Machine needs python in PATH
  # TODO: Bug in Install-ChocolateyPath won't add to MACHINE if already in USER
  $setMachinePathScript = @"
  `$vars = [Environment]::GetEnvironmentVariable('PATH', 'Machine') -split ';';
  if (!(`$vars -contains '$pythonRoot')) { `$vars += '$pythonRoot' };
  [Environment]::SetEnvironmentVariable('PATH', (`$vars -join ';'), 'Machine');
  [Environment]::SetEnvironmentVariable('PYTHONHOME', '$pythonRoot', 'Machine');
"@

  Start-ChocolateyProcessAsAdmin $setMachinePathScript

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
  $sickBeardEmpty = $true
  if (Test-Path $sickBeardPath)
  {
    $files = Get-ChildItem $sickBeardPath -Recurse -ErrorAction SilentlyContinue
    $sickBeardEmpty = ($files.Count -eq 0)
  }
  if (!$sickBeardEmpty)
  {
    Write-ChocolateySuccess 'SickBeard already installed!'
    return
  }
  else
  {
    Write-Host 'Cloning SickBeard source from GitHub'
    &git clone https://github.com/midgetspy/Sick-Beard
  }

  # Read SABNzbd+ config file to find scripts directory
  $sabDataPath = Join-Path $Env:LOCALAPPDATA 'sabnzbd'
  $sabIniPath = Join-Path $sabDataPath 'sabnzbd.ini'
  if (Test-Path $sabIniPath)
  {
    Write-Host "Reading SABnzbd+ config file at $sabIniPath"
    $sabConfig = Get-IniContent -Path $sabIniPath

    # 3 options - missing script_dir, script_dir set to "", or configured script_dir
    if (!$sabConfig.misc.script_dir -or `
      ($sabConfig.misc.script_dir -eq "`"`""))
    {
      $scriptDir = (Join-Path $sabDataPath 'scripts')
      Write-Host "Configured SABnzbd+ script_dir to $scriptDir"
      $sabConfig.misc.script_dir = $scriptDir
      $sabConfig | Out-IniFile -FilePath $sabIniPath -Force -Encoding UTF8
    }

    if (!(Test-Path $sabConfig.misc.script_dir))
    {
      New-Item -Path $sabConfig.misc.script_dir -Type Directory | Out-Null
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
    $sabConfig | Out-IniFile -FilePath $sabIniPath -Force -Encoding UTF8
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
    .\instsrv SickBeard $srvany | Out-Null

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
    $configPath = (Join-Path $sickBeardPath 'config.ini')

    # to start hacking config.ini the service needs to be up, config.ini needs
    # to exist, and SickBeard must respond to requests (config.ini is complete)
    $waitOnConfig = {
      if (!(&$sickBeardRunning)) { return $false }
      if (!(Test-Path $configPath)) { return $false }

      # fails with a 200 (unknown API key) so we know it's accepting requests!
      $pingUrl = 'http://localhost:8081/api/?cmd=sb.ping'
      try
      {
        (New-Object Net.WebClient).DownloadString($pingUrl)
        return $true
      }
      catch {}

      return $false
    }

    if (WaitForSuccess $waitOnConfig 20 'SickBeard to start and create config')
    {
      Write-Host 'SickBeard started and configuration files created'
      $sickBeardConfig = Get-IniContent -Path $configPath

      $sickBeardApiKey = $sickBeardConfig.General.api_key

      Write-Host 'Configuring Windows Firewall for the SickBeard port'
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
      $sickBeardConfig.General.keep_processed_dir = 0

      $sickBeardConfig.General.naming_pattern = 'Season %S\%SN - %Sx%0E - %EN'
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

      $sickBeardConfig |
        Out-IniFile -File $configPath -Force -Encoding UTF8 |
        Out-Null

      Restart-Service SickBeard
    }

    $autoConfig = Join-Path $sabConfig.misc.script_dir 'autoProcessTV.cfg'
    if (!(Test-Path $autoConfig))
    {
      # order shouldn't matter, but don't trust Python ;0
      $sbAuto = New-Object Collections.Specialized.OrderedDictionary
      $sbAuto.host = $sickBeardConfig.General.web_host -replace '0\.0\.0\.0',
        'localhost';
      $sbAuto.port = $sickBeardConfig.General.web_port;
      $sbAuto.username = $sickBeardConfig.General.web_username;
      $sbAuto.password = $sickBeardConfig.General.web_password;
      $sbAuto.web_root = $sickBeardConfig.General.web_root;
      $sbAuto.ssl = 0;

      @{ 'SickBeard' = $sbAuto } |
        Out-IniFile -FilePath $autoConfig -Encoding ASCII -Force

      Write-Host @"
SickBeard SABNzbd+ post-processing scripts configured
  If SickBeard is reconfigured with a username or password or another
  host then those same changes must be made to $configPath
"@
    }

    Write-Host 'Restarting SABnzbd+ to accept configuration changes'
    $url = ("http://localhost:$($sabConfig.misc.port)/api?mode=restart" +
      "&apikey=$($sabConfig.misc.api_key)")
    (New-Object Net.WebClient).DownloadString($url)

    #wait up to 5 seconds for service to fire up
    if (WaitForSuccess $sickBeardRunning 5 'SickBeard to start')
    {
      #launch local default browser for additional config
      $configUrl = "http://localhost:$($sickBeardConfig.General.web_port)"
      [Diagnostics.Process]::Start($configUrl) | Out-Null
    }

    Write-Host "For use in other apps, SickBeard API key: $sickBeardApiKey"

    Pop-Location
  }

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
