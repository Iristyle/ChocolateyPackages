function Get-CurrentDirectory
{
  $thisName = $MyInvocation.MyCommand.Name
  [IO.Path]::GetDirectoryName((Get-Content function:$thisName).File)
}

try {
  $package = 'SourceCodePro'

  $fontHelpersPath = (Join-Path (Get-CurrentDirectory) 'FontHelpers.ps1')
   . $fontHelpersPath

  $fontUrl = 'https://github.com/adobe-fonts/source-code-pro/archive/1.017R.zip'
  $destination = Join-Path $Env:Temp 'SourceCodePro'

  Install-ChocolateyZipPackage -url $fontUrl -unzipLocation $destination

  $shell = New-Object -ComObject Shell.Application
  $fontsFolder = $shell.Namespace(0x14)

  $fontFiles = Get-ChildItem $destination -Recurse -Filter *.otf

  # unfortunately the font install process totally ignores shell flags :(
  # http://social.technet.microsoft.com/Forums/en-IE/winserverpowershell/thread/fcc98ba5-6ce4-466b-a927-bb2cc3851b59
  # so resort to a nasty hack of compiling some C#, and running as admin instead of just using CopyHere(file, options)
  $commands = $fontFiles |
    % { Join-Path $fontsFolder.Self.Path $_.Name } |
    ? { Test-Path $_ } |
    % { "Remove-SingleFont '$_' -Force;" }

  # http://blogs.technet.com/b/deploymentguys/archive/2010/12/04/adding-and-removing-fonts-with-windows-powershell.aspx
  $fontFiles |
    % { $commands += "Add-SingleFont '$($_.FullName)';" }

  $toExecute = ". $fontHelpersPath;" + ($commands -join ';')
  Start-ChocolateyProcessAsAdmin $toExecute

  Remove-Item $destination -Recurse

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
