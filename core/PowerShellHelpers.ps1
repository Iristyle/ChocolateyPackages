function Get-ModuleDirectory
{
  [CmdletBinding()]
  param()

  # find the first default module path we can safely write to
  $defaultModulePath = $Env:PSModulePath -split ';' |
    ? {
      Write-Verbose "Checking path $_ for write-ability"
      try {
        if (!(Test-Path $_)) { New-Item -Path $_ -Type Directory }

        $testFile = Join-Path $_ 'write-test.tmp'
        '' | Out-File -FilePath $testFile
        Remove-Item -Path $testFile
        return $true
      }
      catch { return $false }
    } |
    Select -First 1

  if ($defaultModulePath) { return $defaultModulePath }

  # no defaults were acceptable, so try Choc paths
  $tools = Join-Path $Env:SystemDrive 'tools'
  if ($Env:Chocolatey_Bin_Root)
  {
    $tools = Join-Path $Env:SystemDrive $Env:Chocolatey_Bin_Root
  }

  if (!(Test-Path $tools))
  {
    New-Item -Path $tools -Type Directory | Out-Null
  }

  return $tools
}
