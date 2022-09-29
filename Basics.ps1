#Create a simple runspace, notice it locks up the process since its syncronous 
$PowerShell = [PowerShell]::Create()
$PowerShell.Runspace.RunspaceStateInfo
$PowerShell.AddScript({Start-Sleep -Seconds 5;'Done'})
$PowerShell.Invoke()
$PowerShell.Dispose()

