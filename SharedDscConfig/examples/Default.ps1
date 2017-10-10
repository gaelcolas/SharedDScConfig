$here = if(!$PSScriptRoot) { "$($Pwd.path)\SharedDscConfig\examples\" } else {$PSScriptRoot}

$ProjectPath = Get-item "$here\..\.."

if($Env:PSModulePath -split ';' -notcontains $ProjectPath) {
    Write-Warning ">>> $ProjectPath"
    $Env:PSModulePath = $Env:PSModulePath +';'+ $ProjectPath.FullName
}
# load the Configuration Property resolver

Import-Module -force Datum -Global
#. $here\scripts\Resolve-DscConfigurationData.ps1
$yml = Get-Content -raw $Here\ConfigData\Datum.yml | ConvertFrom-Yaml

Push-Location $Here
$Global:Datum = New-DatumStructure $yml
$Global:ConfigurationData = @{
    AllNodes = @($Datum.AllNodes.psobject.properties|%{ $Datum.AllNodes.($_.Name)})
    Datum = $Global:Datum
}
#Load configuration Data
#$ConfigurationData = Import-PowerShellDataFile $here\..\ConfigurationData\Default\Default.psd1
#$Node = $ConfigurationData.AllNodes.Where{$_.Nodename -eq 'localhost'}[0]

ipmo -force $here\..\SharedDscConfig.psd1


Configuration Default {
    Import-DSCresource -ModuleName SharedDscConfig
    
    Node $ConfigurationData.AllNodes.NodeName {

        Shared1 SharedConfig_NoParam {
            # When no param specified, the default params will be used
        }

        Shared1 SharedConfig_Param1 {
            Param1 = 'This is the content from the Root configuration'
            DestinationPath = 'C:\Test2.txt' #Using the same file as previous block would fail (2 Resource with same key for same Node)
        }
        Write-Warning ($Node|out-String)
        Write-Warning (Lookup $Node 'Shared1'|out-String)
        
        #Auto lookup Parameters for $node with Configuration
        $Properties = $(Lookup $Node 'Shared1' -DefaultValue @{})
        Get-DscSplattedResource -ResourceName 'Shared1' -ExecutionName 'Shared1' -Properties $Properties
        
        #or in short notation
        #x 'Shared1' 'Shared1' $Properties

    }
}

#using that shareable configuration is now possible
# Test-Kitchen will call the configuration name to generate the MOF automatically
if (!$Env:TEST_KITCHEN) {
    Default -ConfigurationData $ConfigurationData -OutputPath DscBuildOutput\
}
