#PSDepend dependencies
# Either install modules for generic use or save them in ./modules for Test-Kitchen

@{
    # Set up a mini virtual environment...
    PSDependOptions = @{
        AddToPath = $True
        Parameters = @{
            #Force = $True
            #Import = $True
        }
    }

    buildhelpers = 'latest'
    pester = 'latest'
    PSScriptAnalyzer = 'latest'
    PlatyPS = 'latest'
    psdeploy = 'latest'
    'gaelcolas/DscBuildHelpers' = 'master'
}