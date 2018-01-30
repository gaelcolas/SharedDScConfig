Configuration SoftwareBase {
    Param(
        $PackageFeedUrl = 'https://chocolatey.org/api/v2',
        $Sources = @(),
        $ChocolateyLicenseXml,
        $Settings = @(),
        $Features = @(),        
        $Packages = @()
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName Chocolatey -ModuleVersion 0.0.46
    
    # Install Choco Software if not present
    ChocolateySoftware ChocoInstall {
        Ensure = 'Present'
        PackageFeedUrl = $PackageFeedUrl
    }

    # Configure Choco Sources to pull packages from
    foreach($source in $Sources) {
        if(!$source.Ensure) { $source.add('Ensure', 'Present') }
        (Get-DscSplattedResource -ResourceName 'ChocolateySource' -ExecutionName "$($Source.Name)_src" -Properties $source -NoInvoke).Invoke($Source)
    }

    if ($ChocolateyLicenseXml) {
        File ChocolateyLicense {
            Ensure = 'Present'
            Contents = $ChocolateyLicenseXml
            DestinationPath = 'C:\ProgramData\chocolatey\license\chocolatey.license.xml'
            Type = 'File'
            Force = $true
        }

        # If Choco is licensed, install Choco extension to enable Business Features
        if($ChocoExtension = $Packages.Where{$_.Name -eq 'chocolatey.extension'}[0]) {
            if(!$ChocoExtension.Ensure) {$ChocoExtension.Add('Ensure','present')}
            if(!$ChocoExtension.Version) {$ChocoExtension.Add('Version','latest')}
            (x ChocolateyPackage 'ChocoExtension' $ChocoExtension -NoInvoke).Invoke($ChocoExtension)
            # Remove the Chocolatey Extension from the $Packages list if present
            $Packages = $Packages.Where{$_.Name -ne 'chocolatey.extension'}
        }
        else {
            # Install Default Extension if LIcensed and not specified
            ChocolateyPackage ChocoExtension {
                Ensure = 'Present'
                Version = 'latest'
                Name = 'Chocolatey.Extension'
                DependsOn = '[File]ChocolateyLicense'
            }
        }
    }

    # Configure Choco Settings
    foreach ($Setting in $Settings) {
        if(!$Setting.Ensure) {$Setting.Add('Ensure','Present')}
        (x ChocolateySetting "$($Setting.Name)_set" $Setting -NoInvoke).Invoke($Setting)
    }

    # Configure Choco Features
    foreach ($Feature in $Features) {
        if(!$Feature.Ensure) {$Feature.Add('Ensure','Present')}
        (x ChocolateyFeature "$($Feature.Name)_Ftr" $Feature -NoInvoke).Invoke($Feature)
    }

    foreach ($Package in $Packages) {
        if(!$Package.Ensure) { $Package.add('Ensure','Present') }
        if(!$Package.Version) { $Package.add('version', 'latest') }
        (Get-DscSplattedResource -ResourceName ChocolateyPackage -ExecutionName "$($Package.Name)_pkg" -Properties $Package -NoInvoke).Invoke($Package)
    }
}