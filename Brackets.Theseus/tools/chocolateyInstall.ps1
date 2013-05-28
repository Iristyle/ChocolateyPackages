$package = 'Brackets.Theseus'

try {

  npm install -g node-theseus@0.0.7

  $params = @{
    PackageName = $package;
    FileType = 'zip';
    Url = 'https://s3.amazonaws.com/theseus-downloads/theseus-0.2.8.zip';
    UnzipLocation = Join-Path $Env:APPDATA 'Brackets\extensions\user';
  }

  Install-ChocolateyZipPackage @params

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
