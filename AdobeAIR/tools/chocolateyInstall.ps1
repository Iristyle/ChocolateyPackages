$packageName = '{{PackageName}}'
$installerType = 'EXE'
#$url = 'http://airdownload.adobe.com/air/win/download/{version}/AdobeAIRInstaller.exe'		#it isn't used the version variable
$url = '{{DownloadUrl}}'
$silentArgs = '-silent -eulaAccepted'
$validExitCodes = @(0) #please insert other valid exit codes here, exit codes for ms http://msdn.microsoft.com/en-us/library/aa368542(VS.85).aspx

Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url"  -validExitCodes $validExitCodes
