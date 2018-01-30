$ProjectPath = Get-item "$PSScriptRoot\..\.."

if($Env:PSModulePath -split ';' -notcontains $ProjectPath) {
    Write-Warning ">>> Adding $ProjectPath to `$Env:PSModulePath"
    $Env:PSModulePath = $Env:PSModulePath +';'+ $ProjectPath.FullName
}

#Now that the Variable has been set, you can call the DSC Test
. $PSScriptRoot\Default.ps1
