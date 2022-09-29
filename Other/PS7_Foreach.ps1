$StartTime = get-date
1..10 | ForEach-Object -Parallel {
    "Output: $_"
    Start-Sleep 1
}
((get-date) - $StartTime).Seconds 
