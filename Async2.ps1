#Creating and running 2 runspaces, then waiting for them both to finish
$start = get-date
$Runspace1 = [PowerShell]::Create() 
$Runspace1.AddScript({Start-Sleep -Seconds 5;'Done1'})
$Async1 = $Runspace1.BeginInvoke() 

$Runspace2 = [PowerShell]::Create() 
$Runspace2.AddScript({Start-Sleep -Seconds 5;'Done2'})
$Async2 = $Runspace2.BeginInvoke() 

Write-Host "I can keep doing stuff until I need results" -ForegroundColor Green
Write-Host "Start waiting for both to finish..." -ForegroundColor Green

$Runspace1.EndInvoke($Async1)
$Runspace2.EndInvoke($Async2)

$end = Get-Date
($end-$start)

$Runspace1.Dispose()
$Runspace2.Dispose()