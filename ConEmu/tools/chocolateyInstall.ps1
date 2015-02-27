$package = 'ConEmu'
$version = '15.02.24a'

try {

  $isSytem32Bit = (($Env:PROCESSOR_ARCHITECTURE -eq 'x86') -and `
    ($Env:PROCESSOR_ARCHITEW6432 -eq $null))

  $os = if ($isSytem32Bit) { "x86" } else { "x64" }

  # TODO: use github api to grab latest release?
  $url = "https://github.com/Maximus5/ConEmu/releases/download/v$version/ConEmuSetup.$($version.replace('.','')).exe"

  echo $url

  $params = @{
    PackageName = $package;
    FileType = 'exe';
    SilentArgs = "/p:$os /passive";
    Url = $url;
    Url64Bit = $url;
  }

  Install-ChocolateyPackage @params
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
