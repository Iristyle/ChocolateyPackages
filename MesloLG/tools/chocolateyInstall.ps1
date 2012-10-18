$package = 'MesloLG.DZ'

try {
  # no dot
  # $fontUrl = 'https://github.com/downloads/andreberg/Meslo-Font/Meslo%20LG%20v1.0.zip'
  # dotted zero
  $fontUrl = 'https://github.com/downloads/andreberg/Meslo-Font/Meslo%20LG%20DZ%20v1.0.zip'
  $destination = Join-Path $Env:Temp 'MesloFont'

  Install-ChocolateyZipPackage -url $fontUrl -unzipLocation $destination

  $shell = New-Object -ComObject Shell.Application
  $fontsFolder = $shell.Namespace(0x14)

  Get-ChildItem $destination -Recurse -Filter *.ttf |
    % { $fontsFolder.CopyHere($_.FullName) }

  Remove-Item $destination -Recurse

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
