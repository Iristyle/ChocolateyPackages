$package = 'CouchPotato'

try
{
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

  Write-Host 'Deleting CouchPotato Windows Firewall config'
  netsh advfirewall firewall delete rule name="CouchPotato"

  # check registry for path to CouchPotato
  $servicePath = 'HKLM:\SYSTEM\CurrentControlSet\Services\CouchPotato\Parameters'
  $installDir = Get-ItemProperty $servicePath -ErrorAction SilentlyContinue |
    Select -ExpandProperty AppParameters

  if ($installDir)
  {
    $couchPotatoDir = Split-Path $installDir
    $sitePackages = Split-Path $couchPotatoDir
    Write-Host "Found CouchPotato service configuration directory of $couchPotatoDir"
  }
  # not found - do some guesswork
  else
  {
    # Use PYTHONHOME if it exists, or fallback to 'Where' to search PATH
    if ($Env:PYTHONHOME) { $localPython = Join-Path $Env:PYTHONHOME 'python.exe' }

    if (!$Env:PYTHONHOME -or !(Test-Path $localPython))
      { $localPython = Which python.exe }

    if (!(Test-Path $localPython))
    {
      Write-Warning 'Could not find CouchPotato or Python!'
    }
    else
    {
      $pythonRoot = Split-Path $localPython
      $sitePackages = (Join-Path (Join-Path $pythonRoot 'Lib') 'site-packages')
      $couchPotatoDir = Join-Path $sitePackages 'CouchPotatoServer'
      Write-Host "CouchPotato service configuration not found - assuming $couchPotatoDir"
    }
  }

  # delete the service and reg keys
  if (Get-Service CouchPotato -ErrorAction SilentlyContinue)
  {
    Write-Host 'Deleting CouchPotato service'
    Stop-Service CouchPotato
    sc.exe delete CouchPotato
  }

  # we found CouchPotato on disk, so delete all the files
  if (Test-Path $couchPotatoDir)
  {
    Write-Host "Removing all files in $couchPotatoDir"
    Remove-Item $couchPotatoDir -Recurse -Force -ErrorAction SilentlyContinue
    if (Test-Path $couchPotatoDir)
    {
      Write-Warning "$couchPotatoDir must be deleted manually"
    }
  }

  $sysProfile = Join-Path 'config' 'systemprofile'
  $couchPotatoData = Join-Path (Join-Path 'AppData' 'Roaming') 'CouchPotato'
  $couchPotatoData = Join-Path $sysProfile $couchPotatoData

  # config files are created on first start-up
  $configPath = (Join-Path ([Environment]::GetFolderPath('System')) $couchPotatoData),
  # must handle SYSWOW64 on x64 (works inside both 32-bit and 64-bit host procs)
  (Join-Path ([Environment]::GetFolderPath('SystemX86')) $couchPotatoData) |
    Select -Unique |
    % {
      if (Test-Path $_)
      {
        Write-Warning "$_ data directory must be deleted manually"
      }
    }

  # Read SABNzbd+ config file to delete CouchPotato scripts if configured
  $sabDataPath = Join-Path $Env:LOCALAPPDATA 'sabnzbd'
  $sabIniPath = Join-Path $sabDataPath 'sabnzbd.ini'
  if (Test-Path $sabIniPath)
  {
    Write-Host "Reading SABnzbd+ config file at $sabIniPath"
    $sabConfig = Get-IniContent $sabIniPath

    $scriptsDir = $sabConfig.misc.script_dir
    # found a legit scripts dir, so delete CouchPotato files
    if ($scriptsDir -and ($scriptsDir -ne "`"`"") -and (Test-Path $scriptsDir))
    {
      Write-Warning "SABnzbd+ post-processing scripts at $scriptsDir must be deleted manually"
    }

    $movies = $sabconfig.categories.movies
    if ($movies -and ($movies.script -eq 'sabToCouchPotato.py'))
    {
      Write-Host 'Removed sabToCouchPotato.py script from movies category inside SABnzbd+'
      $movies.script = 'None'
      $sabConfig | Out-IniFile -FilePath $sabIniPath -Force -Encoding UTF8
    }

    Write-Host 'Restarting SABnzbd+ to accept configuration changes'
    $url = ("http://localhost:$($sabConfig.misc.port)/api?mode=restart" +
      "&apikey=$($sabConfig.misc.api_key)")
    try
    {
      (New-Object Net.WebClient).DownloadString($url)
    }
    catch
    {
      Write-Host "SABNzbd+ not responding to restart request"
    }
  }

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
