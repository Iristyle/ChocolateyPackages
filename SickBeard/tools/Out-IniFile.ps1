#Requires -Version 2.0

function Out-IniFile
{
<#
.Synopsis
  Write the contents of a Hashtable or OrderedDictionary to an INI file
.Description
  The input can either be a standard Powershell hash created with @{},
  an [ordered]@{} in Powershell 3, an OrderedDictionary created by the
  Get-IniContent cmdlet.

  Will write out the fully nested structure to an INI file
.Notes
  Inspiration from Oliver Lipkau <oliver@lipkau.net>
  http://tinyurl.com/94tdhdx
.Inputs
  Accepts either a Collections.Specialized.OrderedDictionary or
  a standard Powershell Hashtable
.Outputs
  Returns an IO.FileInfo object if -PassThru is specified
  System.IO.FileSystemInfo
.Parameter InputObject
  Specifies the OrderedDictionary or Hashtable to be written to the file
.Parameter FilePath
  Specifies the path to the output file.
.Parameter Encoding
  Specifies the type of character encoding used in the file. Valid
  values are "Unicode", "UTF7", "UTF8", "UTF32", "ASCII",
  "BigEndianUnicode", "Default", and "OEM". "Unicode" is the default.

  "Default" uses the encoding of the system's current ANSI code page.

  "OEM" uses the current original equipment manufacturer code page
  identifier for the operating system.
.Parameter Append
  Adds the output to the end of an existing file, instead of replacing
  the file contents.
.Parameter Force
  Allows the cmdlet to overwrite an existing read-only file. Even using
  the Force parameter, the cmdlet cannot override security restrictions.
.Parameter PassThru
  Returns the newly written FileInfo. By default, this cmdlet does not
  generate any output.
.Example
  @{ Section = @{ Foo = 'bar'; Baz = 1} } |
    Out-IniFile -FilePath .\foo.ini

  Description
  -----------
  Writes the given Hashtable to foo.ini as

  [Section]
  Baz=1
  Foo=bar
.Example
  @{ Section = [ordered]@{ Foo = 'bar'; Baz = 1} } |
    Out-IniFile -FilePath .\foo.ini

  Description
  -----------
  Writes the given Hashtable to foo.ini, in the given order

  [Section]
  Foo=bar
  Baz=1
.Example
  @{ Section = [ordered]@{ Foo = 'bar'; Baz = 1} } |
    Out-IniFile -FilePath .\foo.ini -Force

  Description
  -----------
  Same as previous example, except that foo.ini is overwritten should
  it already exist
.Example
  $file = @{ Section = [ordered]@{ Foo = 'bar'; Baz = 1} } |
    Out-IniFile -FilePath .\foo.ini

  Description
  -----------
  Same as previous example, except that the FileInfo object is returned
.Example
  $config = Get-IniContent .\foo.ini
  $config.Section.Value = 'foo'

  $config | Out-IniFile -Path .\foo.ini -Force


  Description
  -----------
  Parses the foo.ini file contents into an OrderedDictionary with the
  Get-IniContent cmdlet.  Manipulates the contents, then overwrites the
  existing file.
#>

  [CmdletBinding()]
  Param(
    [Parameter(ValueFromPipeline=$true, Mandatory=$true)]
    [ValidateScript({ ($_ -is [Collections.Specialized.OrderedDictionary]) -or `
      ($_ -is [Hashtable]) })]
    [ValidateNotNullOrEmpty()]
    $InputObject,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({ Test-Path $_ -IsValid })]
    [string]
    $FilePath,

    [Parameter(Mandatory=$false)]
    [ValidateSet('Unicode','UTF7','UTF8','UTF32','ASCII','BigEndianUnicode',
      'Default','OEM')]
    [string]
    $Encoding = 'Unicode',

    [switch]
    $Append,

    [switch]
    $Force,

    [switch]
    $PassThru
  )

  process
  {
    Write-Verbose "[INFO]: Out-IniFile writing file [$FilePath]"
    if ((New-Object IO.FileInfo($FilePath)).Extension -ne '.ini')
    {
      Write-Warning 'Out-IniFile [$FilePath] does not end in .ini extension'
    }

    if ((Test-Path $FilePath) -and (!$Force))
    {
      throw "The -Force switch must be applied to overwrite $outFile"
    }

    $outFile = $null
    if ($append) { $outFile = Get-Item $FilePath -ErrorAction SilentlyContinue }
    if ([string]::IsNullOrEmpty($outFile) -or (!(Test-Path $outFile)))
      { $outFile = New-Item -ItemType File -Path $FilePath -Force:$Force }

    #recursive function write sections at various depths
    function WriteKeyValuePairs($dictionary, $sectionName = $null, $depth = 0)
    {
      #Sections - take into account nested depth
      if ((![string]::IsNullOrEmpty($sectionName)) -and ($depth -gt 0))
      {
        $sectionName = "$('[' * $depth)$sectionName$(']' * $depth)"
        Write-Verbose "[INFO]: writing section $sectionName to $outFile"
        Add-Content -Path $outFile -Value $sectionName -Encoding $Encoding
      }

      $dictionary.GetEnumerator() |
        % {
          if ($_.Value -is [Collections.Specialized.OrderedDictionary] -or
            $_.Value -is [Hashtable])
          {
            Write-Verbose "[INFO]: Writing section [$($_.Key)] of $sectionName"
            WriteKeyValuePairs $_.Value $_.Key ($depth + 1)
          }
          elseif ($_.Value.IsComment -or ($_.Key -match '^\{Comment\-[\d]+\}'))
          {
            Write-Verbose "[INFO]: Writing comment $($_.Value)"
            Add-Content -Path $outFile -Value $_.Value -Encoding $Encoding
          }
          else
          {
            Write-Verbose "[INFO]: Writing key $($_.Key)"
            Add-Content -Path $outFile -Value "$($_.Key)=$($_.Value)" -Encoding $Encoding
          }
        }
    }

    WriteKeyValuePairs $InputObject

    Write-Verbose "[SUCCESS]: Out-IniFile wrote file [$outFile]"
    if ($PassThru) { return $outFile }
  }
}