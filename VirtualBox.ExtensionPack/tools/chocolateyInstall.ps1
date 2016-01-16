$package = 'VirtualBox.ExtensionPack'
$version = '5.0.12'
$build = '104815'
$packName = "Oracle_VM_VirtualBox_Extension_Pack-$version-$build.vbox-extpack"
$packUrl = "http://download.virtualbox.org/virtualbox/$version/$packName"

# Find the VirtualBox install directory to find where VBoxManage.exe is located
# First, we check the VBOX_MSI_INSTALL_PATH ENV variable,
# Next, we check the PATH ENV variable,
# Finally, we check the PROGRAMFILES(x86)\Oracle\VirtualBox\ & then the PROGRAMFILES\Oracle\VirtualBox\ directories
$vboxManageFile = "VBoxManage.exe"
$vboxSubdir = "\Oracle\VirtualBox\"
$progFilesLoc = if (${ENV:PROGRAMFILES}) { [IO.Path]::Combine(${ENV:PROGRAMFILES}, $vboxSubdir) } else { "" }
$progFilesX86Loc = if (${ENV:PROGRAMFILES(x86)}) { [IO.Path]::Combine(${ENV:PROGRAMFILES(x86)}, $vboxSubdir) } else { "" }
$allPaths = "${ENV:VBOX_MSI_INSTALL_PATH};${ENV:PATH};$progFilesX86Loc;$progFilesLoc"

$vboxManage = $allpaths.Split(";") |
  Where-Object { $_ } |
  ForEach-Object {
    [IO.Path]::Combine([System.Environment]::ExpandEnvironmentVariables($_), $vboxManageFile)
  } |
  Where-Object { Test-Path $_ } |
  Select-Object -First 1

if (!$vboxManage)
{
  throw 'Could not find VirtualBox VBoxManage.exe to install extension pack with'
}

# Get the name of the Extension Pack file from the end of the download URL
$fileName = $packUrl -split '/' | Select-Object -Last 1
# Find or create the temp directory where the Extension Pack will be downloaded
$appTemp = [IO.Path]::Combine($Env:Temp, $package)
if (!(Test-Path $appTemp))
{
  New-Item $appTemp -Type Directory
}
$packageTemp = [IO.Path]::Combine($appTemp, $fileName)

# Download the Extension Pack
Get-ChocolateyWebFile -packageName $package -fileFullPath $packageTemp -url $packUrl

# Install the Extension Pack using VBoxManage
$vboxout = & $vboxManage extpack install --replace $packageTemp 2>&1
if ($LASTEXITCODE -ne 0)
{
  throw "An error occurrred with VirtualBox VBoxManage.exe install command: $vboxout"
}
else
{
  Write-Output "$vboxout"
}
