$here = if(!$PSScriptRoot) { $Pwd.path } else {$PSScriptRoot}
#load the Shared configuration module1
#Import-Module $here\..\SharedDscConfig.psd1 -Verbose -force

# load the Configuration Property resolver
. $here\scripts\Resolve-DscConfigurationData.ps1

#Load configuration Data
$ConfigurationData = Import-PowerShellDataFile $here\..\ConfigurationData\Default\Default.psd1

$SharedConfigurations = get-module $here\SharedDscConfig\SharedDscConfig.psd1 -ListAvailable


. $here\..\SharedDscConfig.ps1

Configuration Default {
    #Import-DSCresource -ModuleName PSDesiredStateConfiguration
    $SharedConfigurations.RequiredModules | % {
        ""
    }

    node $AllNodes.Nodename {

        #SharedDscConfig -blah 'a'
        $MySharedDscConfig = @{
            blah = 'c'
        }

        SharedDscConfig @MySharedDscConfig

        #SharedDscConfig 'c'
        
        #SharedDscConfig Test {
        #    Blah = 'b'
        #}
    }
}


#using that shareable configuration is now possible
# Test-Kitchen will call the configuration name to generate the MOF automatically
if (!$Env:TEST_KITCHEN) {
    Default -ConfigurationData $ConfigurationData
}
