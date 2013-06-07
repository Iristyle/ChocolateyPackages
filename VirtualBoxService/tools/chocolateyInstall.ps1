$package = 'VirtualBoxService'

try {
  function Which([string]$cmd)
  {
    Get-Command -ErrorAction "SilentlyContinue" $cmd |
      Select -ExpandProperty Definition
  }

  $binRoot = $Env:SystemDrive

  if ($Env:Chocolatey_Bin_Root)
  {
    $binRoot = Join-Path $Env:SystemDrive $Env:Chocolatey_Bin_Root
  }

  $params = @{
    PackageName = $package;
    Url = 'http://virtualboxservice.googlecode.com/files/VirtualBoxService-v0.1.zip';
    UnzipLocation = Join-Path $binRoot $package
    #UnzipLocation = Join-Path $Env:ProgramFiles $package
  }

  Install-ChocolateyZipPackage @params

  $installUtil = "$Env:windir\Microsoft.NET\Framework\v2.0.50727\InstallUtil.exe"
  $path = "$params.UnzipLocation\VirtualBoxService.exe"
  &$installUtil $path


  # Welcome to VirtualboxService-Installer!
  # 1 How to use
  # Use the buttons to the right, to install or uninstall the service. Once the service is installed the “Virtualboxservice.exe” and its depending library-DLLs must stay at the current location. After the “Install Service”-button was pressed, a dialog appears, which asks you to enter the logon-information for the user, the service should run as. The virtualmachine-registry of this user is used.
  # Copy the following VirtualboxService-Magic-Tag into the description of the machines you would like to be run by the service:

  # <!VirtualboxService--{"Autostart":"true", "ShutdownType":"ACPIShutdown", "ACPIShutdownTimeout": "300000"}--/VirtualboxService>

  # Autostart:
  # Possible values: “true” or “false”.
  # Determines, if machine should be started by service on host-boot and shutdown on host-shutdown.
  # ShutdownType:
  # Possible values: “SaveState”, “ACPIShutdown”, “HardOff”
  # · SaveState: Machine-State is saved on host-shutdown
  # · ACPIShutdown: ACPI-Shutdown-Command is sent to the Machine on host-shutdown.
  # · HardOff: Machine is turned off on host-shutdown.
  # All shutdown-types will delay the host-shutdown as long as needed to properly shutdown all machines. This works reliably on Windows Vista SP1 and greater. On XP the delay is dependent on the setting of “WaitToKillService”-Registry-Entry (default: 20 Seconds).
  # ACPIShutdownTimeout: Specifies the timeout for the acpi-shutdown-type (in milliseconds).

  # 2 License
  # Copyright 2011 Felix Rüttiger.
  # This software is distributed under the GPLv3-License.

  # This program is free software: you can redistribute it and/or modify
  # it under the terms of the GNU General Public License as published by
  # the Free Software Foundation, either version 3 of the License, or
  # (at your option) any later version.

  # This program is distributed in the hope that it will be useful,
  # but WITHOUT ANY WARRANTY; without even the implied warranty of
  # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  # GNU General Public License for more details.


#   # some files are copied to c:\windows\system32
#   $installVirtualBoxServiceScript = @"
#   Push-Location '$sitePackages'
#   &'$localPython' VirtualBoxService_postinstall.py `-install
#   Remove-Item .\VirtualBoxService_postinstall.py
# "@

#   Start-ChocolateyProcessAsAdmin $installVirtualBoxServiceScript

#   $VirtualBoxServiceTemp, $destination |
#     Remove-Item -Recurse -ErrorAction SilentlyContinue

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
