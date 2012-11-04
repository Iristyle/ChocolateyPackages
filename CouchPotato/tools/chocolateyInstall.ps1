$package = 'CouchPotato'

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

  $couchPotatoRunning = {
    $service = Get-Service 'CouchPotato' -ErrorAction SilentlyContinue
    return ($service -and ($service.Status -eq 'Running'))
  }
  $couchPotatoServing = {
    $pingUrl = 'http://localhost:5050/docs/'
    try
    {
      (New-Object Net.WebClient).DownloadString($pingUrl)
      return $true
    }
    catch {}

    return $false
  }

  # Use PYTHONHOME if it exists, or fallback to 'Where' to search PATH
  if ($Env:PYTHONHOME) { $localPython = Join-Path $Env:PYTHONHOME 'python.exe' }

  if (!$Env:PYTHONHOME -or !(Test-Path $localPython))
    { $localPython = Which python.exe }

  if (!(Test-Path $localPython))
  {
    Write-ChocolateyFailure 'CouchPotato requires a Python runtime to install'
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
  $couchPotatoPath = (Join-Path $sitePackages 'CouchPotatoServer')
  $couchPotatoEmpty = $true
  if (Test-Path $couchPotatoPath)
  {
    $files = Get-ChildItem $couchPotatoPath -Recurse -ErrorAction SilentlyContinue
    $couchPotatoEmpty = ($files.Count -eq 0)
  }
  if (!$couchPotatoEmpty)
  {
    Write-ChocolateySuccess 'CouchPotato already installed!'
    return
  }
  else
  {
    Write-Host 'Cloning CouchPotato source from GitHub'
    &git clone https://github.com/RuudBurger/CouchPotatoServer.git
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

    # To use alternate CouchPotato script, requires modified SickBeard bits
    # copy and configure autoprocessing scripts in SABNzbd+ scripts directory
    Write-Host "Copying CouchPotato post-processing scripts to SABnzbd+"
    Get-ChildItem (Get-CurrentDirectory) -Filter '*.py' |
      # overwrite SickBeard scripts if they exist
      Copy-Item -Destination $sabConfig.misc.script_dir -Force

    if (!$sabconfig.categories.movies)
    {
      Write-Host "Configuring movies category inside SABnzbd+"
      $movies = New-Object Collections.Specialized.OrderedDictionary
      $movies.priority = 0;
      $movies.pp = 3; # Download + Unpack +Repair +Delete
      $movies.name = 'movies';
      $movies.script = 'sabToCouchPotato.py';
      $movies.newzbin = '';
      $movies.dir = 'movies';
      $sabconfig.categories.movies = $movies
    }

    if (([string]::IsNullOrEmpty($sabconfig.categories.movies.script)) -or `
      ($sabconfig.categories.movies.script -ieq 'None') -or
      ($sabconfig.categories.movies.script -ieq "`"`""))
    {
      $sabconfig.categories.movies.script = 'sabToCouchPotato.py'
    }

    # allows failed post processing of empty files (out of retention, etc)
    $sabConfig.misc.empty_postproc = 1

    Write-Host 'Configured movies category in SABnzbd+'
    $sabConfig | Out-IniFile -FilePath $sabIniPath -Force -Encoding UTF8
  }

  # regardless of sabnzbd+ install status, .PY should be executable
  if (($ENV:PATHEXT -split ';') -inotcontains '.PY')
  {
    Write-Host 'Adding .PY to PATHEXT'
    $ENV:PATHEXT += ';.PY'
    [Environment]::SetEnvironmentVariable('PATHEXT', $ENV:PATHEXT, 'Machine')
  }

  # find resource kit tools and configure CouchPotato as a service
  # http://htpcbuild.com/htpc-software/sickbeard/sickbeard-service/
  # http://stackoverflow.com/questions/32404/can-i-run-a-python-script-as-a-service-in-windows-how
  $resourceKit = ${Env:ProgramFiles(x86)}, $Env:ProgramFiles |
    % { Join-Path (Join-Path $_ 'Windows Resource Kits') 'Tools' } |
    ? { Test-Path $_ } |
    Select -First 1

  if ($resourceKit)
  {
    Write-Host "Found resource kit - registering CouchPotato as a service"
    Push-Location $resourceKit
    $srvAny = Join-Path $resourceKit 'srvany.exe'
    .\instsrv CouchPotato $srvany | Out-Null

    # Set-Service cmdlet doesn't have depend OR delayed start :(
    Write-Host "Configuring service delayed auto with Tcpip dependency"
    sc.exe config CouchPotato depend= Tcpip
    sc.exe config CouchPotato start= delayed-auto
    Pop-Location

    New-Item HKLM:\SYSTEM\CurrentControlSet\Services -Name CouchPotato `
      -ErrorAction SilentlyContinue | Out-Null
    New-Item HKLM:\SYSTEM\CurrentControlSet\Services\CouchPotato `
      -Name Parameters -ErrorAction SilentlyContinue | Out-Null
    $couchPotatoParams = Get-Item HKLM:\SYSTEM\CurrentControlSet\Services\CouchPotato\Parameters
    New-ItemProperty -Path $couchPotatoParams.PSPath -PropertyType String `
      -Name 'AppDirectory' -Value $pythonRoot -Force | Out-Null
    $pythonW = (Join-Path $pythonRoot 'pythonw.exe')
    New-ItemProperty -Path $couchPotatoParams.PSPath -PropertyType String `
      -Name 'Application' -Value $pythonW -Force | Out-Null
    $startCouchPotato = (Join-Path $couchPotatoPath 'CouchPotato.py')
    New-ItemProperty -Path $couchPotatoParams.PSPath -PropertyType String `
      -Name 'AppParameters' -Value $startCouchPotato  -Force | Out-Null

    Start-Service CouchPotato

    $sysProfile = Join-Path 'config' 'systemprofile'
    $roamingData = Join-Path $sysProfile 'AppData\Roaming'

    # config files are created on first start-up
    $configPath = (Join-Path ([Environment]::GetFolderPath('System')) $roamingData),
    # must handle SYSWOW64 on x64 (works inside both 32-bit and 64-bit host procs)
    (Join-Path ([Environment]::GetFolderPath('SystemX86')) $roamingData) |
      Select -Unique |
      ? { Test-Path $_ } |
      % { Join-Path $_ 'CouchPotato\settings.conf' } |
      Select -First 1
    Write-Host "Expecting configuration file at $configPath"

    # to start hacking settings.conf the service needs to be up, settings.conf needs
    # to exist, and CouchPotato must respond to requests (settings.conf is complete)
    $waitOnConfig = {
      if (!(&$couchPotatoRunning)) { return $false }
      if (!(Test-Path $configPath)) { return $false }
      return &$couchPotatoServing
    }

    if (WaitForSuccess $waitOnConfig 20 'CouchPotato to start and create config')
    {
      Write-Host 'CouchPotato started and configuration files created'
      # an alternative to modifying conf directly is to use the API
      # /api/KEY/settings
      $couchPotatoConfig = Get-IniContent -Path $configPath
      $couchPotatoApiKey = $couchPotatoConfig.core.api_key

      Write-Host 'Configuring Windows Firewall for the CouchPotato port'
      # configure windows firewall
      netsh advfirewall firewall delete rule name="CouchPotato"
      # program="$pythonW"
      $port = $couchPotatoConfig.core.port
      netsh advfirewall firewall add rule name="CouchPotato" dir=in protocol=tcp localport=$port action=allow

      $couchPotatoConfig.core.launch_browser = 'False'

      # make sure autoupdate is turned on with a correct path to Git
      $couchPotatoConfig.updater.notification = 'True'
      $couchPotatoConfig.updater.enabled = 'True'
      $couchPotatoConfig.updater.git_command = "`"$($git -replace '\\', '\\')`""
      $couchPotatoConfig.updater.automatic = 'True'

      $movieDownloads = Join-Path (Join-Path $sabDataPath 'Downloads') `
        $sabConfig.categories.movies.dir

      $couchPotatoConfig.manage.cleanup = 'True'
      # TODO: once we can sniff out the XBMC directory, we can auto-config this
      # $couchPotatoConfig.manage.enabled = 'False'
      # $couchPotatoConfig.manage.library = ''

      # Write-Host "Using SABNzbd+ movies download directory, but the to must be configured"
      $couchPotatoConfig.renamer.from = "`"$($movieDownloads -replace '\\', '\\')`""
      $couchPotatoConfig.renamer.enabled = 'True'
      $couchPotatoConfig.renamer.cleanup = 'True'
      $couchPotatoConfig.renamer.folder_name = '<namethe> [<year>]'
      $couchPotatoConfig.renamer.move_leftover = 1
      # because we're using alternate post-processing script, don't auto-run this
      # on a schedule
      $couchPotatoConfig.renamer.run_every = 0

      # configure for XBMC with default user / pass of xbmc / xbmc
      $couchPotatoConfig.xbmc.enabled = 1
      $couchPotatoConfig.xbmc.meta_enabled = 'True'
      $couchPotatoConfig.xbmc.meta_thumbnail = 'True'
      $couchPotatoConfig.xbmc.meta_fanart = 'True'
      $couchPotatoConfig.xbmc.meta_nfo = 'True'
      $couchPotatoConfig.xbmc.host = 'localhost:9090'
      $couchPotatoConfig.xbmc.username = 'xbmc'
      $couchPotatoConfig.xbmc.password = 'xbmc'

      # configure CouchPotato to use SABNzbd
      $couchPotatoConfig.sabnzbd.enabled = 1
      $couchPotatoConfig.sabnzbd.api_key = $sabConfig.misc.api_key
      $couchPotatoConfig.sabnzbd.category = 'movies'
      $couchPotatoConfig.sabnzbd.host = "localhost:$($sabConfig.misc.port)"

      $couchPotatoConfig |
        Out-IniFile -File $configPath -Force -Encoding ASCII |
        Out-Null

      $restartUrl = "http://localhost:$port/api/$couchPotatoApiKey/app.restart/"
      try
      {
        Write-Host "Restarting CouchPotato using API to accept config"
        (New-Object Net.WebClient).DownloadString($restartUrl)
      }
      catch
      {
        Write-Host "Error using API - restarting service manually"
        Restart-Service CouchPotato
      }
    }

    # Using alternative CouchPotato renamer script like SickBeard
    # https://couchpota.to/forum/showthread.php?tid=343
    # files at http://www.freefilehosting.net/autoprocessmediabuilds-win
    # The main benefits to this script are:
    # 1 less CPU usage (due to SABnzbd polling an regular disk scanning etc)
    # 2 less hard disk scanning
    # 3 ability to get hard disk to spin down when not downloading
    # 4 the renamer is fired (on demand)
    # 5 if you are using SABnzbd renaming this script will add to the manage list without using the renamer.

    $autoConfig = Join-Path $sabConfig.misc.script_dir 'autoProcessMovie.cfg'
    if (!(Test-Path $autoConfig))
    {
      # order shouldn't matter, but don't trust Python ;0
      $sbAuto = New-Object Collections.Specialized.OrderedDictionary
      $sbAuto.host = $couchPotatoConfig.core.host -replace '0\.0\.0\.0',
        'localhost';
      $sbAuto.port = $couchPotatoConfig.core.port;
      $sbAuto.username = $couchPotatoConfig.core.username;
      $sbAuto.password = $couchPotatoConfig.core.password;
      $sbAuto.ssl = 0;
      $sbAuto.web_root = $couchPotatoConfig.core.url_base;
      $sbAuto.apikey = $couchPotatoConfig.core.api_key
      $sbAuto.delay = 60 # must be minimum of 60 seconds
      $sbAuto.method = 'renamer' #or 'manage'

      @{ 'CouchPotato' = $sbAuto } |
        Out-IniFile -FilePath $autoConfig -Encoding ASCII -Force

      Write-Host @"
CouchPotato SABNzbd+ post-processing scripts configured
  If CouchPotato is reconfigured with a username or password or another
  host or different API key then those same changes must be made to $configPath
"@
    }

    $url = ("http://localhost:$($sabConfig.misc.port)/api?mode=restart" +
      "&apikey=$($sabConfig.misc.api_key)")
    Write-Host "Restarting SABnzbd+ to accept configuration changes at $url"
    (New-Object Net.WebClient).DownloadString($url)

    #wait up to 5 seconds for service to fire up
    if (WaitForSuccess $couchPotatoServing 5 'CouchPotato to start')
    {
      #launch local default browser for additional config
      $configUrl = "http://localhost:$($couchPotatoConfig.core.port)"
      [Diagnostics.Process]::Start($configUrl) | Out-Null
    }

    Write-Host "For use in other apps, CouchPotato API key: $couchPotatoApiKey"

    Pop-Location
  }

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
