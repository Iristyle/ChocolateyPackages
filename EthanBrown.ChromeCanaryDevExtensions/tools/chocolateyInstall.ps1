$package = 'EthanBrown.ChromeCanaryDevExtensions'

try {

  function Get-CurrentDirectory
  {
    $thisName = $MyInvocation.MyCommand.Name
    [IO.Path]::GetDirectoryName((Get-Content function:$thisName).File)
  }

  . (Join-Path (Get-CurrentDirectory) 'ChromeHelpers.ps1')

  $toInstall = @{
    "ighdmehidhipcmcojjgiloacoafjmpfk" = "Batarang";
    "cppjkneekbjaeellbfkmgnhonkkjfpdn" = "Clear Cache";
    "mlejngncgiocofkcbnnpaieapabmanfl" = "DevTools AutoSave";
    "gplegfbjlmmehdoakndmohflojccocli" = "PageSpeed Insights";
    "fhjcajmcbmldlhcimfajhfbgofnpcjmb" = "Simple REST Client";
    "ognampngfcbddbfemdapefohjiobgbdl" = "Speed Tracer";
    "ladbkfdlnaibelfidknofapbbdlhadfp" = "CoffeeConsole";
    "ninejjcohidippngpapiilnmkgllmakh" = "YSlow";
    # has messed up install requirements
    # "hikjpmfebkagiijbdinakadphhjffaik" = "CoffeeScript IDE";
    # "fdmmgilgnpjigdojojpjoooidkmcomcm" = "PostMan";
    # handled by Grunt
    # "jnihajbhpnppcggbcgedagnkighmdlei" = "LiveReload";
    # deprecated for now
    # "fbiodiodggnlakggeeckkjccjhhjndnb" = "Grunt DevTools";
    # "lfjbhpnjiajjgnjganiaggebdhhpnbih" = "Tincr"
  }

  Install-ChromeExtensions $toInstall -Canary

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
