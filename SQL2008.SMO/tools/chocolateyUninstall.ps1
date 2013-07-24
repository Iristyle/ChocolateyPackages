# HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\
$msiId = '{2BF67B4B-7C5E-4045-8766-BB44838DC61A}'
$msiId64 = '{08ECC740-2B3E-45D7-860C-59B511386286}'

$package = 'SQL2008.SMO'

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
