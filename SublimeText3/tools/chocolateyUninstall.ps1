$package = 'SublimeText3'
$installFolder = 'Sublime Text 3'

try {

  $path = ${Env:ProgramFiles(x86)}, $Env:ProgramFiles |
    % { Join-Path $_ $installFolder } |
    ? { Test-Path $_ } |
    Select -First 1

  if ($path)
  {
    Push-Location $path
    $uninstaller = '.\unins000.exe'
    if (Test-Path $uninstaller)
    {
      $unargs = '/silent', '/verysilent', '/suppressmsgboxes', '/norestart'
      &$uninstaller $unargs
    }
  }

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
