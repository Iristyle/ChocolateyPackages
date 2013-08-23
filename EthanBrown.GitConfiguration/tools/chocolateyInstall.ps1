$package = 'EthanBrown.GitConfiguration'

try {
  # Set up git diff/merge tool
  git config --global mergetool.DiffMerge.cmd '\"C:/Program Files/SourceGear/Common/DiffMerge/sgdm.exe\" --merge --result=\"$MERGED\" \"$LOCAL\" \"$BASE\" \"$REMOTE\" --title1=\"Mine\" --title2=\"Merging to: $MERGED\" --title3=\"Theirs\"'
  git config --global mergetool.DiffMerge.trustExitCode true
  git config --global difftool.DiffMerge.cmd '\"C:/Program Files/SourceGear/Common/DiffMerge/sgdm.exe\"  \"$LOCAL\" \"$REMOTE\" --title1=\"Previous Version ($LOCAL)\" --title2=\"Current Version ($REMOTE)\"'

  $defaultMerge = git config --get merge.tool
  if (!$defaultMerge -or ($defaultMerge -match 'kdiff'))
  {
    git config --global merge.tool DiffMerge
  }
  git config --global mergetool.keepBackup false
  git config --global mergetool.prompt false

  $defaultDiff = git config --get diff.tool
  if (!$defaultDiff -or ($defaultDiff -match 'kdiff'))
  {
    git config --global diff.tool DiffMerge
  }
  $defaultDiff = git config --get diff.guitool
  if (!$defaultDiff -or ($defaultDiff -match 'kdiff'))
  {
    git config --global diff.guitool DiffMerge
  }
  git config --global difftool.prompt false

  $defaultPush = git config --get push.default
  if (!$defaultPush)
  {
    git config --global push.default simple
  }

  git config --global core.autocrlf true
  git config --global core.safecrlf false
  $defaultEditor = git config --get core.editor
  if (!$defaultEditor)
  {
    git config --global core.editor "'C:/Program Files (x86)/Notepad++/notepad++.exe' -multiInst -notabbar -nosession -noPlugins"
  }

  git config --global pack.packSizeLimit 2g
  git config --global help.format html
  git config --global rebase.autosquash true

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
