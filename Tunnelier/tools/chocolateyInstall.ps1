try {
  $package = 'Bitvise Tunnelier'

  $url = 'http://dl.bitvise.com/BvSshClient-Inst.exe'

  $installDir = ${Env:ProgramFiles(x86)}, $Env:ProgramFiles |
    ? { Test-Path $_ } | Select -First 1
  $installDir = Join-Path $installDir 'Bitvise SSH Client'

  $params = '-acceptEULA', '-force', "-installDir=`"$installDir`""
  Install-ChocolateyPackage 'BvSshClient-Inst' 'exe' $params $url

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
