$package = 'SublimeText3'
$installFolder = 'Sublime Text 3'

try {

  $paths = $Env:ProgramFiles
  
  if (${Env:ProgramFiles(x86)}) {
	$paths = $paths, ${Env:ProgramFiles(x86)}
  }

  $path = $paths |
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
