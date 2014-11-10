﻿#requires -version 5
$input = @"
 11-6-2014: 05:18 AM to 06:00 AM -- code review
 11-9-2014: 08:52 AM to 09:15 AM -- food
 11-8-2014: 07:00 PM to 08:05 PM -- meeting
 11-8-2014: 05:30 PM to 06:36 PM -- personal appointment
 11-6-2014: 02:47 PM to 03:23 PM -- work
 11-11-2014: 07:14 AM to 08:32 AM -- meeting
 11-11-2014: 11:22 AM to 12:10 PM -- code review
 11-8-2014: 01:39 PM to 02:06 PM -- food
 11-9-2014: 07:12 AM to 08:06 AM -- meeting
 11-9-2014: 02:14 PM to 03:15 PM -- code review
 11-8-2014: 05:13 AM to 06:05 AM -- food
 11-6-2014: 05:54 PM to 06:17 PM -- personal appointment
 11-7-2014: 08:24 AM to 09:23 AM -- personal appointment
 11-8-2014: 11:28 AM to 12:44 PM -- meeting
 11-7-2014: 09:35 AM to 10:35 AM -- workout
 11-9-2014: 10:05 AM to 11:15 AM -- code review
 11-11-2014: 05:02 PM to 06:09 PM -- work
 11-6-2014: 06:16 AM to 07:32 AM -- food
 11-10-2014: 10:08 AM to 11:14 AM -- workout
 11-8-2014: 04:33 PM to 05:12 PM -- meeting
 11-10-2014: 01:38 PM to 02:10 PM -- workout
 11-11-2014: 03:03 PM to 03:40 PM -- food
 11-11-2014: 05:03 AM to 06:12 AM -- food
 11-9-2014: 09:49 AM to 10:09 AM -- meeting
 11-8-2014: 06:49 AM to 07:34 AM -- work
 11-7-2014: 07:29 AM to 08:22 AM -- food
 11-10-2014: 03:08 PM to 03:29 PM -- code review
 11-9-2014: 03:27 PM to 04:39 PM -- food
 11-7-2014: 05:38 AM to 06:49 AM -- meeting
 11-7-2014: 03:28 PM to 04:06 PM -- code review
 11-8-2014: 02:44 PM to 03:35 PM -- meeting
 11-6-2014: 08:53 AM to 09:55 AM -- workout
 11-11-2014: 02:05 PM to 02:49 PM -- meeting
 11-10-2014: 08:29 AM to 09:23 AM -- code review
 11-10-2014: 11:09 AM to 11:35 AM -- sales call
 11-6-2014: 11:29 AM to 12:18 PM -- code review
 11-11-2014: 08:04 AM to 08:45 AM -- work
 11-9-2014: 12:27 PM to 01:29 PM -- sales call
 11-7-2014: 11:04 AM to 12:07 PM -- code review
 11-11-2014: 09:21 AM to 10:37 AM -- food
 11-8-2014: 09:34 AM to 10:53 AM -- meeting
 11-11-2014: 12:36 PM to 01:30 PM -- meeting
 11-10-2014: 05:44 AM to 06:30 AM -- personal appointment
 11-6-2014: 04:22 PM to 05:05 PM -- code review
 11-6-2014: 01:30 PM to 01:59 PM -- sales call
 11-10-2014: 06:54 AM to 07:41 AM -- code review
 11-9-2014: 11:56 AM to 12:17 PM -- work
 11-10-2014: 12:20 PM to 01:17 PM -- personal appointment
 11-8-2014: 07:57 AM to 09:08 AM -- meeting
 11-7-2014: 02:34 PM to 03:06 PM -- work
 11-9-2014: 05:13 AM to 06:25 AM -- workout
 11-11-2014: 04:04 PM to 04:40 PM -- food
 11-9-2014: 06:03 AM to 06:26 AM -- code review
 11-6-2014: 10:32 AM to 11:22 AM -- sales call
 11-6-2014: 07:51 AM to 08:25 AM -- personal appointment
 11-7-2014: 01:07 PM to 02:14 PM -- meeting
"@

$pattern = '(\d{1,2}-\d{1,2}-\d{4})\: (\d{2}\:\d{2} (AM|PM)) to (\d{2}\:\d{2} (AM|PM)) -- ([\w ]+)'

$parsing = @(
    @{ N="Start";    E={ [datetime]("{0} {1}" -f $_.Groups[1], $_.Groups[2]) }},
    @{ N="End";      E={ [datetime]("{0} {1}" -f $_.Groups[1], $_.Groups[4]) }},
    @{ N="Description"; E={ $_.Groups[6] } } 
)
$out = @(
    @{ N="Start";    E={ $_.Start.ToShortTimeString() }},
    @{ N="End";      E={ $_.End.ToShortTimeString() }},
    @{ N="Description"; E={ $_.Description } }
)

$schedule = @()
[regex]::Matches($input, $pattern) | Select-Object $parsing | Sort-Object Start | Group-Object { $_.Start.Date } | ForEach-Object {
    $longest = @{Duration=0; Index=-1}
    for ($i=1; $i -lt $_.Group.Count; $i++) { 
        if (($_.Group[$i].Start - $_.Group[$i-1].End).TotalMinutes -gt $longest.Duration) { 
            $longest = @{Duration=($_.Group[$i].Start - $_.Group[$i-1].End).TotalMinutes; Index=$i} 
        }
    }
    if ($longest.Duration -gt 0) {
        $Reddit = [pscustomobject]@{
            Start=$_.Group[$longest.Index - 1].End; 
            End=$_.Group[$longest.Index].Start; 
            Description="Reddit"; 
        }            
        $schedule += [pscustomobject]@{
            Date = [datetime]$_.Name;
            Activities = $_.Group[0..$($Longest.Index - 1)] + $Reddit + $_.Group[$($Longest.Index)..$($_.Group.Count-1)]
        }
    }
}

$schedule | ForEach-Object {
    "Schedule for {0}" -f $_.Date.ToShortDateString()
    $_.Activities | Select-Object $out | ft
}

$calculations = @()
$schedule.Activities | Select-Object @{N="Time"; E={ ($_.End - $_.Start).TotalMinutes }}, Description | Group-Object Description | ForEach-Object { 
    $calculations += [pscustomobject]@{
        "Activity" = $_.Name;
        "Measured" = $_.Group | Measure-Object -Property Time -Sum -Average -Minimum -Maximum;
    }
}
$totalTime = $calculations | ForEach-Object { $_.Measured.Sum } | Measure-Object -Sum
"Total Time: {0} minutes" -f $totalTime.Sum
$calculations | Select-Object Activity, @{N="Sum";E={$_.Measured.Sum}}, @{N="Average";E={[Math]::Round($_.Measured.Average, 2)}}, @{N="Minimum";E={$_.Measured.Minimum}}, @{N="Maximum";E={$_.Measured.Maximum}}, @{N="Percentage";E={"{0:P2}" -f ($_.Measured.Sum / $totalTime.Sum)}} | Sort-Object Sum -Descending | Format-Table -AutoSize
