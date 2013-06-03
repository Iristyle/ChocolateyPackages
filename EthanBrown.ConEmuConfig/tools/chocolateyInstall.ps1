$package = 'EthanBrown.ConEmuConfig'

try {

  function Get-CurrentDirectory
  {
    $thisName = $MyInvocation.MyCommand.Name
    [IO.Path]::GetDirectoryName((Get-Content function:$thisName).File)
  }

  Push-Location (Get-CurrentDirectory)
  reg import .\ConEmu.reg

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package $($_.Exception.Message)
  throw
}
