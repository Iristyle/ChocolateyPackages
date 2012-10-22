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

  Write-Host 'Deleting SickBeard Windows Firewall config'
  netsh advfirewall firewall delete rule name="SickBeard"

  # check registry for path to sickbeard
  $servicePath = 'HKLM:\SYSTEM\CurrentControlSet\Services\SickBeard\Parameters'
  $installDir = Get-ItemProperty $servicePath -ErrorAction SilentlyContinue |
    Select -ExpandProperty AppParameters

  if ($installDir)
  {
    $sickBeardDir = Split-Path $installDir
    $sitePackages = Split-Path $sickBeardDir
    Write-Host "Found SickBeard service configuration directory of $sickBeardDir"
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
      Write-Warning 'Could not find SickBeard or Python!'
    }
    else
    {
      $pythonRoot = Split-Path $localPython
      $sitePackages = (Join-Path (Join-Path $pythonRoot 'Lib') 'site-packages')
      $sickBeardDir = Join-Path $sitePackages 'Sick-Beard'
      Write-Host "SickBeard service configuration not found - assuming $sickBeardDir"
    }
  }

  # delete the service and reg keys
  if (Get-Service SickBeard -ErrorAction SilentlyContinue)
  {
    Write-Host 'Deleting SickBeard service'
    Stop-Service SickBeard
    sc.exe delete SickBeard
  }

  # we found Sickbeard on disk, so delete all the files
  if (Test-Path $sickBeardDir)
  {
    Write-Host "Removing all files in $sickBeardDir"
    Remove-Item $sickBeardDir -Recurse -Force -ErrorAction SilentlyContinue
    if (Test-Path $sickBeardDir)
    {
      Write-Warning "$sickBeardDir must be deleted manually"
    }
  }

  # Read SABNzbd+ config file to delete SickBeard scripts if configured
  $sabDataPath = Join-Path $Env:LOCALAPPDATA 'sabnzbd'
  $sabIniPath = Join-Path $sabDataPath 'sabnzbd.ini'
  if (Test-Path $sabIniPath)
  {
    Write-Host "Reading SABnzbd+ config file at $sabIniPath"
    $sabConfig = Get-IniContent $sabIniPath

    $scriptsDir = $sabConfig.misc.script_dir
    # found a legit scripts dir, so delete SickBeard files
    if ($scriptsDir -and ($scriptsDir -ne "`"`"") -and (Test-Path $scriptsDir))
    {
      Write-Host "Found SABnzbd+ script_dir $scriptsDir"
      $sickbeardScripts = 'autoProcessTV.cfg', 'autoProcessTV.cfg.sample',
        'autoProcessTV.py', 'hellaToSickBeard.py', 'sabToSickBeard.py'

      Write-Host "Removing SickBeard scripts $sickbeardScripts"
      Get-ChildItem -Path $scriptsDir -Include $sickbeardScripts -Recurse |
        Remove-Item -Force
    }

    $tv = $sabconfig.categories.tv
    if ($tv -and ($tv.script -eq 'sabToSickBeard.py'))
    {
      Write-Host 'Removed sabToSickBeard.py script from tv category inside SABnzbd+'
      $tv.script = 'None'
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
