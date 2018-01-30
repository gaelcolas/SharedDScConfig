Configuration Shared1 {
    Param(
        $Param1 = 'Param from config',
        $DestinationPath = 'C:\test.txt'
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    
    File "TestFile_$(1..999|Get-Random)" {
        Ensure          = 'Present'
        DestinationPath = $DestinationPath
        Contents        = $Param1
    }

}