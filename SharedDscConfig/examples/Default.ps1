# if(!$PSScriptRoot) {$here = "$($Pwd.path)\SharedDscConfig\examples\" } else {$here = $PSScriptRoot}
# . .\SharedDscConfig\examples\init.ps1

Import-Module -force Datum -Global -errorAction Stop

$DatumConfig = Join-Path  $PSScriptRoot "ConfigData\Datum.yml"
Write-Warning "Loading $DatumConfig"

$Global:Datum = New-DatumStructure -definitionFile $DatumConfig

$AllNodes = @($Datum.TestSuites.psobject.Properties | ForEach-Object { 
    $Node = $Datum.TestSuites.($_.Name)
    if(!$Node.contains('Name') ) {
        $null = $Node.Add('Name',$_.Name)
    }
    (@{} + $Node) #Remove order & Case Sensitivity
})

$Global:ConfigurationData = @{
    AllNodes = $AllNodes
    Datum = $Global:Datum
}

#ipmo -force $here\..\SharedDscConfig.psd1


Configuration Default {
    Import-DSCresource -ModuleName SharedDscConfig
    
    Node $ConfigurationData.AllNodes.NodeName {

        # When no param specified, the default params will be used
        Shared1 SharedConfig_NoParam {}

        #Specifying a parameter the traditional way
        Shared1 SharedConfig_Param1 {
            Param1 = 'This is the content from the Root configuration. Traditional approach'
            DestinationPath = 'C:\Test_2.txt' #Using the same file as previous block would fail (2 Resource with same key for same Node)
        }

        #Write-Warning ($Node|out-String)
        $(Write-Warning "Shared1 Parameters: $(Lookup 'Shared1'|Convertto-Json)")
        
        #Auto lookup Parameters for $node with Configuration
        $Properties = $(Lookup 'Shared1')
        (Get-DscSplattedResource -ResourceName 'Shared1' -ExecutionName 'Shared1_FromNodeBlock' -Properties $Properties -NoInvoke).Invoke($Properties)

        #Auto lookup configurations for that node, and foreach of them, look for its params and splat them
        (Lookup Configurations).Foreach{
            $ConfigName = $_
            $Properties = Lookup $ConfigName -DefaultValue @{}
            (x $ConfigName $ConfigName $Properties -NoInvoke).Invoke($Properties)
        }
    }
}

#using that shareable configuration is now possible
# Test-Kitchen will call the configuration name to generate the MOF automatically
if (!$Env:TEST_KITCHEN) {
    Default -ConfigurationData $ConfigurationData -OutputPath DscBuildOutput\
}
