$package = 'WinImage'
$version = '90'

try {
  $params = @{
    PackageName = $package;
    FileType = 'zip';
    Url = "http://www.winimage.com/download/winima$version.zip";
    Url64Bit = "http://www.winimage.com/download/wima64$version.zip";
    UnzipLocation = Join-Path $Env:SystemDrive 'tools';
  }

  $binRoot = Join-Path $Env:SystemDrive $Env:Chocolatey_Bin_Root
  if (Test-Path $binRoot)
  {
    $params.UnzipLocation = $binRoot
  }

  $params.UnzipLocation = Join-Path $params.UnzipLocation $package

  if (!(Test-Path($params.UnzipLocation)))
  {
    New-Item $params.UnzipLocation -Type Directory | Out-Null
  }

  Install-ChocolateyZipPackage @params

  Get-ChildItem $params.UnzipLocation -Filter *.exe -Recurse |
    ? { $_.Name -match 'winimage' } |
    % {
      Generate-BinFile ($_.Name -replace '\.exe', '') $_.FullName
    }

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
