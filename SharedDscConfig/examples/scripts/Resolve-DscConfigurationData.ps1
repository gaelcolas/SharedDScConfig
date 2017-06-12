function Resolve-DscConfigurationData {
    Param(
        [hashtable]$Node,
        [string]$PropertyPath,
        [AllowNull()]
        $Default
    )

    $paths = $PropertyPath -split '\\'
    $CurrentValue = $Node
    foreach ($path in $Paths) {
        $CurrentValue = $CurrentValue.($path)
    }

    if ($null -eq $CurrentValue -and !$PSBoundParameters.ContainsKey('Default')) {
        Throw 'Property returned $null but no default specify. This is bad practice, as compilation may fail if missing data'
    }
    elseif ($CurrentValue) {
        Write-Output $CurrentValue
    }
    else {
        Write-Output $Default
    }
}
Set-Alias -Name ConfigData -value Resolve-DscConfigurationData
Set-Alias -Name DscProperty -value Resolve-DscConfigurationData