#Start a runspace in Async
$Runspace = [PowerShell]::Create() 
$Runspace.AddScript({Start-Sleep -Seconds 20;'Done'})
$Async = $Runspace.BeginInvoke()

write-host "We can keep doing stuff now" -ForegroundColor Green
$Runspace.EndInvoke($Async) #this also waits for completion
write-host "Is it done?" -ForegroundColor Green

$Runspace.Dispose()