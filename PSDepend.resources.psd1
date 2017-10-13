@{
    PSDependOptions = @{
        AddToPath = $True
        Target = 'RequiredResources'
        Parameters = @{
            #Force = $True
            #Import = $True
        }
    }

    'gaelcolas/Chocolatey' = 'master'
}