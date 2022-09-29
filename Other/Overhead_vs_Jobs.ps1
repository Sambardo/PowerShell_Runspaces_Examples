#This is not a great example, but jobs will take a little longer since there is more overhead
#make 100 jobs that last 1 second each
#output should show something like this:
#Jobs took 221.8263645
#Runspaces took 2.1427572
#Difference 219.6836073
#Jobs seem to finish unexpectedly out of order and often hang for a chunk of time between output, unsure why

$JobBlock = {
    $JList = new-object System.Collections.ArrayList
    foreach($i in 0..100)
    {
        $job = Start-Job -ScriptBlock {
        param($num)
        Start-Sleep -Seconds 1
        "JDone $num"
        } -ArgumentList $i
        $JList.add($job) 
    }
    $JList | Receive-Job -wait | write-host
}
$JobTime = Measure-Command -Expression $JobBlock

#make 100 runspaces that last 1 second each
$RSBlock = 
{
    $PSList = new-object System.Collections.ArrayList
    foreach($i in 0..100)
    {
        $PowerShell = [PowerShell]::Create()
        $PowerShell.AddScript({
            param($num)
            Start-Sleep -Seconds 1
            "RSDone $Num"
        }).addArgument($i)
        $PSList.add(@{
            PowerShell = $PowerShell
            Async = $PowerShell.beginInvoke()
        }) 

    }
    
    foreach($PS in $PSList)
    {
        write-host $PS.PowerShell.EndInvoke($PS.Async)
        $PS.PowerShell.Dispose()
    }

}
$RSTime = Measure-Command -Expression $RSBlock 

Write-Host "Jobs took $($JobTime.TotalSeconds)" -ForegroundColor Yellow
Write-Host "Runspaces took $($RSTime.TotalSeconds)" -ForegroundColor Green
Write-Host "Difference $($JobTime.TotalSeconds - $RSTime.TotalSeconds)" -ForegroundColor Cyan
