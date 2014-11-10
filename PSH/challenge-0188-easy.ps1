    $dates = Invoke-WebRequest https://gist.githubusercontent.com/coderd00d/a88d4d2da014203898af/raw/73e9055107b5185468e2ec28b27e3b7b853312e9/gistfile1.txt

    $culture = Get-Culture
    $culture.DateTimeFormat.Calendar.TwoDigitYearMax = 2049

    $displayFormat = "yyyy-MM-dd"
    [string[]]$inputFormats = "yyyy-MM-dd", "MM/dd/yy", "MM#yy#dd", "dd*MM*yyyy", "MMM dd, yy", "MMM dd, yyyy"
    [ref]$outdate = Get-Date

    $dates -split "`n" | % { 
        if ([DateTime]::TryParseExact($_, $inputFormats, $culture, "None", $outDate))
        {
            $outDate.Value | Get-Date -Format $displayFormat
        }
        else
        {
            write-host ("Unknown format: {0}" -f $_) -ForegroundColor Red
        }
    }
