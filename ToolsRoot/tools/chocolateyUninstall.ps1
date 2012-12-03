$package = 'ToolsRoot'

try
{
  $variableName = 'Chocolatey_Bin_Root'
  $binRoot = Get-Item Env:$variableName -ErrorAction SilentlyContinue |
    Select -ExpandProperty Value -First 1

  if ($binRoot)
  {
    [Environment]::SetEnvironmentVariable($variableName, '', 'User')
    Set-Item Env:$variableName $null

    Write-Host "Removed $variableName [was $binRoot]"
  }

  Write-ChocolateySuccess $package
}
catch
{
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
