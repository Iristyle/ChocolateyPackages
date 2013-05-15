# uses functions in JsonHelpers.ps1
function Get-SublimeInstallPath
{
  Join-Path $Env:ProgramFiles 'Sublime Text 2'
}

function Get-SublimeSettingsPath
{
  Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'Sublime Text 2'
}

function Get-SublimePackagesPath
{
  $packagesPath = Join-Path (Get-SublimeSettingsPath) 'Packages'
  if (!(Test-Path $packagesPath))
  {
    New-Item $packagesPath -Type Directory | Out-Null
  }

  return $packagesPath
}

function Get-SublimeUserPath
{
  $path = Join-Path (Get-SublimePackagesPath) 'User'
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
    $Directory
  )

  $packagesPath = Get-SublimePackagesPath
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

function Install-SublimePackageControl
{
  # install package control
  $packagesPath = Join-Path (Get-SublimeSettingsPath) 'Installed Packages'
  if (!(Test-Path $packagesPath)) { New-Item $packagesPath -Type Directory }
  $packageControl = Join-Path $packagesPath 'Package Control.sublime-package'

  if (!(Test-Path $packageControl))
  {
    # http://wbond.net/sublime_packages/package_control/installation
    $packageUrl = 'http://sublime.wbond.net/Package%20Control.sublime-package'
    Get-ChocolateyWebFile -url $packageUrl -fileFullPath $packageControl
  }
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
  if (!(Test-Path $existingPath))
  {
    '{}' | Out-File -FilePath $existingPath -Encoding ASCII
  }
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
