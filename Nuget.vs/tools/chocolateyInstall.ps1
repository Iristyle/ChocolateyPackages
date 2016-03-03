$package = 'NuGet.vs'

$params = @{
  PackageName = $package;
  VsixUrl = 'http://visualstudiogallery.msdn.microsoft.com/27077b70-9dad-4c64-adcf-c7cf6bc9970c/file/37502/30/NuGet.Tools.vsix';
}

$vsKeys = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\VisualStudio' |
		Select -ExpandProperty PsChildName

# VS 2012, VS 2010
'11.0', '10.0' |
  % {
    if ($vsKeys -contains $_)
    {
      Install-ChocolateyVsixPackage @params -VsVersion ($_ -as [int])
    }
  }