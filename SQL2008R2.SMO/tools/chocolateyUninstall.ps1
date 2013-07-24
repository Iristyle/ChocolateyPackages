# HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\
$msiId = '{B692E59A-055C-43B7-BE0A-9C2FE0AB88B6}'
$msiId64 = '{F10ADDB9-839B-448B-BD2E-3BCB5C1E4B55}'

$package = 'SQL2008R2.SMO'

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
