$package = 'OpenSSL.Light'

try {

  #default is to plop in c:\ -- yuck!
  $installDir = Join-Path $Env:ProgramFiles 'OpenSSL'

  $params = @{
    packageName = $package;
    fileType = 'exe';
    #InnoSetup - http://unattended.sourceforge.net/InnoSetup_Switches_ExitCodes.html
    silentArgs = '/silent', '/verysilent', '/sp-', '/suppressmsgboxes',
      "/DIR=`"$installDir`"";
    url = 'http://slproweb.com/download/Win32OpenSSL_Light-1_0_1c.exe'
    url64bit = 'http://slproweb.com/download/Win64OpenSSL_Light-1_0_1c.exe'
  }

  Install-ChocolateyPackage @params

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
