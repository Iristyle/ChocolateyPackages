$package = 'EthanBrown.GitAliases'

try {
  # partially inspired by
  # https://git.wiki.kernel.org/index.php/Aliases
  # https://gist.github.com/oli/1637874
  # https://gist.github.com/bradwilson/4215933

  git config --global alias.aliases 'config --get-regexp alias'
  git config --global alias.amend 'commit --amend'
  git config --global alias.bl 'blame -w -M -C'
  git config --global alias.changed 'status -sb'
  git config --global alias.f '!git ls-files | grep -i'
  git config --global alias.hist "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue) [%an]%Creset' --abbrev-commit --date=relative"
  git config --global alias.last 'log -p --max-count=1 --word-diff'
  git config --global alias.pick 'add -p'
  git config --global alias.stage 'add'
  $userName = git config --global --get user.name
  if ($userName)
  {
    git config --global alias.standup "log --since yesterday --oneline --author $userName"
  }
  else
  {
    Write-Warning "Set git global username with git config --global user.name 'foo' to use standup"
  }
  git config --global alias.stats 'diff --stat'
  git config --global alias.sync '! git fetch upstream -v && git fetch origin -v && git checkout master && git merge upstream/master'
  git config --global alias.undo 'reset head~'
  git config --global alias.unstage 'reset HEAD'
  git config --global alias.wdiff 'diff --word-diff'
  git config --global alias.who 'shortlog -s -e --'

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
