$package = 'MultiPar'
$version = '1.2.3.3'
$downloadVersion = '123'

try {
  $params = @{
    packageName = $package;
    fileType = 'exe';
    #InnoSetup - http://unattended.sourceforge.net/InnoSetup_Switches_ExitCodes.html
    silentArgs = '/silent', '/verysilent', '/sp-', '/suppressmsgboxes';
    url = "http://ftp.vector.co.jp/pack/winnt/util/disk/care/MultiPar$($downloadVersion)_setup.exe";
  }

  Install-ChocolateyPackage @params

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}

