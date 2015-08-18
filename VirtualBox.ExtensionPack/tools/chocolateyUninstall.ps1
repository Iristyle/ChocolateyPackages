$package = 'VirtualBox.ExtensionPack'
$vboxName = 'Oracle VM VirtualBox Extension Pack'

$vboxManageDefault = Join-Path $Env:ProgramFiles 'Oracle\VirtualBox\VBoxManage.exe'

# simulate the unix command for finding things in path
# http://stackoverflow.com/questions/63805/equivalent-of-nix-which-command-in-powershell
$vboxManage = (Get-Command -ErrorAction "SilentlyContinue" VBoxManage |
    Select -ExpandProperty Definition),
  $vboxManageDefault |
  ? { Test-Path $_ } |
  Select -First 1

if (!$vboxManage)
{
  throw 'Could not find VirtualBox VBoxManage.exe necessary to uninstall extension pack'
}

$vboxout = & $vBoxManage extpack uninstall `"$vboxName`" 2>&1
if ($LASTEXITCODE -ne 0)
{
  throw "An error occurrred with VirtualBox VBoxManage.exe uninstall command: $vboxout"
}
else
{
  Write-Output "$vboxout"
}
