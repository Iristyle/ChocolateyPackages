$package = 'jdk7'
$build = '18'
$version = '45'

try {
  $IsSytem32Bit = (($Env:PROCESSOR_ARCHITECTURE -eq 'x86') -and `
    ($Env:PROCESSOR_ARCHITEW6432 -eq $null))

  # http://www.oracle.com/technetwork/java/javase/downloads/index.html
  $url = if ($IsSytem32Bit)
    { "http://download.oracle.com/otn-pub/java/jdk/7u$version-b$build/jdk-7u$version-windows-i586.exe" }
  else
    { "http://download.oracle.com/otn-pub/java/jdk/7u$version-b$build/jdk-7u$version-windows-x64.exe" }

  $chocTemp = Join-Path $Env:TEMP 'chocolatey'
  $tempInstall = Join-Path $chocTemp 'jdk7\jdk7installer.exe'

  Write-Host "Downloading from $url"

  # had issues with Invoke-WebRequest working properly
  $client = New-Object Net.WebClient
  $client.Headers.Add('Cookie',
    'gpw_e24=http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html')
  $client.DownloadFile($url, $tempInstall)

  Write-Host "Download from $url complete"

  $params = @{
    PackageName = $package;
    FileType = 'exe';
    # http://docs.oracle.com/javase/7/docs/webnotes/install/windows/jdk-installation-windows.html#Check
    SilentArgs = '/s';
    File = $tempInstall;
  }

  Install-ChocolateyInstallPackage @params

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
