    $dates = Invoke-WebRequest https://gist.githubusercontent.com/coderd00d/a88d4d2da014203898af/raw/73e9055107b5185468e2ec28b27e3b7b853312e9/gistfile1.txt

    $t, $f, $b, $w, $i, $c = "(\d\d)", "(\d{4})", "(\d{4}|\d\d)", "(\w{3})", 0, @{}
    -split "Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec" | % { $c+=@{$_=++$i} }
    function z {switch ($args[0]){$true{$args[1]}$false{$args[2]}}}
    $dates -split "`n" | % {
        [int]$y, [int]$m, [int]$d = switch -regex ($_) {
            "^$f-$t-$t$"   { $matches[1], $matches[2], $matches[3] }
            "^$t/$t/$t$"   { $matches[3], $matches[1], $matches[2] }
            "^$t#$t#$t$"   { $matches[2], $matches[3], $matches[1] }
            "^$t\*$t\*$f$" { $matches[3], $matches[2], $matches[1] }
            "^$w $t, $b$"  { $matches[3], $c[$matches[1]], $matches[2] }
        }
        $y += z ($y -lt 50) 2000 (z ($y -lt 100) 1900 0)
        "{0:d4}-{1:d2}-{2:d2}" -f $y, $m, $d
    }
