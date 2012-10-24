$package = 'HipChat'

try {

  $hipChatGuid = Get-ChildItem HKLM:\SOFTWARE\Classes\Installer\Products |
    Get-ItemProperty -Name 'ProductName' |
    ? { $_.ProductName -eq 'HipChat' } |
    Select -ExpandProperty PSChildName -First 1

  $properties = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\$hipChatGuid\InstallProperties

  $pkg = $properties.LocalPackage

  # http://help.adobe.com/en_US/air/redist/WS485a42d56cd19641-70d979a8124ef20a34b-8000.html#WS485a42d56cd19641-70d979a8124ef20a34b-7ffa
  msiexec.exe /x $pkg /qb-! REBOOT=ReallySuppress

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
