#Start a runspace in Async
$PowerShell = [PowerShell]::Create() 
$PowerShell.AddScript({Start-Sleep -Seconds 20;'Done'})
$Async = $PowerShell.BeginInvoke() 

write-host "We can keep doing stuff now" -ForegroundColor Green
write-host "Is it done?" -ForegroundColor Green
#note it is in running state
$Async

#Retrieve the output
$PowerShell.EndInvoke($Async)
$PowerShell.Dispose()