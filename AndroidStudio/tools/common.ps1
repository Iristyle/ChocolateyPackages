Function GetArguments ([string]$packageArgs)
{
	$arguments = @{};

    # Default the values
    $pinnedtotaskbar = "true";
    $addtodesktop = "true";


    # Now, let’s parse the packageParameters using good old regular expression
    $MATCH_PATTERN = "/([a-zA-Z]+):([`"'])?([a-zA-Z0-9- _]+)([`"'])?"
    $PARAMATER_NAME_INDEX = 1
    $VALUE_INDEX = 3

    if($packageArgs -match $MATCH_PATTERN ){
        $results = $packageArgs | Select-String $MATCH_PATTERN -AllMatches 
        $results.matches | % { 
            $arguments.Add(
                $_.Groups[$PARAMATER_NAME_INDEX].Value.Trim().ToLower(),
                $_.Groups[$VALUE_INDEX].Value.Trim()) 
        }
    }     

    if($arguments.ContainsKey("pinnedtotaskbar")) {
        $pinnedtotaskbar = $arguments["pinnedtotaskbar"];
    }  

    if($arguments.ContainsKey("addtodesktop")) {
        $addtodesktop = $arguments["addtodesktop"];
    }

    New-Object PSObject -Property $arguments
}

function Uninstall-ChocolateyPinnedTaskBarItem {
<#
.SYNOPSIS
Removes an item from the task bar linking to the provided path.

.PARAMETER TargetFilePath
The path to the application that should be launched when clicking on the task bar icon.

.EXAMPLE
Uninstall-ChocolateyPinnedTaskBarItem "${env:ProgramFiles(x86)}\Microsoft Visual Studio 11.0\Common7\IDE\devenv.exe"

This will remove the Visual Studio task bar icon.

#>
param(
  [string] $targetFilePath
)

  Write-Debug "Running 'Uninstall-ChocolateyPinnedTaskBarItem' with targetFilePath:`'$targetFilePath`'";

  if (test-path($targetFilePath)) {
    $verb = "Unpin from Taskbar"
    $path= split-path $targetFilePath 
    $shell=new-object -com "Shell.Application"  
    $folder=$shell.Namespace($path)    
    $item = $folder.Parsename((split-path $targetFilePath -leaf)) 
    $itemVerb = $item.Verbs() | ? {$_.Name.Replace("&","") -eq $verb} 
    if($itemVerb -eq $null){ 
      Write-Host "TaskBar verb not found for $item. It may have already been unpinned"
    } else { 
        $itemVerb.DoIt() 
    } 
    Write-Host "`'$targetFilePath`' has been unpinned from the task bar on your desktop"
  } else {
    $errorMessage = "`'$targetFilePath`' does not exist, not able to unpin from task bar"
  }
  if($errorMessage){
    Write-Error $errorMessage
    throw $errorMessage
  }
}