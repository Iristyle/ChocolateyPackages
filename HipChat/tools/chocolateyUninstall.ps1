$package = 'HipChat'

try {

  # http://stackoverflow.com/questions/450027/uninstalling-an-msi-file-from-the-command-line-without-using-msiexec
  $msiArgs = "/X{56B4BFF9-4967-4A84-A5B0-4B49AB070100} /qb-! REBOOT=ReallySuppress"
  Start-ChocolateyProcessAsAdmin "$msiArgs" 'msiexec'

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
