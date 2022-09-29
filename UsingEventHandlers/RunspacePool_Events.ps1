<#Notes on event action
    output is of type psdatacollection https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.psdatacollection-1?view=powershellsdk-7.0.0
    o[0] gets the value directly, but with hash table it seems to work without index
#>
$MaxThreads = 5
$RunspacePool = [runspacefactory]::CreateRunspacePool(1,$MaxThreads)
$RunspacePool.Open()

$startTime = get-date
$global:CumulativeTime = 0

Foreach($Instance in 0..20) {
    $PowerShell = [powershell]::Create()
    $PowerShell.RunspacePool = $RunspacePool
    
    [void]$PowerShell.AddScript({
    param ($InstanceNumber)
        $timeToSleep = get-random -Minimum 10 -Maximum 60
        Start-Sleep -Seconds $timeToSleep
        #return a hash table with the time and instance number
        @{
            Time = $timeToSleep
            InstanceNumber = $InstanceNumber
        }

    })
    [void]$PowerShell.AddParameter("InstanceNumber",$Instance)

    $p = @{
        InputObject = $PowerShell
        EventName = "InvocationStateChanged"
        MaxTriggerCount = 1
        #This passes in the async token to $event.MessageData and calls beginInvoke 
        MessageData = $PowerShell.BeginInvoke()

        Action = { #see notes at top regarding $o
            $o = $Sender.Endinvoke($event.MessageData)
            Write-host "Runspace $($o.InstanceNumber) completed in $($o.Time) seconds!" 
            $global:CumulativeTime+=$o[0].Time
            $Sender.Dispose()
        }    
    }
    Register-ObjectEvent @p
}

while((Get-EventSubscriber).count -gt 0){}

$totalTime = (Get-date) - $startTime
write-host "Total Time: $($totalTime.totalseconds)" -ForegroundColor Green
write-host "CumulativeTime time: $global:CumulativeTime" -ForegroundColor yellow
write-host "Time difference: $($global:CumulativeTime - $totalTime.totalseconds)" -ForegroundColor Green
$RunspacePool.dispose() 