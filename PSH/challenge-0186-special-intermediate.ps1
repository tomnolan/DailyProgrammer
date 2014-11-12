enum CellTypes
{
    Empty
    Zombie
    Victim
    Hunter
}

function Generate-ZombieMap
{
    Param(
        [int]$Zombies,
        [int]$Victims,
        [int]$Hunters,
        [int]$MapWidth,
        [int]$MapHeight
    )
    if ($Zombies + $Victims + $Hunters -gt $MapWidth * $MapHeight)
    {
        throw (New-Object System.ArgumentException "Specified map size must be greater than number of characters to be placed.")
    }

    $map = New-Object 'CellTypes[]' -ArgumentList ($MapWidth * $MapHeight)
    $Start = 1
    $Start..$($Start + $Zombies - 1) | ForEach-Object { $map[$_-1] = [CellTypes]::Zombie }
    $Start += $Zombies
    $Start..$($Start + $Victims - 1) | ForEach-Object { $map[$_-1] = [CellTypes]::Victim }
    $Start += $Victims
    $Start..$($Start + $Hunters - 1) | ForEach-Object { $map[$_-1] = [CellTypes]::Hunter }

    $map | Sort-Object { Get-Random -Minimum 1 -Maximum ($MapWidth * $MapHeight) }
}


$World = Generate-ZombieMap -Zombies 10 -Victims 50 -Hunters 15 -MapWidth 20 -MapHeight 20
#$World | Group-Object
$world
