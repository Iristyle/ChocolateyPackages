# HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\
$msiId = ' {4AB6A079-178B-4144-B21F-4D1AE71666A2}'
$msiId64 = '{2180B33F-3225-423E-BBC1-7798CFD3CD1F}'

$package = 'SQL2008R2.NativeClient'

try {
  
  if ([IntPtr]::Size -eq 8) { Uninstall-ChocolateyPackage $package 'MSI' -SilentArgs "$msiId64 /qb" -validExitCodes @(0) }
  else { Uninstall-ChocolateyPackage $package 'MSI' -SilentArgs "$msiId /qb" -validExitCodes @(0) }
  # the following is all part of error handling
  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw 
}
