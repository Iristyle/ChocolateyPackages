$package = 'Brackets'
$build = '30'

try {
  $params = @{
    PackageName = $package;
    FileType = 'msi';
    SilentArgs = '/q';
    Url = "http://download.brackets.io/file.cfm?platform=WIN&build=$build";
  }

  Install-ChocolateyPackage @params

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
