$package = 'CasperJS'
$version = '1.1-beta1'

try {
  $params = @{
    PackageName = $package;
    FileType = 'zip';
    Url = "https://github.com/n1k0/casperjs/zipball/$version";
    UnzipLocation = Join-Path $Env:TEMP "$package\$version";
  }

  if (!(Test-Path($params.UnzipLocation)))
  {
    New-Item $params.UnzipLocation -Type Directory | Out-Null
  }

  # unzip to a temporary location
  Install-ChocolateyZipPackage @params

  # then move the sha1 named package over to tools\CasperJS
  $binRoot = Join-Path $Env:SystemDrive $Env:Chocolatey_Bin_Root
  $moveTo = if (Test-Path $binRoot) { $binRoot } `
    else { Join-Path $Env:SystemDrive 'tools' }
  $moveTo = Join-Path $moveTo $package

  if (Test-Path $moveTo) { Remove-Item $moveTo -Recurse -ErrorAction SilentlyContinue }

  Get-ChildItem $params.UnzipLocation |
    Select -First 1 |
    Move-Item -Destination $moveTo

  $batchLocation = Get-ChildItem $moveTo -Filter 'casperjs.bat' -Recurse |
    Select -ExpandProperty 'DirectoryName' -First 1

  Install-ChocolateyPath $batchLocation

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
