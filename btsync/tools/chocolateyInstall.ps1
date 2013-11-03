$packageName = 'BitTorrent Sync'
$installerType = 'exe'
$url = 'http://download-lb.utorrent.com/endpoint/btsync/os/windows/track/stable'
#$url64 = $url No 64-bit version available
$silentArgs = '/PERFORMINSTALL /AUTOMATION'
$validExitCodes = @(0,1) # Returns 1 after a successful automated install, naturally

Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" -validExitCodes $validExitCodes