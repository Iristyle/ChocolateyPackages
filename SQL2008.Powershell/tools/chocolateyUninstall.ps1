# HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\
$msiId = '{4033FB91-32C7-440D-B4A3-B76D47190233}'
$msiId64 = '{A2D06441-583D-4D37-9A9A-E4AE1663A81E}'

$package = 'SQL2008.PowerShell'

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
