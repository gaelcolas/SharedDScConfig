$here = if(!$PSScriptRoot) { $Pwd.path } else {$PSScriptRoot}
#load the Shared configuration module1
Import-Module "$here\..\SharedDscConfig.psd1"

# load the Configuration Property resolver
. $here/scripts/Resolve-DscConfigurationData.ps1

#Load configuration Data
$ConfigurationData = Import-PowerShellDataFile $here\..\ConfigurationData\OtherTestSuite\OtherTestSuite.psd1
$Node = $ConfigurationData.AllNodes.Where{$_.Nodename -eq 'localhost'}[0]

Configuration OtherTestSuite {
    Import-DSCresource -ModuleName PSDesiredStateConfiguration

    node $AllNodes.Nodename {

        $MySharedDscConfig = @{
            #add parameter here if you need
        }

        SharedDscConfig @MySharedDscConfig
    }
}


#using that shareable configuration is now possible
# Test-Kitchen will call the configuration name to generate the MOF automatically
if (!$Env:TEST_KITCHEN) {
    OtherTestSuite -ConfigurationData $ConfigurationData -instanceName
}
