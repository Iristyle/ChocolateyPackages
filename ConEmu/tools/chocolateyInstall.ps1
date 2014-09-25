$package = 'ConEmu'
$version = '14.09.23'

try {

  $isSytem32Bit = (($Env:PROCESSOR_ARCHITECTURE -eq 'x86') -and `
    ($Env:PROCESSOR_ARCHITEW6432 -eq $null))

  $os = if ($isSytem32Bit) { "x86" } else { "x64" }

  # TODO: use github api to grab latest release?
  $url = "https://github.com/Maximus5/ConEmu/releases/download/v$version/ConEmuSetup.$($version.replace('.','')).exe"

  $chocTemp = Join-Path $Env:TEMP 'chocolatey'
  $tempInstall = Join-Path $chocTemp "ConEmu\ConEmuSetup.$version.exe"

  Write-Host "Downloading from $url to $tempInstall"

  # need a Referer, User-Agent and Accept to be able to download
  # other headers not required
  $client = New-Object Net.WebClient
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
