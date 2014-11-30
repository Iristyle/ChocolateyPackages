$package = 'Elixir'
$version = '0.12.5'

try {
  $params = @{
    PackageName = $package;
    FileType = 'zip';
    Url = "https://github.com/elixir-lang/elixir/releases/download/v$version/Precompiled.zip";
    UnzipLocation = Join-Path $Env:SystemDrive 'tools';
  }

  $binRoot = Join-Path $Env:SystemDrive $Env:Chocolatey_Bin_Root
  if (Test-Path $binRoot)
  {
    $params.UnzipLocation = $binRoot
  }

  $params.UnzipLocation = Join-Path $params.UnzipLocation 'Elixir'

  if (!(Test-Path($params.UnzipLocation)))
  {
    New-Item $params.UnzipLocation -Type Directory | Out-Null
  }

  Install-ChocolateyZipPackage @params

  $elixirBin = Join-Path $params.UnzipLocation 'bin'

  Install-ChocolateyPath $elixirBin

  Write-Host @'
Please restart your current shell session to access Elixir commands:
elixir
elixirc
mix
iex.bat (use batch file within Powershell due to name collision)
'@

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}

