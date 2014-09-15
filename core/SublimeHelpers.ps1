# uses functions in JsonHelpers.ps1
function Get-SublimeInstallPath
{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $false)]
    [ValidateRange(2,3)]
    [int]
    $Version = 2
  )

  Join-Path $Env:ProgramFiles "Sublime Text $Version"
}

function Get-SublimeSettingsPath
{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $false)]
    [ValidateRange(2,3)]
    [int]
    $Version = 2
  )

  Join-Path ([Environment]::GetFolderPath('ApplicationData')) "Sublime Text $Version"
}

function Get-SublimePackagesPath
{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $false)]
    [ValidateRange(2,3)]
    [int]
    $Version = 2
  )

  $packagesPath = Join-Path (Get-SublimeSettingsPath -Version $Version) 'Packages'
  if (!(Test-Path $packagesPath))
  {
    New-Item $packagesPath -Type Directory | Out-Null
  }

  return $packagesPath
}

function Get-SublimeUserPath
{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $false)]
    [ValidateRange(2,3)]
    [int]
    $Version = 2
  )

  $path = Join-Path (Get-SublimePackagesPath -Version $Version) 'User'
  if (!(Test-Path $path))
  {
    New-Item $path -Type Directory  | Out-Null
  }
  return $path
}

function Install-SublimePackagesFromCache
{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [string]
    $Directory,

    [Parameter(Mandatory = $false)]
    [ValidateRange(2,3)]
    [int]
    $Version = 2
  )

  $packagesPath = Get-SublimePackagesPath -Version $Version
  Get-ChildItem $Directory |
    ? { $_.PsIsContainer } |
    % { @{Path = $_.FullName; Destination = Join-Path $packagesPath $_.Name }} |
    ? {
      $exists = Test-Path $_.Destination
      if ($exists) { Write-Host "[ ] Skipping existing $($_.Destination)" }
      return !$exists
    } |
    % {
      Write-Host "[+] Copying cached package $($_.Destination)"
      Copy-Item @_ -Recurse
    }
}

# clean up any previous installation attempts that were Git clnoe based
function Remove-GitInstalledSublimePackageControl
{
  $installPath = 'Packages\Package Control'
  $packagesPath = Join-Path (Get-SublimeSettingsPath -Version $Version) $installPath
  if (Test-Path $packagesPath)
  {
    Write-Host "Removing previously Git installed Package Control from $packagesPath"
    Remove-Item $packagesPath -Recurse -Force -ErrorAction SilentlyContinue
  }
}

function Install-SublimePackageControl
{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $false)]
    [ValidateRange(2,3)]
    [int]
    $Version = 2,

    [Parameter(Mandatory = $false)]
    [Switch]
    $PreRelease = $false
  )

  # remove Git cloned version if it exists
  if ($Version -eq 3) { Remove-GitInstalledSublimePackageControl }

  # install package control
  $packageFolder = 'Installed Packages'
  $packagesPath = Join-Path (Get-SublimeSettingsPath -Version $Version) $packageFolder

  if (!(Test-Path $packagesPath)) { New-Item $packagesPath -Type Directory }

  $packageControl = Join-Path $packagesPath 'Package Control.sublime-package'

  if (Test-Path $packageControl) { Remove-item $packageControl }

  # http://wbond.net/sublime_packages/package_control/installation
  $packageUrl = 'http://sublime.wbond.net/Package%20Control.sublime-package'
  if ($PreRelease)
  {
    $packageUrl = 'https://sublime.wbond.net/prerelease/Package%20Control.sublime-package'
  }
  Get-ChocolateyWebFile -url $packageUrl -fileFullPath $packageControl

  $settings = @{ 'install_prereleases' = $PreRelease }
  Merge-PackageControlSettings -Settings $settings -Version $Version
}

function Merge-PackageControlSettings
{
  [CmdletBinding(DefaultParameterSetName = "File")]
  param(
    [Parameter(Mandatory = $false, ParameterSetName = "File")]
    [string]
    $FilePath,

    [Parameter(Mandatory = $false, ParameterSetName = "Hash")]
    [Hashtable]
    $Settings,

    [Parameter(Mandatory = $false)]
    [ValidateRange(2,3)]
    [int]
    $Version = 2
  )

  $root = Get-SublimeUserPath -Version $Version
  $existingPath = Join-Path $root 'Package Control.sublime-settings'
  if (!(Test-Path $existingPath))
  {
    '{}' | Out-File -FilePath $existingPath -Encoding ASCII
  }
  $existingText = [IO.File]::ReadAllText($existingPath) -replace '(?m)^\s*//.*$', ''
  if ([string]::IsNullOrEmpty($existingText)) { $existingText = '{}' }

  $existing = ConvertFrom-Json $existingText
  Write-Verbose "Existing settings: `n`n$existingText`n`n"

  if ($PsCmdlet.ParameterSetName -eq 'File')
  {
    $new = ConvertFrom-Json ([IO.File]::ReadAllText($FilePath))
  }
  else
  {
    $new = $Settings
  }

  $simpleArrays = @('installed_packages', 'repositories', 'channels',
    'auto_upgrade_ignore', 'git_update_command', 'hg_update_command',
    'dirs_to_ignore', 'files_to_ignore', 'files_to_include',
    'files_to_ignore_binary', 'files_to_include_binary' )
  $simpleArrays |
    ? { $new.$_ -ne $null } |
    % { Merge-JsonArray -Name $_ -Destination $existing -Array $new.$_ }

  $maps = @('package_name_map')
  $maps |
    ? { $new.$_ -ne $null } |
    % { Merge-JsonSimpleMap -Name $_ -Destination $existing -SimpleMap $new.$_ }

  $arrayOfMaps = @('certs')
  $arrayOfMaps |
    ? { $new.$_ -ne $null } |
    % { Merge-JsonArrayOfSimpleMap -Name $_ -Destination $existing -Array $new.$_ }

  $excluded = $simpleArrays + $maps + $arrayOfMaps
  if ($new -is [PSCustomObject]) { $props = $new.PSObject.Properties }
  else { $props = $new.GetEnumerator() }
  $props |
    ? { $excluded -inotcontains $_.Name } |
    % {
      Merge-JsonNamedValue -Name $_.Name -Destination $existing -Value $_.Value
    }

  $json = $existing | ConvertTo-Json -Depth 10 | ConvertFrom-UnicodeEscaped
  Write-Verbose "Updated settings: `n`n$json`n"
  [IO.File]::WriteAllText($existingPath, $json, [System.Text.Encoding]::ASCII)
}

function Merge-Preferences
{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [String]
    $FilePath,

    [Parameter(Mandatory = $false)]
    [ValidateRange(2,3)]
    [int]
    $Version = 2
  )

  $root = Get-SublimeUserPath -Version $Version
  $existingPath = Join-Path $root 'Preferences.sublime-settings'
  if (!(Test-Path $existingPath))
  {
    '{}' | Out-File -FilePath $existingPath -Encoding ASCII
  }

  $existingText = [IO.File]::ReadAllText($existingPath) -replace '(?m)^\s*//.*$', ''
  if ([string]::IsNullOrEmpty($existingText)) { $existingText = '{}' }

  $existing = ConvertFrom-Json $existingText
  Write-Verbose "Existing settings: `n`n$existingText`n`n"

  $new = ConvertFrom-Json ([IO.File]::ReadAllText($FilePath))

  $simpleArrays = @('ignored_packages', 'indent_guide_options', 'rulers',
    'font_options', 'folder_exclude_patterns', 'file_exclude_patterns',
    'binary_file_patterns')

  $simpleArrays |
    ? { $new.$_ -ne $null } |
    % { Merge-JsonArray -Name $_ -Destination $existing -Array $new.$_ }

  'auto_complete_triggers' |
    ? { $new.$_ -ne $null } |
    % { Merge-JsonArrayOfSimpleMap -Name $_ -Destination $existing -Array $new.$_ }

  $excluded = $simpleArrays + 'auto_complete_triggers'
  $new.PSObject.Properties |
    ? { $excluded -inotcontains $_.Name } |
    % {
      Merge-JsonNamedValue -Name $_.Name -Destination $existing -Value $_.Value
    }

  # HACK: one last top level scan to ensure we don't have any single "
  $existing.PSObject.Properties |
    ? { $_.Value -is [String] } |
    % { $_.Value = $_.Value | ConvertTo-DoubleEscapedQuotes -Name $_.Name }

  $json = $existing | ConvertTo-Json -Depth 10 | ConvertFrom-UnicodeEscaped
  Write-Verbose "Updated settings: `n`n$json`n"
  [IO.File]::WriteAllText($existingPath, $json, [System.Text.Encoding]::ASCII)
}
