$package = 'Posh-VsVars'

function Get-CurrentDirectory
{
  $thisName = $MyInvocation.MyCommand.Name
  [IO.Path]::GetDirectoryName((Get-Content function:$thisName).File)
}

try {
  $current = Get-CurrentDirectory
  . (Join-Path $current 'PowerShellHelpers.ps1')
  . (Join-Path $current 'EncodingHelpers.ps1')

  $moduleDirectory = Get-ModuleDirectory
  $installDirectory = Join-Path $moduleDirectory $package
  # find user specific module directory

  # unload module if its already loaded necessary
  Get-Module -Name $package | Remove-Module

  try
  {
    if (Test-Path($installDirectory))
    {
      Remove-Item $installDirectory -Recurse -Force
    }
  }
  catch
  {
    Write-Host "Could not remove existing $package folder"
  }

  Write-Host "Installing $package to $installDirectory..."
  $params = @{
    PackageName = $package;
    Url = 'https://github.com/Iristyle/Posh-VsVars/zipball/master';
    UnzipLocation = $moduleDirectory;
  }

  Install-ChocolateyZipPackage @params

  # github tarballs are versioned and we don't want that ;0
  Get-ChildItem -Path $moduleDirectory |
    ? { $_.Name -match 'Posh\-VsVars' } |
    Sort-Object -Property CreationTime -Descending |
    Select -First 1 |
    Rename-Item -NewName $installDirectory

  if (!(Test-Path $PROFILE))
  {
    $profileRoot = Split-Path $PROFILE
    New-Item -Path $profileRoot -Type Directory -ErrorAction SilentlyContinue
    Set-Content -Path $PROFILE -Value '' -Force -Encoding UTF8
  }

  if (!(Select-String -Pattern 'Posh\-VsVars\-Profile\.ps1' -Path $PROFILE))
  {
    $loaderFile = 'Posh-VsVars-Profile.ps1'
    "`n`n# Load Posh-VsVars`n. '$installDirectory\$loaderFile'" |
      Out-File -FilePath $PROFILE -Append -Encoding (Get-FileEncoding $PROFILE)
    . $PROFILE
  }

  Write-Host @'
  Reload the current profile to access Posh-VsVars with:
  . $PROFILE
'@
  Write-ChocolateySuccess $package
}
catch
{
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
