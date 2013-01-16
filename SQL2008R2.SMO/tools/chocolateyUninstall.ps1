# HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\
$msiId = '{B692E59A-055C-43B7-BE0A-9C2FE0AB88B6}'
$msiId64 = '{F10ADDB9-839B-448B-BD2E-3BCB5C1E4B55}'

$package = 'SQL2008R2.SMO'

try {
  Uninstall-ChocolateyPackage $package 'MSI' -SilentArgs "$msiId /qb" -validExitCodes @(0)
  if ([IntPtr]::Size -eq 8) { Uninstall-ChocolateyPackage $package 'MSI' -SilentArgs "$msiId64 /qb" -validExitCodes @(0) }
  # the following is all part of error handling
  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw 
}
