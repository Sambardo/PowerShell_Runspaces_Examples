<#
I'm not sure how to make this useful yet 
You can get the output buffer info as it gets populated
I'm not sure how the input one would work for me here, and if there is a way to just skip it
Refs: 
https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.psdatacollection-1?view=powershellsdk-7.0.0
https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.powershell.invokeasync?view=powershellsdk-7.0.0#System_Management_Automation_PowerShell_InvokeAsync
#>

$scriptBlock = {
    foreach($a in 1..5)
    {
        start-sleep -Seconds 3
        "hello world"
    }
}

# Create objects and set stuff up
$PowerShell = [powershell]::Create().AddScript($scriptBlock)
# These two lines are not correct
$inputStream = New-Object System.Management.Automation.PSDataCollection[PSObject]
$outputStream = New-Object System.Management.Automation.PSDataCollection[PSObject]

$async = $PowerShell.BeginInvoke($inputStream, $outputStream)
#$async = $pipeline.BeginInvoke($outputStream)


while(!($async.IsCompleted))
{
    $outputStream
}

$pipeline.EndInvoke($async)

# Clean-up code    
$pipeline.Dispose()