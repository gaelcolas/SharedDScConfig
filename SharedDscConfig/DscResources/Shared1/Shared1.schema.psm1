Configuration Shared1 {
    Param(
        $Param1 = 'Param from config',
        $DestinationPath = 'C:\test.txt'
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    
    File TestFile {
        Ensure          = 'Present'
        DestinationPath = $DestinationPath
        Contents        = $Param1
    }

    ChocolateyInstall InstallChoco {
        Ensure = 'Present'
    }
}