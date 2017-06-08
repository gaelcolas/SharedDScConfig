Configuration SharedDscConfig {
    Import-DSCresource -ModuleName PSDesiredStateConfiguration

    node $AllNodes.Where{'SharedDscConfig' -in $_.Role}.NodeName {
        File TestFile {
            Ensure = DscProperty 'Role\SharedDscConfig\Ensure'
        }
    }
}