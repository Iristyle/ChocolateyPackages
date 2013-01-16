# HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\
$msiId = '{A47FD1BF-A815-4A76-BE65-53A15BD5D25D}'
$msiId64 = '{4701DEDE-1888-49E0-BAE5-857875924CA2}'

$package = 'SQL2008R2.ClrTypes'

try {
  Uninstall-ChocolateyPackage $package 'MSI' -SilentArgs "$msiId /qb" -validExitCodes @(0)
  if ([IntPtr]::Size -eq 8) { Uninstall-ChocolateyPackage $package 'MSI' -SilentArgs "$msiId64 /qb" -validExitCodes @(0) }
  # the following is all part of error handling
  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw 
}
