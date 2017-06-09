Configuration SharedDscConfig {
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    File TestFile {
        Ensure          = DscProperty $Node 'Roles\SharedDscConfig\Ensure'
        DestinationPath = DscProperty $Node 'Roles\SharedDscConfig\DestinationPath'
        Contents        = DscProperty $Node 'Roles\SharedDscConfig\Contents'
    }
}