#This requires threadjob module installed or PS7+
$TJ = Start-ThreadJob -ScriptBlock {
    Start-sleep 10
    "End" 
    }
Write-Host "Do Stuff"
Wait-Job $TJ | out-null
Receive-Job $TJ
