$package = 'Erlang'
$version = 'R16B01'

try {
  $params = @{
    PackageName = $package;
    FileType = 'exe';
    #uses NSIS installer - http://nsis.sourceforge.net/Docs/Chapter3.html
    SilentArgs = '/S';
    Url = "http://www.erlang.org/download/otp_win32_$($version).exe";
    Url64Bit = "http://www.erlang.org/download/otp_win64_$($version).exe";
  }

  Install-ChocolateyPackage @params

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}

