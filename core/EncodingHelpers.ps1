# Adapted from http://www.west-wind.com/Weblog/posts/197245.aspx
function Get-FileEncoding($Path)
{
  $bytes = [byte[]](Get-Content $Path -Encoding byte -ReadCount 4 -TotalCount 4)

  if (!$bytes) { return 'utf8' }

  switch -regex ('{0:x2}{1:x2}{2:x2}{3:x2}' -f $bytes[0..3])
  {
      '^efbbbf'   { return 'utf8' }
      '^2b2f76'   { return 'utf7' }
      '^fffe'     { return 'unicode' }
      '^feff'     { return 'bigendianunicode' }
      '^0000feff' { return 'utf32' }
      default     { return 'ascii' }
  }
}
