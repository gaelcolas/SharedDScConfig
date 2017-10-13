@{
    PSDependOptions = @{
        AddToPath = $True
        Target = 'Resources'
        Parameters = @{
            #Force = $True
            #Import = $True
        }
    }

    'gaelcolas/Chocolatey' = 'master'
}