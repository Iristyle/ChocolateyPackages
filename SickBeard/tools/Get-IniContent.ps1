#Requires -Version 2.0

function Get-IniContent
{
<#
.Synopsis
  Reads the contents of an INI file into an OrderedDictionary
.Description
  The dictionary can be manipulated the same way a Hashtable can, by
  adding or removing keys to the various sections.

  By using an OrderedDictionary, the contents of the file can be
  roundtripped through the Out-IniFile cmdlet.

  Nested INI sections represented like the following are supported:

  [foo]
  name = value
  [[bar]]
  name = value
  ;name = value

  Comment lines prefixed with a ; are returned in the output with a name
  of {Comment-X} where X is the comment index within the entire INI file

  Comments also have an IsComment property attached to the values, so
  that Out-IniFile may properly handle them.
.Notes
  Inspiration from Oliver Lipkau <oliver@lipkau.net>
  http://tinyurl.com/9g4zonn
.Inputs
  String or FileInfo
.Outputs
  Collections.Specialized.OrderedDictionary
  Keys with a OrderdedDictionary Value are representative of sections

  Sections may be nested to any arbitrary depth
.Parameter Path
  Specifies the path to the input file. Can be a string or FileInfo
  object
.Example
  $configFile = Get-IniContent .\foo.ini

  Description
  -----------
  Parses the foo.ini file contents into an OrderedDictionary for local
  reading or manipulation
.Example
  $configFile = .\foo.ini | Get-IniContent
  $configFile.SectionName | Select *

  Description
  -----------
  Same as the first example, but using pipeline input.
  Additionally outputs all values stored in the [SectionName] section of
  the INI file.
#>
  [CmdletBinding()]
  param(
    [Parameter(ValueFromPipeline=$True, Mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({ (Test-Path $_) -and ($_.Extension -eq '.ini') })]
    [IO.FileInfo]
    $Path
  )

  Process
  {
    Write-Verbose "[INFO]: Get-IniContent processing file [$Path]"

    # TODO: once Powershell 3 is common, this can be $ini = [ordered]@{}
    $ini = New-Object Collections.Specialized.OrderedDictionary

    function getCurrentOrEmptySection($section)
    {
      if (!$section)
      {
        if (!$ini.Keys -contains '')
        {
          $ini[''] = New-Object Collections.Specialized.OrderedDictionary
        }
        $section = $ini['']
      }
      return $section
    }

    $comments = 0
    $sections = @($ini)
    switch -regex -file $Path
    {
      #http://stackoverflow.com/questions/9155483/regular-expressions-balancing-group
      '\[((?:[^\[\]]|(?<BR> \[)|(?<-BR> \]))+(?(BR)(?!)))\]' # Section
      {
        $name = $matches[1]
        # since the regex above is balanced, depth is a simple count
        $depth = ($_ | Select-String '\[' -All).Matches |
          Measure-Object |
          Select -ExpandProperty Count

        # root section
        Write-Verbose "Parsing section $_ at depth $depth"
        # handles any level of nested section
        $section = New-Object Collections.Specialized.OrderedDictionary
        $sections[$depth - 1][$name] = $section
        if ($sections.Length -le $depth)
        {
          $sections += $section
        }
        else
        {
          $sections[$depth] = $section
        }
      }
      '^(;.*)$' # Comment
      {
        $section = getCurrentOrEmptySection $section
        $name = '{Comment-' + ($comments++) + '}'
        $section[$name] = $matches[1] |
          Add-Member -MemberType NoteProperty -Name IsComment -Value $true -PassThru
      }
      '(.+?)\s*=\s*(.*)' # Key
      {
        $name, $value = $matches[1..2]
        (getCurrentOrEmptySection $section)[$name] = $value
      }
    }

    Write-Verbose "[SUCCESS]: Get-IniContent processed file [$path]"
    return $ini
  }
}