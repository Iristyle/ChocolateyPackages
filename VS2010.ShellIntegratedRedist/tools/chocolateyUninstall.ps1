$package = 'VS2010.ShellIntegratedRedist'

try {

  # FYI - there is also an Isolated redist in addition to an Integrated one
  # http://www.microsoft.com/en-us/download/details.aspx?id=1366
  # http://download.microsoft.com/download/1/9/3/1939AD78-F8E8-4336-83F3-E2470F422C62/VSIsoShell.exe

  # $productGuid = Get-ChildItem HKLM:\SOFTWARE\Classes\Installer\Products |
  #   Get-ItemProperty -Name 'ProductName' |
  #   ? { $_.ProductName -eq 'Microsoft Visual Studio 2010 Shell (Integrated) - ENU' } |
  #   Select -ExpandProperty PSChildName -First 1

  $productGuid = '3C62D210A21EADB3E8ECFD417E125A70'
  $properties = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\$productGuid\InstallProperties

  $pkg = $properties.LocalPackage

  msiexec.exe /x $pkg /qb-!

  Install-ChocolateyPackage @params

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
