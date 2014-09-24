$package = 'ConEmu'
$version = '140922'

try {

  $isSytem32Bit = (($Env:PROCESSOR_ARCHITECTURE -eq 'x86') -and `
    ($Env:PROCESSOR_ARCHITEW6432 -eq $null))

  $os = if ($isSytem32Bit) { "x86" } else { "x64" }


  # $url = "http://www.fosshub.com/download/ConEmuSetup.$version.exe"
  $url = "http://mirror4.fosshub.com/programs/ConEmuSetup.$version.exe"

  $chocTemp = Join-Path $Env:TEMP 'chocolatey'
  $tempInstall = Join-Path $chocTemp "ConEmu\ConEmuSetup.$version.exe"

  Write-Host "Downloading from $url to $tempInstall"

  # need a Referer, User-Agent and Accept to be able to download
  # other headers not required
  $client = New-Object Net.WebClient
  # Connection: keep-alive
  # DNT: 1
  # $client.Headers.Add('Accept-Encoding', 'gzip,deflate,sdch')
  # $client.Headers.Add('Accept-Language', 'en-US,en;q=0.8')
  $client.Headers.Add('Referer', 'http://www.fosshub.com/ConEmu.html')
  $client.Headers.Add('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8')
  $client.Headers.Add('User-Agent', 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2145.4 Safari/537.36')
  $client.DownloadFile($url, $tempInstall)

  Write-Host "Download from $url complete"

  # If having problems with untrusted cetrificates on HTTPS, use
  # solution: http://stackoverflow.com/a/561242/1579985
  $params = @{
    PackageName = $package;
    FileType = 'exe';
    SilentArgs = "/p:$os /passive";
    # MSI installer, but packed inside wrapper to select x86 or x64
    # version. Therefore, treat it as EXE type.
    File = $tempInstall;
    # ValidExitCodes = @(0);
  }

  Install-ChocolateyInstallPackage @params

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
