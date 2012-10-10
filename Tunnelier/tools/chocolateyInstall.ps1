try {
  $package = 'Bitvise Tunnelier'

  $url = 'http://dl.bitvise.com/BvSshClient-Inst.exe'

  $installDir = ${Env:ProgramFiles(x86)}, $Env:ProgramFiles |
    ? { Test-Path $_ } | Select -First 1
  $installDir = Join-Path $installDir 'Bitvise SSH Client'

  # https://fogbugz.bitvise.com/default.asp?Tunnelier.2.11840.3
  $params = '-acceptEULA', '-force', "-installDir=`"$installDir`"",
    '-noDesktopIcon'
  Install-ChocolateyPackage 'BvSshClient-Inst' 'exe' $params $url

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
