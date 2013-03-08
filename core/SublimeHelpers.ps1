# uses functions in JsonHelpers.ps1

function Get-SublimePackagesPath
{
  $installPath = Join-Path $Env:ProgramFiles 'Sublime Text 2'
  $settingsPath = Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'Sublime Text 2'
  $packagesPath = Join-Path $settingsPath 'Packages'
  if (!(Test-Path $packagesPath)) { New-Item $packagesPath -Type Directory }

  return $packagesPath
}

function Get-SublimeUserPath
{
  Join-Path (Get-SublimePackagesPath) 'User'
}

function Merge-PackageControlSettings
{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [string]
    $FilePath
  )

  $root = Get-SublimeUserPath
  $existingPath = Join-Path $root 'Package Control.sublime-settings'
  $existingText = [IO.File]::ReadAllText($existingPath) -replace '(?m)^\s*//.*$', ''
  if ([string]::IsNullOrEmpty($existingText)) { $existingText = '{}' }

  $existing = ConvertFrom-Json $existingText
  Write-Verbose "Existing settings: `n`n$existingText`n`n"

  $new = ConvertFrom-Json ([IO.File]::ReadAllText($FilePath))

  # simple arrays
  'installed_packages', 'repositories' |
    ? { $new.$_ -ne $null } |
    % { Merge-JsonArray -Name $_ -Destination $existing -Array $new.$_ }

  # maps
  'package_name_map' |
    ? { $new.$_ -ne $null } |
    % { Merge-JsonSimpleMap -Name $_ -Destination $existing -SimpleMap $new.$_ }

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
    $FilePath
  )

  $root = Get-SublimeUserPath
  $existingPath = Join-Path $root 'Preferences.sublime-settings'
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
