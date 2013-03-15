$package = 'EthanBrown.GitExtensionsConfiguration'

try {

  $root = 'HKCU:\Software\GitExtensions\GitExtensions'

  @(
    @{Name = 'difffont'; Value = 'Source Code Pro Semibold;9.75'; Type='String'}
    @{Name = 'showstashcount'; Value = 'True'; Type = 'String'},
    @{Name = 'CommitValidationMaxCntCharsFirstLine'; Value = 50; Type = 'DWORD'},
    @{Name = 'CommitValidationMaxCntCharsPerLine'; Value = 72; Type = 'DWORD'},
    @{Name = 'CommitValidationSecondLineMustBeEmpty'; Value = 'True'; Type = 'String'},
    @{Name = 'CommitTemplates'; Value = '512:AAEAAAD/////AQAAAAAAAAAMAgAAAD1HaXRVSSwgVmVyc2lvbj0yLjQzLjAuMCwgQ3VsdHVyZT1uZXV0cmFsLCBQdWJsaWNLZXlUb2tlbj1udWxsBwEAAAAAAQAAAAUAAAAEGEdpdFVJLkNvbW1pdFRlbXBsYXRlSXRlbQIAAAAJAwAAAAkEAAAACQUAAAAJBgAAAAkHAAAABQMAAAAYR2l0VUkuQ29tbWl0VGVtcGxhdGVJdGVtAgAAAAROYW1lBFRleHQBAQIAAAAGCAAAABdTdGFuZGFyZCBHaXQgQ29tbWl0IExvZwYJAAAAAAEEAAAAAwAAAAkJAAAACQkAAAABBQAAAAMAAAAJCQAAAAkJAAAAAQYAAAADAAAACQkAAAAJCQAAAAEHAAAAAwAAAAkJAAAACQkAAAALAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='; Type = 'String'},
    @{Name = 'revisiongraphshowworkingdirchanges'; Value = 'True'; Type = 'String'},
    @{Name = 'showgitstatusinbrowsetoolbar'; Value = 'True'; Type = 'String'},
    @{Name = 'usefastchecks'; Value = 'True'; Type = 'String'}
  ) |
    % {
      Set-ItemProperty -Path $root -name $_.Name -Type $_.Type -Value $_.Value
    }

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
