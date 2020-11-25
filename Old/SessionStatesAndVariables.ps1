#Show the current runspace host
$Host.Runspace 
$Host.Runspace.InitialSessionState
$Host.Runspace.InitialSessionState.Providers | ft
$Host.Runspace.InitialSessionState.Commands | ft
$Host.Runspace.InitialSessionState.Variables | ft
$Host.Runspace.InitialSessionState.LanguageMode 

#Create a new Runspace and view the same of this new runspace
$Powershell = [PowerShell]::Create()
$PowerShell.Runspace.InitialSessionState
$PowerShell.Runspace.RunspaceConfiguration

##########
#Create a Session state
#Create a new variable named “Null” and having a value of “Value”
#Add variable to state
$InitialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault() 
$sessionVariable = [System.Management.Automation.Runspaces.SessionStateVariableEntry]::new("name", "value", $null)
$InitialSessionState.Variables.Add($sessionVariable) 

#Create a PowerShell runspace and initialize it from the session state
$PowerShell = [powershell]::Create($InitialSessionState)  
$PowerShell.Runspace.InitialSessionState.Variables | ft name,value

##########
