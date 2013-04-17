try {
  $package = 'xUnit.vs2012'

  $params = @{
    PackageName = $package;
    VsixUrl = 'http://visualstudiogallery.msdn.microsoft.com/463c5987-f82b-46c8-a97e-b1cde42b9099/file/66837/8/xunit.runner.visualstudio.vsix';
    VsVersion = 11; # VS 2012
  }

  Install-ChocolateyVsixPackage @params

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
