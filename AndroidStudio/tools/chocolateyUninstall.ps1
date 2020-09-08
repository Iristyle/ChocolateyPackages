$package = 'AndroidStudio'
$extractionPath = "C:/Google"

try
{
	# Common Functions
	. (Join-Path $(Split-Path -parent $MyInvocation.MyCommand.Definition) 'Common.ps1')

	
	$installDir = Join-Path $extractionPath 'android-studio'

	$studioExe = (gci "${installdir}/bin/studio64.exe").FullName | sort -Descending | Select -first 1

	# Remove Pinned Item if it exist
	Uninstall-ChocolateyPinnedTaskBarItem $studioExe

	# Remove Desktop Lnk if it exist
	$desktop = $([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory))
	$link = Join-Path $desktop "$([System.IO.Path]::GetFileName($studioExe)).lnk"
	$desktop = $([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory))
	$desktopLink = Join-Path $desktop "$link.lnk"
	if (Test-Path ($desktopLink)) {Remove-Item $desktopLink -force}

	# Remove Android Studio Directory
	Remove-Item -Recurse -Force $installDir
	
	# if nothing else is in the $extractionPath besides Android Studio then delete it as well.
	if( (Get-ChildItem $extractionPath | Measure-Object).Count -eq 0)
	{
		Remove-Item -Force $extractionPath
	}

	Write-ChocolateySuccess $package
}
catch
{
	Write-ChocolateyFailure $package "$($_.Exception.Message)"
	throw
}