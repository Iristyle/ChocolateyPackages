# HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\
$msiId = ' {4AB6A079-178B-4144-B21F-4D1AE71666A2}'
$msiId64 = '{2180B33F-3225-423E-BBC1-7798CFD3CD1F}'

$package = 'SQL2008R2.NativeClient'

$IsSystem32Bit = (($Env:PROCESSOR_ARCHITECTURE -eq 'x86') -and ($Env:PROCESSOR_ARCHITEW6432 -eq $null))

try {

  $uninstallParams = @{
    PackageName = $package;
    FileType = 'MSI';
    SilentArgs = "$msiId /qb";
    ValidExitCodes = @(0)
  }

  if ($IsSystem32Bit) { $uninstallParams.SilentArgs = "$msiId64 /qb" }

  Uninstall-ChocolateyPackage

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
