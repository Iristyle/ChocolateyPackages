$package = 'Python.Cheetah'

try {
  pip install cheetah==2.4.4

  # python.exe should be in PATH based on
  #simulate the unix command for finding things in path
  #http://stackoverflow.com/questions/63805/equivalent-of-nix-which-command-in-powershell
  function Which([string]$cmd)
  {
    Get-Command -ErrorAction "SilentlyContinue" $cmd |
      Select -ExpandProperty Definition
  }

  # Use PYTHONHOME if it exists, or fallback to where
  $localPython = Join-Path $Env:PYTHONHOME 'python.exe'
  if (!(Test-Path $localPython))
    { $localPython = Which python.exe }

  if (!(Test-Path $localPython))
  {
    Write-Host 'Could not find Python directory to install compiled NameMapper'
    return
  }

  # http://www.cheetahtemplate.org/download.html
  # Cheetah offers better perf on Windows if the compiled NameMapper is used
  $nameMapperPath = Split-Path $localPython |
    Get-ChildItem -Filter 'NameMapper.py' -Recurse |
    ? { (Split-Path (Split-Path $_.FullName) -Leaf) -ieq 'Cheetah' } |
    Select -First 1 -ExpandProperty FullName

  if (!(Test-Path $nameMapperPath))
  {
    Write-Host 'Could not find Cheetahs NameMapper.py'
    return
  }

  $nameMapperRoot = Split-Path $nameMapperPath
  Write-Host "Installing _namemapper.pyd adjacent to existing NameMapper.py at $nameMapperRoot"

  $pythonVersion = &$localPython --version 2>&1
  # pick compiled namemapper based on python version
  switch -Regex $pythonVersion
  {
    #2.7 compiled by hand with setup.py install build --compiler=mingw32
    '^.*2\.7(\.\d+){0,1}$' { $url = 'https://github.com/Iristyle/ChocolateyPackages/raw/master/Python.Cheetah/_namemapper-2.7.pyd' }
    '^.*2\.6(\.\d+){0,1}$' { $url = 'https://github.com/Iristyle/ChocolateyPackages/raw/master/Python.Cheetah/_namemapper-2.6.pyd' }
    '^.*2\.5(\.\d+){0,1}$' { $url = 'https://github.com/Iristyle/ChocolateyPackages/raw/master/Python.Cheetah/_namemapper-2.5.pyd' }
    '^.*2\.4(\.\d+){0,1}$' { $url = 'https://github.com/Iristyle/ChocolateyPackages/raw/master/Python.Cheetah/_namemapper-2.4.pyd' }
    # original sources
    # '^.*2\.6(\.\d+){0,1}$' { $url = 'http://feisley.com/python/cheetah/pyd2.2.1/py26/_namemapper.pyd' }
    # '^.*2\.5(\.\d+){0,1}$' { $url = 'http://cheetahtemplate.org/_namemapper.pyd2.5' }
    # '^.*2\.4(\.\d+){0,1}$' { $url = 'http://cheetahtemplate.org/_namemapper.pyd2.4' }
  }

  $params = @{
    packageName = $package;
    fileFullPath = (Join-Path $nameMapperRoot '_namemapper.pyd');
    url = $url
  }

  Get-ChocolateyWebFile @params

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
