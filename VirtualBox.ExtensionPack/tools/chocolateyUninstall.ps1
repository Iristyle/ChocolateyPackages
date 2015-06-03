$package = 'VirtualBox.ExtensionPack'
$vboxName = 'Oracle VM VirtualBox Extension Pack'

# simulate the unix command for finding things in path
# http://stackoverflow.com/questions/63805/equivalent-of-nix-which-command-in-powershell
function Which([string]$cmd)
{
  Get-Command -ErrorAction "SilentlyContinue" $cmd |
    Select -ExpandProperty Definition
}

function Uninstall-ExtensionPack([string] $name)
{
  $vboxManageDefault = Join-Path $Env:ProgramFiles 'Oracle\VirtualBox\VBoxManage.exe'

  $vboxManage = (Which VBoxManage),
    $vboxManageDefault |
    ? { Test-Path $_ } |
    Select -First 1

  if (!$vboxManage)
  {
    throw 'Could not find VirtualBox VBoxManage.exe necessary to uninstall extension pack'
  }

  $vboxout = & $vBoxManage extpack uninstall `"$name`" 2>&1
  if ($LASTEXITCODE -ne 0)
  {
    throw "An error occurrred with VirtualBox VBoxManage.exe uninstall command: $vboxout"
  }
  else
  {
    Write-Output "$vboxout"
  }
}

Uninstall-ExtensionPack $vboxName
