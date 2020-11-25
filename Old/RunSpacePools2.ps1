#region function
function Get-RunspaceState
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [Alias('PowerShell')]
        [PowerShell]$PS,

        [Parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [Alias('Handle')]
        # Should be of type [System.Management.Automation.PowerShellAsyncResult]. value returned from BeginInvoke
        [PSObject]$AsyncResult
    )

    Begin
    {
        # Set the Binding Flags for Reflection to get Non-Public Fields from PowerShell Instance
        $BindingFlags = [System.Reflection.BindingFlags]'static','nonpublic','instance'
    }
    process
    {
        # Get Value Runspace Worker Field
        $Worker = $PS.GetType().GetField('worker',$BindingFlags).GetValue($PS)

        # Get the 'CurrentlyRunningPipline' Property for the runspaces worker
        $CurrentlyRunningPipeline = $worker.GetType().GetProperty('CurrentlyRunningPipeline',$BindingFlags).GetValue($Worker)

        # Check Com
        if($AsyncResult.IsCompleted -and $null -eq $CurrentlyRunningPipeline)
        {
            $State = 'Completed'
        }
        elseif (-not $AsyncResult.IsCompleted -and $null -ne $CurrentlyRunningPipeline )
        {       

            $State = 'Running'
        }
        elseif (-not $AsyncResult.IsCompleted -and $null -eq $CurrentlyRunningPipeline)
        {
            # The logic here is that pipeline will be cleared when Completed.
            # So if it is Not Completed and there nothing in the Pipeline it has not started yet
            $State = 'NotStarted'
        }
        
        [PSCustomObject]@{
            PipelineRunning = [bool]$CurrentlyRunningPipeline
            State = $State
            IsCompleted = $AsyncResult.IsCompleted
            Synchronous = $AsyncResult.CompletedSynchronously
        }
    }
} 
#endregion

#Create a runspace pool
$RunspacePool = [runspacefactory]::CreateRunspacePool(1,3)

#Must open the Pool before we can use the Runspaces
$RunspacePool.Open()
$RunspacePool.GetAvailableRunspaces() 
 
#Create an Empty List to store PowerShell and Runspace AsyncResults in
[System.Collections.ArrayList]$RunspaceList = @() 


#Assign the following script to the runspace pools that will index the c:\windows folder
foreach($RunspaceInstance in 1..10)
{
    $PowerShellInstance = [powershell]::Create()
    $PowerShellInstance.RunspacePool = $RunspacePool

    [void]$PowerShellInstance.AddScript(
    {
        $ranTime = Get-Random -Minimum 10 -Maximum 30
        start-sleep -Seconds $ranTime
        Write-host "$RunspaceInstance is done" -ForegroundColor Green
    })
        
    [Void]$PowerShellInstance.AddArgument($RunspaceInstance)
    $RunspaceList.Add([pscustomobject]@{
        RunspaceInstance = $RunspaceInstance
        PowerShell       = $PowerShellInstance
        AsyncResult      = $PowerShellInstance.BeginInvoke()
    })
}  

#View available runspaces
$RunspacePool.GetAvailableRunspaces() 
#View the list object with all runspaces 
$RunspaceList
$RunspaceList.AsyncResult 

$RunspaceList | Get-RunspaceState

<#
$tracker = 0
While($tracker -lt 10)
{
    $numDone = ($RunspaceList.AsyncResult.iscompleted | where {$_ -eq "True"}).count
    if($numDone -gt $tracker)
    {
        $tracker = $numDone
        $RunspaceList.AsyncResult | FT isCompleted
    }
    start-sleep -seconds 2
}

$RunspaceList.PowerShell.Stop() 
#>