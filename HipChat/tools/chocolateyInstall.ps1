$package = 'HipChat'

try {

  $hipParams = @{
    PackageName = $package;
    FileType = 'msi';
    SilentArgs = '/qn';
    Url = 'https://www.hipchat.com/downloads/latest/qtwindows'
  }
    
  Install-ChocolateyPackage @hipParams
 
  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
