$package = 'ConEmu'

try {

  # $productGuid = Get-ChildItem HKLM:\SOFTWARE\Classes\Installer\Products |
  #   Get-ItemProperty -Name 'ProductName' |
  #   ? { $_.ProductName -match 'ConEmu' } |
  #   Select -ExpandProperty PSChildName -First 1

  $installerRoot = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer'
  $productsRoot = "$installerRoot\UserData\S-1-5-18\Products"

  # x64, x86
  '1616F7E78FA09834EAA6E0617006EEC7', '8ADD8A72FEF29D044884864D191B15B0', 'B0790B48745EDCE4F9918AE6829BC1F4' |
    % { "$productsRoot\$_\InstallProperties" } |
    ? { Test-Path $_ } |
    % {
      $pkg = (Get-ItemProperty $_).LocalPackage

      msiexec.exe /x $pkg /qb-!
    }

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
