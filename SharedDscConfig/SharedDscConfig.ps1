Configuration SharedDscConfig {
    Param($blah)
    #Import-DSCresource -ModuleName PSDesiredStateConfiguration
    Write-host (DscProperty $Node 'Roles\SharedDscConfig\Ensure')
    Write-host ($blah)
    #node $AllNodes.Where{$_.MemberOfRoles -contains 'SharedDscConfig'}.NodeName {
        File TestFile {
            Ensure          = DscProperty $Node 'Roles\SharedDscConfig\Ensure'
            DestinationPath = DscProperty $Node 'Roles\SharedDscConfig\DestinationPath'
            Contents        = DscProperty $Node 'Roles\SharedDscConfig\Contents'
        }
    #}
}