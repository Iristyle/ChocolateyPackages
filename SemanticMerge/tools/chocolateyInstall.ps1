$package = 'SemanticMerge'

try {
  $params = @{
    packageName = $package;
    fileType = 'exe';
    # BitRock Install Builder
    # http://installbuilder.bitrock.com/docs/installbuilder-userguide/ar01s10.html
    silentArgs = '--unattendedmodeui none', '--mode unattended';
    url = 'http://www.semanticmerge.com/users/download'
  }

  Install-ChocolateyPackage @params

  Write-Host @'
For instructions for use with configuration as a Git merge tool, please see:

http://rlbisbe.wordpress.com/2013/04/15/semantic-merge-as-the-default-merge-tool-with-git-on-windows/
'@
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
