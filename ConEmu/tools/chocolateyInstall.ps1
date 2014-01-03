$package = 'ConEmu'
$version = '131225'

try {

  $isSytem32Bit = (($Env:PROCESSOR_ARCHITECTURE -eq 'x86') -and `
    ($Env:PROCESSOR_ARCHITEW6432 -eq $null))

  $os = if ($isSytem32Bit) { "x86" } else { "x64" }

  # If having problems with untrusted cetrificates on HTTPS, use
  # solution: http://stackoverflow.com/a/561242/1579985
  $params = @{
    PackageName = $package;
    FileType = 'exe';
    SilentArgs = "/p:$os /passive";
    # MSI installer, but packed inside wrapper to select x86 or x64
    # version. Therefore, treat it as EXE type.
    Url = "https://conemu-maximus5.googlecode.com/files/ConEmuSetup.$version.exe";
    ValidExitCodes = @(0);
  }

  Install-ChocolateyPackage @params

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
