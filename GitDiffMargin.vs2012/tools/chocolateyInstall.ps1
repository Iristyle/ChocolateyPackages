try {
  $package = 'GitDiffMargin.vs2012'

  $params = @{
    PackageName = $package;
    VsixUrl = 'http://visualstudiogallery.msdn.microsoft.com/cf49cf30-2ca6-4ea0-b7cc-6a8e0dadc1a8/file/101267/1/GitDiffMargin.vsix';
    VsVersion = 11; # VS 2012
  }

  Install-ChocolateyVsixPackage @params

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
