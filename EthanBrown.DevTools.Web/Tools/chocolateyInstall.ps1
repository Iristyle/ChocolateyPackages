$package = 'EthanBrown.DevTools.Web'

try {

  # simulate the unix command for finding things in path
  # http://stackoverflow.com/questions/63805/equivalent-of-nix-which-command-in-powershell
  function Which([string]$cmd)
  {
    Get-Command -ErrorAction "SilentlyContinue" $cmd |
      Select -ExpandProperty Definition
  }

  # "External packages cannot depend on packages that target projects."
  # http://nuget.codeplex.com/workitem/595

  # install required NPM packages
  $packages = @(
    'coffee-script@1.6.2',
    'coffeelint@0.5.4',
    'bower@0.9.2',
    'grunt-cli@0.1.8',
    'http-server@0.5.3',
    'jshint@2.0.1',
    'codo@1.7.0',
    'recess@1.1.6',
    'csslint@0.9.10'
  )

  $npmDefault = Join-Path $Env:ProgramFiles 'nodejs\npm.cmd'
  $npm = (Which npm),
    $npmDefault |
    ? { Test-Path $_ } |
    Select -First 1

  if ($npm)
  {
    &$npm install -g $packages
  }
  else
  {
    $msg = @"
Could not find NodeJS NPM to install global packages:
Please install these packages in a command prompt that has access to npm.cmd

npm install -g $packages
"@
  Write-Warning $msg
  }

  # install required gems
  gem update --system
  gem install bundler --version '=1.3.5'
  gem install capistrano --version '=2.14.2'
  gem install twig --version '=1.2'

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package $($_.Exception.Message)
  throw
}
