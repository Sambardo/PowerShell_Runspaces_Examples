<#
using 2 separate script blocks works fine for organization, but output will only show from the last script block
#>

$MakeFunctionSB = {
    Function SomeTestFunction
    {
        "Hello World"
    }
}

$UsingFunctionSB = {
    "Running the function"
    SomeTestFunction
}

$Runspace = [PowerShell]::Create() 
[void]$Runspace.AddScript($MakeFunctionSB)
[void]$Runspace.AddScript($UsingFunctionSB) 

$Async = $Runspace.BeginInvoke() 
write-host "We can keep doing stuff now" -ForegroundColor Green

#Retrieve the output
$Runspace.EndInvoke($Async)
$Runspace.Dispose()