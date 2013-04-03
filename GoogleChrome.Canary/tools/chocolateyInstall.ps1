$package = 'Chrome.Canary'

try {

  function Get-CurrentDirectory
  {
    $thisName = $MyInvocation.MyCommand.Name
    [IO.Path]::GetDirectoryName((Get-Content function:$thisName).File)
  }

  . (Join-Path (Get-CurrentDirectory) 'ChromeHelpers.ps1')

  $installedPath = Get-ChromePath -Canary
  if (Test-Path $installedPath)
  {
    Write-Host "Chrome Canary already installed at $installedPath"
  }
  else
  {
    $url = 'https://dl.google.com/tag/s/appguid%3D%7B4ea16ac7-fd5a-47c3-875b-dbf4a2008c20%7D%26iid%3D%7B0281A7E2-6043-D983-8BBA-7FD622493C9D%7D%26lang%3Den%26browser%3D4%26usagestats%3D1%26appname%3DGoogle%2520Chrome%2520Canary%26needsadmin%3Dfalse/update2/installers/ChromeSetup.exe'

    Install-ChocolateyPackage 'ChromeSetup' 'exe' '' $url
  }

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
