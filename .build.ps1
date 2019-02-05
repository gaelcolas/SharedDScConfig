[cmdletBinding()]
Param (
    [Parameter(Position=0)]
    $Tasks,

    [switch]
    $ResolveDependency,

    [String]
    $BuildOutput = "BuildOutput",

    [String[]]
    $GalleryRepository,

    [Uri]
    $GalleryProxy,

    [Switch]
    $ForceEnvironmentVariables = [switch]$true,

    $MergeList = @('enum*',[PSCustomObject]@{Name='class*';order={(Import-PowerShellDataFile .\SampleModule\Classes\classes.psd1).order.indexOf($_.BaseName)}},'priv*','pub*')

    ,$CodeCoverageThreshold = 90
)

Process {
    if ($MyInvocation.ScriptName -notlike '*Invoke-Build.ps1') {
        if ($PSboundParameters.ContainsKey('ResolveDependency')) {
            Write-Verbose "Dependency already resolved. Skipping"
            $null = $PSboundParameters.Remove('ResolveDependency')
        }
        Invoke-Build $Tasks $MyInvocation.MyCommand.Path @PSBoundParameters
        return
    }

    Get-ChildItem -Path "$PSScriptRoot/.build/" -Recurse -Include *.ps1 -Verbose |
        Foreach-Object {
            "Importing file $($_.BaseName)" | Write-Verbose
            . $_.FullName
        }

    task . DscClean,LoadResource,LoadConfigurations

    task DscClean {
        if(![io.path]::IsPathRooted($BuildOutput)) {
            $BuildOutput = Join-Path $PSScriptRoot $BuildOutput
        }
        Get-ChildItem -Path $BuildOutput -Recurse | Remove-Item -force -Recurse -Exclude README.md
    }

    task Noop { }

    task dsc {
        . $PSScriptRoot\SharedDscConfig\examples\init.ps1
    }

    task LoadResource {
        $PSDependResourceDefinition = '.\PSDepend.resources.psd1'
        if(Test-Path $PSDependResourceDefinition) {
            Invoke-PSDepend -Path $PSDependResourceDefinition -Confirm:$False
        }
    }

    task LoadConfigurations {
        $PSDependConfigurationDefinition = '.\PSDepend.configurations.psd1'
        if(Test-Path $PSDependConfigurationDefinition) {
            Invoke-PSDepend -Path $PSDependConfigurationDefinition -Confirm:$False
        }
    }

}


begin {

    if (![io.path]::IsPathRooted($BuildOutput)) {
        $BuildOutput = Join-Path -Path $PSScriptRoot -ChildPath $BuildOutput
    }

    if(($Env:PSModulePath -split ';') -notcontains (Join-Path $BuildOutput 'modules') ) {
        $Env:PSModulePath = (Join-Path $BuildOutput 'modules') + ';' + $Env:PSModulePath
    }

    function Resolve-Dependency {
        [CmdletBinding()]
        param()

        if (!(Get-PackageProvider -Name NuGet -ForceBootstrap)) {
            $providerBootstrapParams = @{
                Name = 'nuget'
                force = $true
                ForceBootstrap = $true
            }
            if($PSBoundParameters.ContainsKey('verbose')) { $providerBootstrapParams.add('verbose',$verbose)}
            if ($GalleryProxy) { $providerBootstrapParams.Add('Proxy',$GalleryProxy) }
            $null = Install-PackageProvider @providerBootstrapParams
            Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        }

        if (!(Get-Module -Listavailable PSDepend)) {
            Write-verbose "BootStrapping PSDepend"
            "Parameter $BuildOutput"| Write-verbose
            $InstallPSDependParams = @{
                Name = 'PSDepend'
                AllowClobber = $true
                Confirm = $false
                Force = $true
                Scope = 'CurrentUser'
            }
            if($PSBoundParameters.ContainsKey('verbose')) { $InstallPSDependParams.add('verbose',$verbose)}
            if ($GalleryRepository) { $InstallPSDependParams.Add('Repository',$GalleryRepository) }
            if ($GalleryProxy)      { $InstallPSDependParams.Add('Proxy',$GalleryProxy) }
            if ($GalleryCredential) { $InstallPSDependParams.Add('ProxyCredential',$GalleryCredential) }
            Install-Module @InstallPSDependParams
        }

        $PSDependParams = @{
            Force = $true
            Path = "$PSScriptRoot\PSDepend.build.psd1"
        }
        if($PSBoundParameters.ContainsKey('verbose')) { $PSDependParams.add('verbose',$verbose)}
        Invoke-PSDepend @PSDependParams
        Write-Verbose "Project Bootstrapped, returning to Invoke-Build"
    }

    if ($ResolveDependency) {
        Write-Host "Resolving Dependencies... [this can take a moment]"
        $Params = @{}
        if ($PSboundParameters.ContainsKey('verbose')) {
            $Params.Add('verbose',$verbose)
        }
        Resolve-Dependency @Params
    }
}