
try {

  start-process -wait "C:\Program Files\erl6.0\uninstall.exe"

  Write-ChocolateySuccess 'Erlang'
} catch {
  Write-ChocolateySuccess 'Erlang'
}
