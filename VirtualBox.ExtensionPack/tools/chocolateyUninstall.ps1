$package = 'VirtualBox.ExtensionPack'
$vboxName = 'Oracle VM VirtualBox Extension Pack'

# Refresh the PS session environment so that if VirtualBox was just installed in this session, it will be found in PATH
Update-SessionEnvironment

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
  throw 'Could not find VirtualBox VBoxManage.exe necessary to uninstall extension pack'
}

# Uninstall the Extension Pack using VBoxManage
$vboxout = & $vBoxManage extpack uninstall `"$vboxName`" 2>&1
if ($LASTEXITCODE -ne 0)
{
  throw "An error occurrred with VirtualBox VBoxManage.exe uninstall command: $vboxout"
}
else
{
  Write-Output "$vboxout"
}
