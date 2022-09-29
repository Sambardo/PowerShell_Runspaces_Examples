$PowerShell = [powershell]::Create()
$PowerShell.AddScript(
{
    $count = 0
    do 
    {    
        $count+=1
        Start-Sleep -Seconds 1
        $count+=2
        Start-Sleep -Seconds 1
        $count+=3
    }while($true )
})
$async = $PowerShell.BeginInvoke()
Debug-Runspace $PowerShell.Runspace

$PowerShell.Dispose()