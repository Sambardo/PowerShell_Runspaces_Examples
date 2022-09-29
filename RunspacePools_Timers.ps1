<# LEGAL DISCLAIMER:
This Sample Code is provided for the purpose of illustration only and is not
intended to be used in a production environment.  THIS SAMPLE CODE AND ANY
RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
#>
<#  Summary:
    builds a runspace pool
    creates 10 powershell instances and assigns them to the pool
    calculates the start and end time
    
    Output Notes:
    The output will poll every 10 seconds and display which runspaces are finished
    This means the total time might be ~10 seconds off  
    You should see them finish slightly out of order while working in batches of $MaxThreads
    
    Runspace notes:
    Each runspace runs for a random time between 10-60s so they will finish at different times
    Runspaces take in their own instance number and output a custom object
    Object contains: the run time and a message for the end
#>

$MaxThreads = 8
$RunspacePool = [runspacefactory]::CreateRunspacePool(1,$MaxThreads)

#Must open the Pool before we can use the Runspaces
$RunspacePool.Open()
#$RunspacePool.GetAvailableRunspaces() 
 
#Create an Empty List to store PowerShell and Runspace AsyncResults in
[System.Collections.ArrayList]$RunspaceList = @() 

$startTime = (get-date).TimeOfDay
write-host "Start time $startTime" -ForegroundColor Green

<# This loop does the following:
Create 10 runspaces
add a script that take 10-60 seconds in each
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
        [pscustomobject]@{
            RunspaceNumber   = "$RunspaceNumber is done and took $runTime seconds"
            Runtime          = $runTime
        }
    })
    [Void]$Runspace.AddArgument($RunspaceNumber) 

    [void]$RunspaceList.Add([pscustomobject]@{
        RunspaceNumber   = $RunspaceNumber
        Runspace         = $Runspace
        AsyncResult      = $Runspace.BeginInvoke()
    })
}  

<#
Every 10 seconds check if the runspace pool is still running (not all 3 runspaces are available for work)
Display the runspaces for which are running/finished
The runspaces executing will be $MaxThreads and as less work is available then threads free up

output explained:
The following sample uses 8 max threads and the output shows that 
- runspaces 3,4,6,7,8,10 are all complete (TRUE)
- runspaces 1,2,5,9 are still running
- Since there are 8 max threads, but only 4 runspaces are executing, then 4 are available
Runspaces available: 4
False
False
True
True
False
True
True
True
False
True
#>
while($RunspacePool.GetAvailableRunspaces() -lt $MaxThreads)
{
    Write-host "Runspaces available: $($RunspacePool.GetAvailableRunspaces())" -ForegroundColor Green 
    $RunspaceList.AsyncResult.iscompleted
    start-sleep -Seconds 10
}

#Get all the results, then the total run time
$seconds = 0
ForEach ($r in $RunspaceList)
{
    $out = $R.Runspace.EndInvoke($R.AsyncResult)
    $seconds+=$out.Runtime
    $out.RunspaceNumber
    $R.Runspace.Dispose()
}

$endTime = (get-date).TimeOfDay
$runTime = $endTime - $startTime
write-host "End time $endTime" -ForegroundColor Green
write-host "Actual run time: $($runTime.TotalSeconds) seconds" -ForegroundColor Green
write-host "Cumulative from all runspaces: $seconds seconds" -ForegroundColor Green
write-host "Time difference: $($seconds - $runTime.TotalSeconds) seconds" -ForegroundColor Green

$RunspacePool.Dispose()
