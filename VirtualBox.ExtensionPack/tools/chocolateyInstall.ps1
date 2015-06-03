$package = 'VirtualBox.ExtensionPack'
$version = '4.3.16'
$build = '95972'
$packName = "Oracle_VM_VirtualBox_Extension_Pack-$version-$build.vbox-extpack"
$packUrl = "http://download.virtualbox.org/virtualbox/$version/$packName"

# simulate the unix command for finding things in path
# http://stackoverflow.com/questions/63805/equivalent-of-nix-which-command-in-powershell
function Which([string]$cmd)
{
  Get-Command -ErrorAction "SilentlyContinue" $cmd |
    Select -ExpandProperty Definition
}

function Install-ExtensionPack([string] $url)
{
  $vboxManageDefault = Join-Path $Env:ProgramFiles 'Oracle\VirtualBox\VBoxManage.exe'

  $vboxManage = (Which VBoxManage),
    $vboxManageDefault |
    ? { $_ -and { Test-Path $_ } } |
    Select -First 1

  if (!$vboxManage)
  {
    throw 'Could not find VirtualBox VBoxManage.exe to install extension pack with'
  }

  $fileName = $url -split '/' | Select -Last 1
  $appTemp = Join-Path $Env:Temp $package
  if (!(Test-Path $appTemp))
  {
    New-Item $appTemp -Type Directory
  }
  $packageTemp = Join-Path $appTemp $fileName
  Get-ChocolateyWebFile -packageName $package -fileFullPath $packageTemp -url $url

  Push-Location $appTemp
  $vboxout = & $vboxManage extpack install --replace $packName 2>&1
  if ($LASTEXITCODE -ne 0)
  {
    throw "An error occurrred with VirtualBox VBoxManage.exe install command: $vboxout"
  }
  else
  {
    Write-Output "$vboxout"
  }
  Pop-Location
}

Install-ExtensionPack $packUrl
