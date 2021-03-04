#Create a simple runspace, notice it locks up the process since its syncronous 
$Powershell = [PowerShell]::Create()
$Powershell.Runspace.RunspaceStateInfo
$PowerShell.AddScript({Start-Sleep -Seconds 5;'Done'})
$PowerShell.Invoke()

#region overhead difference between a Job and a Runspace in time
#This is not a great example, but jobs will take a little longer since there is more overhead
Measure-Command -Expression {Start-Job -ScriptBlock {Start-Sleep -Seconds 5;'Done'} | Wait-Job}

$runspaceinvokesb = 
{
    $Powershell = [PowerShell]::Create()
    $PowerShell.AddScript({Start-Sleep -Seconds 5;'Done'})
    $PowerShell.Invoke()
    $PowerShell.Dispose()
}
Measure-Command -Expression $runspaceinvokesb 
#endregion

#Jobs create a bunch of new processes, but runspaces make threads
#TODO Need to add some more examples for this later