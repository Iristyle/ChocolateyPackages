$package = 'Posh-GitHub'
$version = '0.0.1'

function Get-CurrentDirectory
{
  $thisName = $MyInvocation.MyCommand.Name
  [IO.Path]::GetDirectoryName((Get-Content function:$thisName).File)
}

try {
  $current = Get-CurrentDirectory
  . (Join-Path $current 'PowerShellHelpers.ps1')
  . (Join-Path $current 'EncodingHelpers.ps1')

  # find user specific module directory
  $moduleDirectory = Get-ModuleDirectory
  $installDirectory = Join-Path $moduleDirectory $package

  # unload module if its already loaded
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
    Url = "https://github.com/Iristyle/Posh-GitHub/zipball/$version";
    UnzipLocation = $moduleDirectory;
  }

  Install-ChocolateyZipPackage @params

  # github tarballs are versioned and we don't want that ;0
  Get-ChildItem -Path $moduleDirectory |
    ? { $_.Name -match 'Posh\-GitHub' } |
    Sort-Object -Property CreationTime -Descending |
    Select -First 1 |
    Rename-Item -NewName $installDirectory

  if (!(Test-Path $PROFILE))
  {
    $profileRoot = Split-Path $PROFILE
    New-Item -Path $profileRoot -Type Directory -ErrorAction SilentlyContinue
    Set-Content -Path $PROFILE -Value '' -Force -Encoding UTF8
  }

  if (!(Select-String -Pattern 'Posh\-GitHub\-Profile\.ps1' -Path $PROFILE))
  {
    $loaderFile = 'Posh-GitHub-Profile.ps1'
    "`n`n# Load Posh-GitHub`n. '$installDirectory\$loaderFile'" |
      Out-File -FilePath $PROFILE -Append -Encoding (Get-FileEncoding $PROFILE)
    . $PROFILE

    Write-Host -ForegroundColor DarkMagenta @'
    Reload the current profile to access Posh-Github with:
    . $PROFILE
'@
  }

  Write-ChocolateySuccess $package
}
catch
{
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
