#Requires -Modules InvokeBuild
Param (
    [String]
    $BuildOutput = "$PSScriptRoot\BuildOutput",

    [String[]]
    $GalleryRepository, #used in ResolveDependencies, has default

    [Uri]
    $GalleryProxy, #used in ResolveDependencies, $null if not specified

    [Switch]
    $ForceEnvironmentVariables = [switch]$true
)
if ((Get-PSCallStack)[1].InvocationInfo.MyCommand.Name -ne 'Invoke-Build.ps1') {
    Invoke-Build
    return
}

Get-ChildItem -Path "$PSScriptRoot/.build/" -Recurse -Include *.ps1 -Verbose |
    Foreach-Object {
        "Importing file $($_.BaseName)" | Write-Verbose
        . $_.FullName 
    }

task . Clean,
        ResolveDependencies,
        Invoke-DscBuild