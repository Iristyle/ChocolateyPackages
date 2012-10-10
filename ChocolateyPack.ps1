param(
  [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
  [string]
  $apiKey,

  [Parameter(Mandatory = $false, Position=0)]
  [string]
  [ValidateSet('Push','Pack')]
  $operation = 'Push',

  [Parameter(Mandatory = $false, Position=1)]
  [string]
  $source = 'http://chocolatey.org'
)

function Get-CurrentDirectory
{
  $thisName = $MyInvocation.MyCommand.Name
  [IO.Path]::GetDirectoryName((Get-Content function:$thisName).File)
}

function Get-NugetPath
{
  Write-Host 'Executing Get-NugetPath'
  Get-ChildItem -Path (Get-CurrentDirectory) -Include 'nuget.exe' -Recurse |
    Select -ExpandProperty FullName -First 1
}

function Restore-Nuget
{
  Write-Host 'Executing Restore-Nuget'
  $nuget = Get-NugetPath

  if ($nuget -ne $null)
  {
      &"$nuget" update -Self | Write-Host
      return $nuget
  }

  $nugetPath = Join-Path (Get-CurrentDirectory) 'nuget.exe'
  (New-Object Net.WebClient).DownloadFile('http://nuget.org/NuGet.exe', $nugetPath)

  return Get-NugetPath
}

function Invoke-Pack
{
  $currentDirectory = Get-CurrentDirectory
  Write-Host "Running against $currentDirectory"


  Get-ChildItem -Path $currentDirectory -Filter *.nuspec -Recurse |
    % {
      $csproj = Join-Path $_.DirectoryName ($_.BaseName + '.csproj')
      if (Test-Path $csproj)
      {
        &$script:nuget pack "$csproj" -Prop Configuration=Release -Exclude '**\*.CodeAnalysisLog.xml'
      }
      else
        { &$script:nuget pack $_.FullName }
    }
}

function Invoke-Push
{
 Get-ChildItem *.nupkg |
   % {
     Write-Host "Value of source -> $source"
     if ($source -eq '') { &$script:nuget push $_ $apiKey }
     else { &$script:nuget push $_ $apiKey -source $source }
   }
}

$script:nuget = Restore-Nuget
del *.nupkg
Invoke-Pack
if ($operation -eq 'Push') { Invoke-Push }
del *.nupkg
