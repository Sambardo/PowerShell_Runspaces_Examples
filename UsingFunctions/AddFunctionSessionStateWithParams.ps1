<#You could also add the data in as a variable entry initially, but in this example the function has params and addagrument is used#>

$InitialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault() 

#this would also work if you want to use a string for the code
#$MyFunction = [System.Management.Automation.Runspaces.SessionStateFunctionEntry]::new("MyFunction","write-output 'test'") 

$MyFunction = [System.Management.Automation.Runspaces.SessionStateFunctionEntry]::new("MyFunction",{
    param($proc)
    get-process powershell}) 

$InitialSessionState.Commands.Add($MyFunction)

$Runspace = [PowerShell]::Create($InitialSessionState)

$data = "powershell"
[void]$Runspace.Addcommand("MyFunction").AddArgument($data)
$Async = $Runspace.BeginInvoke() 
write-host "We can keep doing stuff now" -ForegroundColor Green

#Retrieve the output
$Runspace.EndInvoke($Async)
$Runspace.Dispose()