#Trying GUI in own runspace + other runspace for chanigng values -- works
#GUI button code to change property at same time -- works
#Same issue as without GUI runspace, it hangs or lags or something on update. Try more options

$syncHash = [hashtable]::Synchronized(@{})
$syncHash["GUIXAML"] = $PSScriptRoot
$InitialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault() 
$InitialSessionState.ApartmentState = "STA"
$sessionVariable = [System.Management.Automation.Runspaces.SessionStateVariableEntry]::new("syncHash", $syncHash, $null)
$InitialSessionState.Variables.Add($sessionVariable) 

$GUIRunspace = [PowerShell]::Create($InitialSessionState)
#<#
$GUIRunspace.AddScript({
    #region Load GUI
    #Add WPF assemblies
    Add-Type -AssemblyName PresentationCore,PresentationFramework

    #Cleanup XAML options
    $XAML= [XML](Get-Content -Path "$($syncHash["GUIXAML"])\GUI.xaml" -Raw)
    $XAML.Window.RemoveAttribute('x:Class')
    $XAML.Window.RemoveAttribute('xmlns:local')
    $XAML.Window.RemoveAttribute('xmlns:d')
    $XAML.Window.RemoveAttribute('xmlns:mc')
    $XAML.Window.RemoveAttribute('mc:Ignorable')

    #read XML as XAML
    $XAMLreader = New-Object System.Xml.XmlNodeReader $XAML
    $Rawform = [Windows.Markup.XamlReader]::Load($XAMLreader) 

    #add XML namespace manager
    $XmlNamespaceManager = [System.Xml.XmlNamespaceManager]::New($XAML.NameTable)
    $XmlNamespaceManager.AddNamespace('x','http://schemas.microsoft.com/winfx/2006/xaml')

    #Create hash table containing a representation of all controls
    $namedNodes = $XAML.SelectNodes("//*[@x:Name]",$XmlNamespaceManager)
    $namedNodes | ForEach-Object -Process {$syncHash.Add($_.Name, $Rawform.FindName($_.Name))}
    #endregion Load GUI
    #$syncHash["window"].Dispatcher.invoke([action]{$syncHash["window"].ShowDialog()},"Normal")

    #TEST
    $counter = 1
    $buttonCode = {
        #$syncHash["Block2"].Text = $counter
        $counter=$script:counter
        $syncHash["Block2"].Dispatcher.invoke([action]{$syncHash["Block2"].Text = $counter},"Normal")
        $script:counter++
    }
    $syncHash["button1"].add_click($buttonCode)

    $syncHash["window"].ShowDialog()
    #$syncHash
    #$error[($error.count - 1)]
})#>

$Runspace = [PowerShell]::Create($InitialSessionState)
#$Runspace.SessionStateProxy.SetVariable("syncHash",$syncHash)
$Runspace.AddScript({
    #$syncHash["Block2"].Text = "testing"
    foreach($i in 1..100)
    {
        Start-Sleep -Seconds 1
        $syncHash["Block1"].Dispatcher.invoke([action]{$syncHash["Block1"].Text = $i},"Normal")
    }
})

$Runspace2 = [PowerShell]::Create($InitialSessionState)
$Runspace2.AddScript({
    foreach($i in 1..100)
    {
        Start-Sleep -Seconds 1
        $syncHash["Block2"].Dispatcher.invoke([action]{$syncHash["Block2"].Text = $i},"Normal")
    }
})

$GUIRunspace.BeginInvoke()
$Runspace.BeginInvoke()
#$Runspace2.BeginInvoke()

<#
$a = $GUIRunspace.BeginInvoke()
$e = $GUIRunspace.EndInvoke($a)
#$GUIRunspace.Streams.Error

$GUIRunspace | FL *
$GUIRunspace.Runspace | FL *
$e | FL * -force
#>