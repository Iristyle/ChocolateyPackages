$package = 'EthanBrown.ChromeDevExtensions'

try {

  function Get-CurrentDirectory
  {
    $thisName = $MyInvocation.MyCommand.Name
    [IO.Path]::GetDirectoryName((Get-Content function:$thisName).File)
  }

  . (Join-Path (Get-CurrentDirectory) 'ChromeHelpers.ps1')

  Write-Host "Launching Chrome extensions page to remove extensions"

  $chromePath = Get-ChromePath
  $chromeExe = Join-Path $chromePath 'Application\chrome.exe'
  $chromeParams = @('--new-window', 'chrome://extensions/')
  &$chromeExe @chromeParams

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
