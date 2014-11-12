$data = Invoke-WebRequest https://gist.githubusercontent.com/coderd00d/54215798871d0c356cfb/raw/5eaeefb59a46bbede467bc3d1ce58f5462f78166/186%20easy
$Candy = $data.Content.Trim() -split "`n"
$Candy | Group-Object | ForEach-Object { [pscustomobject]@{Candy=$_.Name; Count=$_.Count; Percentage=($_.Count / $Candy.Count)} } | Sort-Object Candy | Format-Table Candy, Count, @{N="Percentage";E={"{0:P1}" -f $_.Percentage}} -AutoSize
