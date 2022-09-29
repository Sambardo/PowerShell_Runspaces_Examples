#Start a runspace in Async
$PowerShell = [PowerShell]::Create() 
$PowerShell.AddScript({Start-Sleep -Seconds 20;'Done'})
$Async = $PowerShell.BeginInvoke()

write-host "We can keep doing stuff now" -ForegroundColor Green
$PowerShell.EndInvoke($Async) #this also waits for completion
write-host "Is it done?" -ForegroundColor Green

$PowerShell.Dispose()