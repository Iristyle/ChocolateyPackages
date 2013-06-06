$package = 'AdobeAIR'
$version = '3.7'

try {

  $params = @{
    PackageName = $package;
    FileType = 'exe';
    SilentArgs = '-silent -eulaAccepted';
    Url = 'http://airdownload.adobe.com/air/win/download/3.7/AdobeAIRInstaller.exe'
  }

  Install-ChocolateyPackage @params

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
