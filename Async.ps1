#Start a runspace in Async
$Runspace = [PowerShell]::Create() 
$Runspace.AddScript({Start-Sleep -Seconds 20;'Done'})
$Async = $Runspace.BeginInvoke() 

write-host "We can keep doing stuff now" -ForegroundColor Green
write-host "Is it done?" -ForegroundColor Green
#note it is in running state
$Async

#Retrieve the output
$Runspace.EndInvoke($Async)
$Runspace.Dispose()