<#
Using one big scriptblock to accomplish what you need is an easy was to pass in data
#>

$MakeFunctionSB = {
    param($Data)
    Function SomeTestFunction
    {
        param($msg)
        "Hello $msg"
    }

    SomeTestFunction -msg $data
}

$MyData = "Everyone"

$Runspace = [PowerShell]::Create() 
[void]$Runspace.AddScript($MakeFunctionSB).AddArgument($MyData)

$Async = $Runspace.BeginInvoke() 
write-host "We can keep doing stuff now" -ForegroundColor Green

#Retrieve the output
$Runspace.EndInvoke($Async)
$Runspace.Dispose()