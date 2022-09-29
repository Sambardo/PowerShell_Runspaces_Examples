#Got GUI to run in it's own runspace, apartment state needed to be STA. 
#Next steps to try multiple runspaces talking to eachother

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
    $syncHash["window"].ShowDialog()
    #$syncHash
    #$error[($error.count - 1)]
})#>

<#
$GUIRunspace.AddScript({
    "testing"
    $syncHash["GUIXAML"]
})
#>
$a = $GUIRunspace.BeginInvoke()
$e = $GUIRunspace.EndInvoke($a)
#$GUIRunspace.Streams.Error

$GUIRunspace | FL *
$GUIRunspace.Runspace | FL *
$e | FL * -force