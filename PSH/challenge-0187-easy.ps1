#requires -version 5
############# Not finished!!!
<#
input
--------
4
a:all
f:force
n:networking
N:numerical-list
-aN 12 --verbose 192.168.0.44

output
---------
flag: all
flag: numerical-list
parameter: 12
flag: verbose
parameter: 192.168.0.44
#>
class FlagDefinition
{
    [string]$ShortForm
    [string]$LongForm

    FlagDefinition($Short, $Long)
    {
        $ShortForm = $Short
        $LongForm = $Long
    }
}

function New-FlagDefinition
{
    [cmdletbinding()]
    Param(
        [parameter(ParameterSetName="UnparsedSet", Mandatory=$true, ValueFromPipelineByValue=$true)]
        [string]$Definition,
        [parameter(ParameterSetName="PreparsedSet", Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$ShortForm,
        [parameter(ParameterSetName="PreparsedSet", Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$LongForm
    )

    if ($PsCmdlet.ParameterSetName -eq "UnparsedSet")
    {
        # Intermediate: "\*?(\w):(\w+)"
        if ($Definition -match "(\w):(\w+)")
        {
            $ShortForm = $matches[1]
            $LongForm = $matches[2]
        }
        else
        {
            throw (New-Object System.ArgumentException "Incorrect flag definition format")
        }
    }
    
    return [FlagDefinition]::New($ShortForm,$LongForm)
}

function Test-Parameters
{
    [cmdletbinding()]
    Param(
        [parameter(Mandatory=$true, ValueFromPipelineByValue=$true)]
        [psobject]
    )
}






Param(
    [string[]]$FlagDefinitions,
    [string]$CommandLine
)

$SupportedFlags = @()
$FlagDefinitions | ForEach-Object {
    if ($_ -match "(\w):(\w+)")     # Intermediate: "\*?(\w):(\w+)"
    {
        $SupportedFlags += [pscustomobject]@{"ShortForm"=$matches[1]; "LongForm"=$matches[2]}
    }
}

$clArgs = $CommandLine.Split(" ")
for ($i = 0; $i -lt $clArgs.Length; $i++)
{
    switch -Regex ($clArgs[$i])
    {
        "--(\w+)"
        {
            "Long Flag: $($matches[1])"
            break
        }
        "-(\w+)"
        {
            for ($j = 0; $j -lt $matches[1].Length; $j++)
                { "Short Flag: $($matches[1][$j])" }
            break
        }
        "(\w+)"
        {
            "Parameter: $($matches[1])"
        }
    }
}

