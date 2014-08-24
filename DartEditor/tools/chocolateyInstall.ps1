$package = 'DartEditor'

try {
  $params = @{
    PackageName = $package;
    FileType = 'zip';
    Url = 'http://storage.googleapis.com/dart-archive/channels/stable/release/latest/editor/darteditor-windows-ia32.zip';
    Url64bit = 'http://storage.googleapis.com/dart-archive/channels/stable/release/latest/editor/darteditor-windows-x64.zip';
    UnzipLocation = Join-Path $Env:SystemDrive 'tools';
  }

  $binRoot = Join-Path $Env:SystemDrive $Env:Chocolatey_Bin_Root
  if (Test-Path $binRoot)
  {
    $params.UnzipLocation = $binRoot
  }

  if (!(Test-Path($params.UnzipLocation)))
  {
    New-Item $params.UnzipLocation -Type Directory | Out-Null
  }

  Install-ChocolateyZipPackage @params

  $dartPath = Join-Path $params.UnzipLocation 'dart'
  Get-ChildItem $dartPath -Filter *.exe -Recurse |
    ? { $_.Name -match 'dart' } |
    % {
      Generate-BinFile ($_.Name -replace '\.exe', '') $_.FullName
    }

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
