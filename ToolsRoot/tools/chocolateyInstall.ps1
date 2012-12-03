$packageName = 'ToolsRoot'

try
{
  $variableName = 'Chocolatey_Bin_Root'
  if (!(Get-Item Env:$variableName -ErrorAction SilentlyContinue))
  {
    $path = '\tools'
    [Environment]::SetEnvironmentVariable($variableName, $path, 'User')
    Set-Item Env:$variableName $path

    $binRoot = Join-Path $Env:SystemDrive $path
    Write-Host "Configured $variableName as $binRoot"
  }

  Write-ChocolateySuccess $package
}
catch
{
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
