#region Load GUI
#Add WPF assemblies
Add-Type -AssemblyName PresentationCore,PresentationFramework

#Cleanup XAML options
$XAML= [XML](Get-Content -Path "$PSScriptRoot\GUI.xaml" -Raw)
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
$GUI = @{}
$namedNodes = $XAML.SelectNodes("//*[@x:Name]",$XmlNamespaceManager)
$namedNodes | ForEach-Object -Process {$GUI.Add($_.Name, $Rawform.FindName($_.Name))}
#endregion Load GUI

$syncHash = [hashtable]::Synchronized($GUI)
$InitialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault() 
$sessionVariable = [System.Management.Automation.Runspaces.SessionStateVariableEntry]::new("syncHash", $syncHash, $null)
$InitialSessionState.Variables.Add($sessionVariable) 
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


# $counter = 1
# $buttonCode = {
#     #$syncHash["Block2"].Text = $counter
#     $syncHash["Block2"].Dispatcher.invoke([action]{$syncHash["Block2"].Text = $counter},"Normal")
#     $counter++
# }
# $syncHash["button1"].add_click($buttonCode)

$syncHash["Block1"].Text = "testing"

$Runspace2.BeginInvoke()
$Runspace.BeginInvoke()

$syncHash["window"].ShowDialog()

<#
$newRunspace =[runspacefactory]::CreateRunspace()
$newRunspace.ApartmentState = "STA"
$newRunspace.ThreadOptions = "ReuseThread"         
$newRunspace.Open()
$newRunspace.SessionStateProxy.SetVariable("syncHash",$syncHash)          
$psCmd = [PowerShell]::Create().AddScript({   
    [xml]$xaml = @"
    <Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        x:Name="Window" Title="Initial Window" WindowStartupLocation = "CenterScreen"
        Width = "600" Height = "800" ShowInTaskbar = "True">
        <TextBox x:Name = "textbox" Height = "400" Width = "600"/>
    </Window>
"@
  
    $reader=(New-Object System.Xml.XmlNodeReader $xaml)
    $syncHash.Window=[Windows.Markup.XamlReader]::Load( $reader )
    $syncHash.TextBox = $syncHash.window.FindName("textbox")
    $syncHash.Window.ShowDialog() | Out-Null
    $syncHash.Error = $Error
})
$psCmd.Runspace = $newRunspace
$data = $psCmd.BeginInvoke()

[String]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation">
    <Grid>
        <Label FontSize="100" Name="Text" /> 
    </Grid>
</Window>
"@

$Window = [Windows.Markup.XamlReader]::Parse($xaml)

$Text = $Window.Content.FindName("Text")
$Text.Content = "👋, from WPF!"

$Window.ShowDialog()
#>