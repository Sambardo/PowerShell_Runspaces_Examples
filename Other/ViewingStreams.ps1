$PowerShell = [PowerShell]::Create()
$powershell.AddScript(
{
    #streams don't all show by default
    $VerbosePreference = "continue"
    $WarningPreference = "continue" #Warnign stream has output issues, see later comments
    $DebugPreference = "continue"

    write-verbose -Message "Some verbose junk"
    Write-debug -Message "some debug junk"
    write-warning -Message "some warning"
    write-information -Message "some informatrion"
    write-error -Message "some error"
})
$PowerShell.Invoke() 
$PowerShell.Streams 
#Warning doesn't show up for some reason, without specifying $PowerShell.Streams.Warning
$PowerShell.Dispose()