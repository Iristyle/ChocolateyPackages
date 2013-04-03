$package = 'Chrome.Dev'

try {

  function Get-CurrentDirectory
  {
    $thisName = $MyInvocation.MyCommand.Name
    [IO.Path]::GetDirectoryName((Get-Content function:$thisName).File)
  }

  . (Join-Path (Get-CurrentDirectory) 'ChromeHelpers.ps1')

  $installedPath = Get-ChromePath
  $params = @{
    Path = 'HKCU:\Software\Google\Update\ClientState\{8A69D345-D564-463C-AFF1-A69D9E530F96}';
    Name = 'ap';
    ErrorAction = 'SilentlyContinue';
  }
  $installType = Get-ItemProperty @params | Select -ExpandProperty 'ap'

  if ((Test-Path $installedPath) -and ($installType -match 'dev'))
  {
      Write-Host "Chrome Dev already installed at $installedPath"
  }
  else
  {
    $params = @{
      PackageName = $package;
      FileType = 'exe';
      SilentArgs = '/silent /installsource silent /install';
      Url = 'https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7B0AA7B49A-29EA-0AE3-8A45-61F351F89414%7D%26lang%3Den%26browser%3D2%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dfalse%26ap%3D2.0-dev%26installdataindex%3Ddefaultbrowser/update2/installers/ChromeSetup.exe'
    }

    Install-ChocolateyPackage @params
  }

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
