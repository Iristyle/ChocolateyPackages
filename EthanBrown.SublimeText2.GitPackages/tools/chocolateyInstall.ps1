$package = 'EthanBrown.SublimeText2.GitPackages'

function Get-CurrentDirectory
{
  $thisName = $MyInvocation.MyCommand.Name
  [IO.Path]::GetDirectoryName((Get-Content function:$thisName).File)
}

try {
  $current = Get-CurrentDirectory

  . (Join-Path $current 'JsonHelpers.ps1')
  . (Join-Path $current 'SublimeHelpers.ps1')

  $sublimeUserDataPath = Get-SublimeUserPath

  #straight file copies
  'Git Commit Message.sublime-settings',
  'GitHub.sublime-settings',
  'SideBarGit.sublime-settings' |
    % {
      $params = @{
        Path = Join-Path $current $_;
        Destination = Join-Path $sublimeUserDataPath $_;
        Force = $true
      }
      Copy-Item @params
    }

  $packageCache = Join-Path (Get-CurrentDirectory) 'PackageCache'
  Install-SublimePackagesFromCache -Directory $packageCache
  Install-SublimePackageControl
  $packageControl = Join-Path $current 'Package Control.sublime-settings'
  Merge-PackageControlSettings -FilePath $packageControl

  $preferences = Join-Path $current 'Preferences.sublime-settings'
  Merge-Preferences -FilePath $preferences

  if (Get-Process -Name sublime_text -ErrorAction SilentlyContinue)
  {
    Write-Warning 'Please close and re-open Sublime Text to force packages to update'
  }

  Write-Host @'
To take advantage of the GitHub Gist plugin, generate an OAuth token.

In Powershell this can be done by copying the following code into the shell:

function Setup-SublimeGitHub
{
  $userName = Read-Host -Prompt "Enter GitHub Username"
  $password = Read-Host -Prompt "Enter GitHub Password"

  $postData = @{ scopes = @("repo"); note = "Sublime Plugin Token" }
  $params = @{
    Uri = "https://api.github.com/authorizations";
    Method = "POST";
    Headers = @{
      Authorization = "Basic " + [Convert]::ToBase64String(
        [Text.Encoding]::ASCII.GetBytes("$($userName):$($password)"));
    }
    ContentType = "application/json";
    Body = (ConvertTo-Json $postData -Compress)
  }

  $GITHUB_API_OUTPUT = Invoke-RestMethod @params

  $token = $GITHUB_API_OUTPUT | Select -ExpandProperty Token
  Write-Host "New OAuth token is $token"

  $configFile = "$ENV:APPDATA\Sublime Text 2\Packages\User\GitHub.sublime-settings"
  $json = (Get-Content $configFile) -join "" | ConvertFrom-Json
  $json.accounts.GitHub.github_token = $token
  $json | ConvertTo-Json | Out-File $configFile -Force
}

Setup-SublimeGitHub
'@

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
