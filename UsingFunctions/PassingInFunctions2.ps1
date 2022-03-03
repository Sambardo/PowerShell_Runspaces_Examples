<#Pass in the entire script you plan to run#>
$SB = {
    Function SomeTestFunction
    {
        "Hello World"
    }

    "Running the function"
    SomeTestFunction
}

$Runspace = [PowerShell]::Create() 
[void]$Runspace.AddScript($SB)
$Async = $Runspace.BeginInvoke() 
write-host "We can keep doing stuff now" -ForegroundColor Green

#Retrieve the output
$Runspace.EndInvoke($Async)
$Runspace.Dispose()