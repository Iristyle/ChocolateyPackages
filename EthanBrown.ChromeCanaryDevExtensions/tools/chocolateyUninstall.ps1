$package = 'EthanBrown.ChromeCanaryDevExtensions'

try {

  function Get-CurrentDirectory
  {
    $thisName = $MyInvocation.MyCommand.Name
    [IO.Path]::GetDirectoryName((Get-Content function:$thisName).File)
  }

  . (Join-Path (Get-CurrentDirectory) 'ChromeHelpers.ps1')

  Write-Host "Launching Chrome Canary extensions page to remove extensions"

  $chromePath = Get-ChromePath -Canary
  $chromeExe = Join-Path $chromePath 'Application\chrome.exe'
  $chromeParams = @('--new-window', 'chrome://extensions/')
  &$chromeExe @chromeParams

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
