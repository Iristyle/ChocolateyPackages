try {
  $package = 'NuGet.vs'

  $versions = @(
    @{ 
      PackageName=$package
      VsVersion='12'
      VsixUrl ='http://visualstudiogallery.msdn.microsoft.com/4ec1526c-4a8c-4a84-b702-b21a8f5293ca/file/105933/1/NuGet.Tools.2013.vsix'
    },
    @{
      PackageName=$package
      VsVersion='11'
      VsixUrl ='http://visualstudiogallery.msdn.microsoft.com/27077b70-9dad-4c64-adcf-c7cf6bc9970c/file/37502/32/NuGet.Tools.vsix'
    },
    @{
      PackageName=$package
      VsVersion='10'
      VsixUrl ='http://visualstudiogallery.msdn.microsoft.com/27077b70-9dad-4c64-adcf-c7cf6bc9970c/file/37502/32/NuGet.Tools.vsix'
    }
  )

  $vsKeys = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\VisualStudio' |
    Select -ExpandProperty PsChildName

  # VS 2012, VS 2010
  $versions |
    % {
      if ($vsKeys -contains $("{0}.0" -f $_.VsVersion))
      {
        Install-ChocolateyVsixPackage @_
      }
    }

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
