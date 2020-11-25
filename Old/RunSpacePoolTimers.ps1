#Create a runspace pool
$RunspacePool = [runspacefactory]::CreateRunspacePool(1,3)

#Must open the Pool before we can use the Runspaces
$RunspacePool.Open()
$RunspacePool.GetAvailableRunspaces() 
 
#Create an Empty List to store PowerShell and Runspace AsyncResults in
[System.Collections.ArrayList]$RunspaceList = @() 


#Assign the following script to the runspace pools that will index the c:\windows folder

$startTime = (get-date).TimeOfDay
write-host "Start time $startTime" -ForegroundColor Green

for($i = 0; $i -lt 10; $i++)
{
    $PowerShellInstance = [powershell]::Create()
    $PowerShellInstance.RunspacePool = $RunspacePool

    [void]$PowerShellInstance.AddScript(
    {
        param($i)
        start-sleep -Seconds 10
        "I'm done $i"
    })
        
    [Void]$PowerShellInstance.AddArgument($i)
    $RunspaceList.Add([pscustomobject]@{
        Runspace       = $PowerShellInstance
        AsyncResult      = $PowerShellInstance.BeginInvoke()
    })
}  


while ($RunspaceList.AsyncResult.IsCompleted -notcontains $true) {
    foreach ($runspace in $RunspaceList ) {
        # EndInvoke method retrieves the results of the asynchronous call
        $runspace.Runspace.EndInvoke($runspace.AsyncResult)
        $runspace.Runspace.Dispose()
    }
}

$endTime = (get-date).TimeOfDay
$runTime = $endTime.Subtract($startTime)
write-host "End time $endTime" -ForegroundColor Green
write-host "Run time $($runTime.TotalSeconds)" -ForegroundColor Green

<#
foreach ($runspace in $RunspaceList ) {
    # EndInvoke method retrieves the results of the asynchronous call
    $runspace.Runspace.EndInvoke($runspace.AsyncResult)
    $runspace.Runspace.Dispose()
}
#>