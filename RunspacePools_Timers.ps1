<# LEGAL DISCLAIMER:
This Sample Code is provided for the purpose of illustration only and is not
intended to be used in a production environment.  THIS SAMPLE CODE AND ANY
RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
#>
$MaxThreads = 4
#Create a runspace pool
$RunspacePool = [runspacefactory]::CreateRunspacePool(1,$MaxThreads)

#Must open the Pool before we can use the Runspaces
$RunspacePool.Open()
$RunspacePool.GetAvailableRunspaces() 
 
#Create an Empty List to store PowerShell and Runspace AsyncResults in
[System.Collections.ArrayList]$RunspaceList = @() 

#region main example
#If you run this whole region it will measure the total time it takes to complete
$startTime = (get-date).TimeOfDay
write-host "Start time $startTime" -ForegroundColor Green

<# This loop does the following:
Create 10 runspaces
add a script that take 10-30 seconds in each
assign them all to the runspace pool and start them
#>
foreach($RunspaceNumber in 1..10)
{
    $Runspace = [powershell]::Create()
    $Runspace.RunspacePool = $RunspacePool

    [void]$Runspace.AddScript(
    {
        param($RunspaceNumber)
        $runTime = Get-Random -Minimum 10 -Maximum 60
        start-sleep -Seconds $runTime
        "$RunspaceNumber is done and took $runTime seconds"
    })
    [Void]$Runspace.AddArgument($RunspaceNumber) 

    $RunspaceList.Add([pscustomobject]@{
        RunspaceNumber   = $RunspaceNumber
        Runspace         = $Runspace
        AsyncResult      = $Runspace.BeginInvoke()
    })
}  

#Every 10 seconds check if the runspace pool is still running (not all 3 runspaces are available for work)
#Display the runspaces for which are running/finished. Observe 3 will always be running picking up new work as they finish others
while($RunspacePool.GetAvailableRunspaces() -lt $MaxThreads)
{
    Write-host "Runspaces available: $($RunspacePool.GetAvailableRunspaces())" -ForegroundColor Green 
    $RunspaceList.AsyncResult.iscompleted
    start-sleep -Seconds 10
}

#Get all the results, then the total run time
ForEach ($r in $RunspaceList)
{
    $R.Runspace.EndInvoke($R.AsyncResult)
    $R.Runspace.Dispose()
}

$endTime = (get-date).TimeOfDay
$runTime = $endTime.Subtract($startTime)
write-host "End time $endTime" -ForegroundColor Green
write-host "Run time $($runTime.TotalSeconds)" -ForegroundColor Green

$RunspacePool.Dispose()
#endregion main example
