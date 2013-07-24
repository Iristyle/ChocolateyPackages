# HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\
$msiId = '{A47FD1BF-A815-4A76-BE65-53A15BD5D25D}'
$msiId64 = '{4701DEDE-1888-49E0-BAE5-857875924CA2}'

$package = 'SQL2008R2.ClrTypes'

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
