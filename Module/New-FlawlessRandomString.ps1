function New-FlawlessRandomString {
<#
.SYNOPSIS
    Generates a string of random characters of a given length.
.DESCRIPTION
    Generates a string of random characters of a given length. The string must contain a given number of
    non-alphanumeric characters – the rest can be numbers or letters (at least one upper case, at least
    one lower case character and at least 1 numeric character). Scrambles the characters of the string.
.PARAMETER Length
    The length of the random string.
.PARAMETER NonAlphaNumeric
    The number of non-alphanumeric characters in the random string.
.EXAMPLE
    $string = Get-FlawlessRandomString -Length 10 -NonAlphaNumeric 3
    Assigns to $string a random 10 character string with 3 non-alphanumeric characters.
#>

[CmdletBinding(SupportsShouldProcess=$True)]
param (
    [Parameter()] [byte]$Length = 10,
    [Parameter()] [byte]$NonAlphaNumeric = 1
)
    Begin {
        if ($NonAlphaNumeric + 3 -gt $Length) {
            Write-Warning -Message "The Length value must be at least three more than the NonAlphaNumeric value."
            break
        }
        $SecureString = New-Object SecureString
        $NonAlphaNumericSet = ([char[]]([char]32..[char]47)) + ([char[]]([char]58..[char]64)) +
                                ([char[]]([char]91..[char]96)) + ([char[]]([char]123..[char]126))
        $LowerAlphabeticSet = ([char[]]([char]97..[char]122))
        $UpperAlphabeticSet = ([char[]]([char]65..[char]90))
        $NumericSet = ([char[]]([char]48..[char]57))
        $Characterset = $LowerAlphabeticSet + $UpperAlphabeticSet + $NumericSet + $NonAlphaNumeric
    }
    Process {
        if($PSCmdlet.ShouldProcess("Attempting to Create a Random Password")){
            $x = 0
            while ($x -le $Length) {
                $SecureString.AppendChar([char](Get-Random -InputObject $Characterset))
                $x++
            }
        }
    }
    End {
        #($RandomString | Sort-Object {Get-Random}) -join '')
        Write-Output $SecureString
    }
}
