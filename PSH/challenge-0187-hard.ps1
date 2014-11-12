$River = @{
    "A"=@{ "B"=6; "C"=2; };
    "B"=@{ "E"=3; "D"=3; };
    "C"=@{ "G"=5; };
    "D"=@{ "C"=2; "F"=1; };
    "E"=@{ "H"=1; "I"=2; };
    "F"=@{ "H"=1; };
    "G"=@{ "H"=2; "I"=2; };
    "H"=@{ "I"=4; };
}

$RiverStart = "A"
$RiverEnd = "I"

function FindPaths ($Graph, $Path, $End) {
    if ($Path[-1] -eq $End)
        { $Path }
    else
    { 
        $Graph["$($Path[-1])"].Keys | % { FindPaths -Graph $River -Path ($Path + $_) -End $End }
    }
}


$RiverRuns = FindPaths -Graph $River -Path "A" -End "I" | Sort-Object

