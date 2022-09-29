<#Add data to the state before creating#>

$InitialSessionState = [InitialSessionState]::CreateDefault() 

#this would also work if you want to use a string for the code
#$MyFunction = [System.Management.Automation.Runspaces.SessionStateFunctionEntry]::new("MyFunction","write-output 'test'") 

$MyFunction = [System.Management.Automation.Runspaces.SessionStateFunctionEntry]::new("MyFunction",{get-process powershell_ISE}) 
$InitialSessionState.Commands.Add($MyFunction)

$Runspace = [PowerShell]::Create($InitialSessionState) 
[void]$Runspace.Addcommand("MyFunction")
$Async = $Runspace.BeginInvoke() 
write-host "We can keep doing stuff now" -ForegroundColor Green

#Retrieve the output
$Runspace.EndInvoke($Async)
$Runspace.Dispose()