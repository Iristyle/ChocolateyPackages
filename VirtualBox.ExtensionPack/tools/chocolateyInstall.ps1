$package = 'VirtualBox.ExtensionPack'
$version = '5.0.0'
$build = '101573'
$packName = "Oracle_VM_VirtualBox_Extension_Pack-$version-$build.vbox-extpack"
$packUrl = "http://download.virtualbox.org/virtualbox/$version/$packName"

$vboxManageDefault = Join-Path $Env:ProgramFiles 'Oracle\VirtualBox\VBoxManage.exe'

# simulate the unix command for finding things in path
# http://stackoverflow.com/questions/63805/equivalent-of-nix-which-command-in-powershell
$vboxManage = (Get-Command -ErrorAction "SilentlyContinue" VBoxManage |
  Select -ExpandProperty Definition),
  $vboxManageDefault |
  ? { $_ -and { Test-Path $_ } } |
  Select -First 1

if (!$vboxManage)
{
  throw 'Could not find VirtualBox VBoxManage.exe to install extension pack with'
}

$fileName = $packUrl -split '/' | Select -Last 1
$appTemp = Join-Path $Env:Temp $package
if (!(Test-Path $appTemp))
{
  New-Item $appTemp -Type Directory
}
$packageTemp = Join-Path $appTemp $fileName
Get-ChocolateyWebFile -packageName $package -fileFullPath $packageTemp -url $packUrl

$vboxout = & $vboxManage extpack install --replace $packageTemp 2>&1
if ($LASTEXITCODE -ne 0)
{
  throw "An error occurrred with VirtualBox VBoxManage.exe install command: $vboxout"
}
else
{
  Write-Output "$vboxout"
}
