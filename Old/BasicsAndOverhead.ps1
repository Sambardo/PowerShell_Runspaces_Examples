#Create a simple runspace ( Powershell default Runspace)
$Powershell = [PowerShell]::Create()
$Powershell.Runspace.RunspaceStateInfo
$PowerShell.AddScript({Start-Sleep -Seconds 5;'Done'})
$PowerShell.Invoke()

#region overhead difference between a Job and a Runspace in time
Measure-Command -Expression {Start-Job -ScriptBlock {Start-Sleep -Seconds 5;'Done'} | Wait-Job}

$runspaceinvokesb = 
{
    $Powershell = [PowerShell]::Create()
    $PowerShell.AddScript({Start-Sleep -Seconds 5;'Done'})
    $PowerShell.Invoke()
}
Measure-Command -Expression $runspaceinvokesb 

#endregion

#region overhead difference between a Job and a Runspace in Resources
$PSHostsPreJobCreation = Get-PSHostProcessInfo
Start-Job -Name TestJob2 -ScriptBlock {Start-Sleep -Seconds 60; 'Done'}
start-sleep -seconds 61
$PSHostsPostJobCreation = Get-PSHostProcessInfo
Write-Host "Job - Pre: $($PSHostsPreJobCreation.count) Post: $($PSHostsPostJobCreation.count)"

#Notice the There is a PowerShell.exe Host per Job created.
#Jobs also have an overhead around management (Start,Stop,Suspend,Resume)
#Each Job has a primary Job and then one or more ChildJobs
$TestJob = Get-Job -Name TestJob -IncludeChildJob
$TestJob.ChildJobs

#Looking at overhead of a Runspace
$PSHostPreRunSpaceCreation = Get-PSHostProcessInfo
$PowerShellRunspaceWrapper = [PowerShell]::Create()
$PSHostPostRunSpaceCreation = Get-PSHostProcessInfo
Write-Host "Runspace - Pre: $($PSHostPreRunSpaceCreation.count) Post: $($PSHostPostRunSpaceCreation.count)"
#Show that there is a Runspace in the current Host Process
$host.Runspace 
#endregion

#region memmory and garbage collection
#When a lot of runspace are running managing the resources might be needed. 
#Start a NEW powershell session and show memory consumption
Powershell.exe
[GC]::GetTotalMemory($false) / 1mb 
#Run a runspace that consumes some memory
$Powershell = [PowerShell]::Create()
$PowerShell.AddScript({$1= Get-ChildItem -Recurse -Path c:\windows;$2=$1;$2+=$1})
$PowerShell.Invoke() 
#Look at memory consumption
[GC]::GetTotalMemory($false) / 1mb 
#Dispose of the Runspace and remove the variable 
#Run garbage collection and view memory consumption
$PowerShell.dispose()
Remove-Variable $powershell 
[GC]::Collect() 
[GC]::GetTotalMemory($false) / 1mb 
#endregion
