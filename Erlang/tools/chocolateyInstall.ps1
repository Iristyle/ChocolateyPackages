try {
	Install-ChocolateyPackage 'erlang' 'EXE' '/S' 'http://www.erlang.org/download/otp_win32_17.0.exe' 'http://www.erlang.org/download/otp_win64_17.0.exe'  -validExitCodes @(0)

  Write-ChocolateySuccess 'Erlang'
} catch {
  Write-ChocolateyFailure 'Erlang' $($_.Exception.Message)
  throw 
}
