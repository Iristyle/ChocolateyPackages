try {
  $package = 'SourceCodePro'

  $fontUrl = 'https://github.com/downloads/adobe/Source-Code-Pro/SourceCodePro_FontsOnly-1.010.zip'
  $destination = Join-Path $Env:Temp 'SourceCodePro'

  Install-ChocolateyZipPackage -url $fontUrl -unzipLocation $destination

  $shell = New-Object -ComObject Shell.Application
  $fontsFolder = $shell.Namespace(0x14)

  Get-ChildItem $destination -Recurse -Filter *.otf |
    % { $fontsFolder.CopyHere($_.FullName) }

  Remove-Item $destination -Recurse

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
