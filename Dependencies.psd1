#PSDepend dependencies
# Either install modules for generic use or save them in ./modules for Test-Kitchen

@{
    # Set up a mini virtual environment...
    PSDependOptions = @{
        AddToPath = $True
        Target = 'DscBuildOutput\modules'
        Parameters = @{
            #Force = $True
            #Import = $True
        }
    }

    invokeBuild = 'latest'
    'powershell-yaml' = 'latest'
    buildhelpers = 'latest'
    pester = 'latest'
    PSScriptAnalyzer = 'latest'
    PlatyPS = 'latest'
    psdeploy = 'latest'
    'gaelcolas/DscBuildHelpers' = 'master'
    'gaelcolas/Datum' = 'master'
    
}