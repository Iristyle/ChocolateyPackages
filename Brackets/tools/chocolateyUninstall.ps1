$package = 'Brackets'

try {

  # C:\Program Files (x86)\Brackets Sprint 25
  # http://stackoverflow.com/questions/450027/uninstalling-an-msi-file-from-the-command-line-without-using-msiexec
  msiexec.exe '/X{37DF8424-BAF6-458B-A3F0-2A89D65628B2}' /qb-! REBOOT=ReallySuppress

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
