#Create a simple runspace, notice it locks up the process since its syncronous 
$Runspace = [PowerShell]::Create()
$Runspace.Runspace.RunspaceStateInfo
$Runspace.AddScript({Start-Sleep -Seconds 5;'Done'})
$Runspace.Invoke()

$Runspace.Dispose()

#region overhead difference between a Job and a Runspace in time
#This is not a great example, but jobs will take a little longer since there is more overhead
Measure-Command -Expression {Start-Job -ScriptBlock {Start-Sleep -Seconds 5;'Done'} | Wait-Job}

$runspaceinvokesb = 
{
    $Runspace = [PowerShell]::Create()
    $Runspace.AddScript({Start-Sleep -Seconds 5;'Done'})
    $Runspace.Invoke()
    $Runspace.Dispose()
}
Measure-Command -Expression $runspaceinvokesb 
#endregion

#Jobs create a bunch of new processes, but runspaces make threads
#TODO Need to add some more examples for this later