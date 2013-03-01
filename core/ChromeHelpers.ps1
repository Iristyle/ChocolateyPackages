function Get-ChromePath
{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $false)]
    [Switch]
    $Canary = $false
  )

  $path = if ($Canary) { 'Google\Chrome SxS' } else { 'Google\Chrome' }

  Join-Path $Env:LOCALAPPDATA $path
}

function Get-ChromeExtensions
{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $false)]
    [Switch]
    $Canary = $false,

    [Parameter(Mandatory = $false)]
    [bool]
    $ExcludeBlacklist = $true
  )

  $installed = @{}

  $root = Get-ChromePath -Canary:$Canary
  $prefsPath = Join-Path $root 'User Data\Default\Preferences'

  if (Test-Path $prefsPath)
  {
    Write-Verbose "Examining $prefsPath for installed extensions...`n`n"
    $prefs = ConvertFrom-Json ([IO.File]::ReadAllText($prefsPath))

    $prefs.extensions.settings.PsObject.Properties |
      ? { if ($ExcludeBlacklist) { -not $_.Value.blacklist } else { $true } } |
      % {
         $installed[$_.Name] = $_.Value
         $msg = "Found Extension $($_.Value.manifest.name) [$($_.Name)]"
         if (!$ExcludeBlacklist -and $_.Value.blacklist)
         {
          $msg += " - Blacklist [$($_.Value.blacklist)]"
        }
         Write-Verbose $msg
      }
  }

  return $installed
}

# this is a bit of a misnomer, it just finds and launches Chrome with
# new tabs for each extension since the end user still has to click a button
function Install-ChromeExtensions
{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $false)]
    [Switch]
    $Canary = $false,

    [Parameter(Mandatory = $true)]
    [Hashtable]
    $Extensions
    # Expected a hash of Id / Name
  )

  $name = 'Chrome'
  if ($Canary) { $name += ' Canary'}

  $installed = Get-ChromeExtensions -Canary:$Canary
  $rootPath = Get-ChromePath -Canary:$Canary
  $chromeExe = Join-Path $rootPath 'Application\chrome.exe'

  $Extensions.GetEnumerator() |
    ? { $installed.Keys -contains $_.Key } |
    % {
      Write-Verbose "$name Extension $($_.Value) [$($_.Key)] is already installed!"
    }

  $storeUrl = 'https://chrome.google.com/webstore/detail'
  $chromeParams = @()
  $neededPackages = $Extensions.GetEnumerator() |
    ? { $installed.Keys -notcontains $_.Key } |
    % {
      Write-Host "Launching $name to install extension $($_.Value) [$($_.Key)]!"
      # http://peter.sh/experiments/chromium-command-line-switches/
      $chromeParams += "--new-window", "$storeUrl/$($_.Key)"
    }

  if ($chromeParams.Count -gt 0)
  {
    Write-Host "`n`nExecuting $chromeExe $chromeParams"
    &$chromeExe @chromeParams
  }
  else
  {
    Write-Host "`n`nAll extensions already installed!"
  }
}
