try 
{
  $package = 'SABnzbd+'
  $upgrade = $false

  # stop helper services if they're running
  Get-Service -Include SABnzbd, SABHelper |
    Stop-Service -Force
  
  $installPath = (Join-Path "${Env:\ProgramFiles(x86)}" 'sabnzbd'), 
    (Join-Path 'Env:ProgramFiles' 'sabnzbd') |
    ? { Test-Path $_ } |
    Select -First 1

  $helper = 'SABnzbd-helper.exe'
  $service = 'SABnzbd-service.exe'
  
  # already installed, so must call remove on existing exes to be safe
  if ($installPath -ne $null)
  {
    $upgrade = $true
    $helper, $service | 
      % { 
        $path = Join-Path $installPath $_
        if (Test-Path $path) { &$path remove }
      }
  }
  
  #uses NSIS installer
  Install-ChocolateyPackage 'SABnzbd-0.7.4-win32-setup' 'exe' '/S' `
    'http://sourceforge.net/projects/sabnzbdplus/files/sabnzbdplus/0.7.4/SABnzbd-0.7.4-win32-setup.exe/download'

  #need to turn on / install services
  @("${Env:\ProgramFiles(x86)}", '^%ProgramFiles(x86)^%'), 
  @($Env:ProgramFiles, '^%ProgramFiles^%') |
    % {
      $path = Join-Path $_[0] 'sabnzbd'
      if (Test-Path $path)
      {
        $installPath = $path
        $dosPath = $_[1]
        break
      }
    }

  #register file association
  #http://stackoverflow.com/questions/323426/windows-command-line-non-evaluation-of-environment-variable
  cmd /c assoc .nzb=NZBFile
  $sabPath = "^`"$dosPath\sabnzbd\SABnzbd.exe^`""
  cmd /c ftype NZBFile=$sabPath `"%1`"

  Push-Location $installPath

  $dataDirectory = Join-Path $Env:LOCALAPPDATA 'sabnzbd'
  &".\$service" -f $dataDirectory install
  &".\$helper" install

  Pop-Location

  # Set-Service cmdlet doesn't have delayed start :(
  sc.exe config SABnzbd start= delayed-auto

  # configure windows firewall
  netsh advfirewall firewall delete rule name="SABnzbd+"
  netsh advfirewall firewall add rule name="SABnzbd+" dir=in protocol=tcp localport=8080 action=allow program="$installPath\SABnzbd-service.exe"
  netsh advfirewall firewall add rule name="SABnzbd+" dir=in protocol=tcp localport=9090 action=allow program="$installPath\SABnzbd-service.exe"

  Start-Service SABnzbd

  # no need to use the web UI to configure an upgrade
  if ($upgrade) { return }

  #wait up to 5 seconds for service to fire up
  0..10 |
    % {
      if ((Get-Service SABnzbd).Status -eq 'Running') 
      { 
        #launch local default browser to configure
        [Diagnostics.Process]::Start('http://localhost:8080')
        break 
      }
      Start-Sleep -Milliseconds 500
    }  
  
  Write-ChocolateySuccess $package
}
catch 
{
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
