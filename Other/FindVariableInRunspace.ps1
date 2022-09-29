$powershell = [powershell]::Create()
$powershell.AddScript({
    $var = "My Var"
})
$a = $powershell.BeginInvoke()


$Powershell.Runspace.SessionStateProxy.PSVariable.get("var")

$powershell.EndInvoke($a)
$powershell.Dispose()