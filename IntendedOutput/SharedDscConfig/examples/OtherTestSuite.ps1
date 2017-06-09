$here = if(!$PSScriptRoot) { $Pwd.path } else {$PSScriptRoot}
#load the Shared configuration module1
Import-Module "$here\..\SharedDscConfig.psd1"

# load the Configuration Property resolver
. $here/scripts/Resolve-DscConfigurationData.ps1

#Load configuration Data
$ConfigurationData = Import-PowerShellDataFile $here\..\ConfigurationData\OtherTestSuite\OtherTestSuite.psd1

#using that shareable configuration is now possible
# Test-Kitchen will call the configuration name to generate the MOF automatically
if (!$Env:TEST_KITCHEN) {
    SharedDscConfig -ConfigurationData $ConfigurationData -instanceName
}
