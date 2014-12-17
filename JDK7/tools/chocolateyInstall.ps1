$script_path = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$common = $(Join-Path $script_path "common.ps1")
. $common

$package = 'jdk7'
$build = '14'
$version = '72'

try {
    $params = "$env:chocolateyPackageParameters" # -params '"x64=false;path=c:\\java\\jdk"'
    $params = (ConvertFrom-StringData $params.Replace(";", "`n")) 
    
    chocolatey-install  
} catch {
    if ($_.Exception.InnerException) {
        $msg = $_.Exception.InnerException.Message
    } else {
        $msg = $_.Exception.Message
    }
    
    Write-ChocolateyFailure $package "$msg"
    throw 
}  

#          $client.Headers.Add('Cookie', 'gpw_e24=http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html;');
#          $client.Headers.Add('Cookie', 'oraclelicense=accept-securebackup-cookie');
#  Install-ChocolateyEnvironmentVariable "JAVA_HOME" "C:\Program Files\Java\jdk1.7.0_72\bin" 'Machine'


  Install-ChocolateyInstallPackage @params

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
