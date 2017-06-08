#Worth noting InvokeBuild supports to attach the Invoke-build.ps1 file in the repo, 
# dot source it and use Invoke-Build alias


# Grab nuget bits, install minimum module
if (!(Get-PackageProvider -Name NuGet -ForceBootstrap)) {
    $null = Install-PackageProvider nuget -force -ForceBootstrap
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}

if(!(Get-Module -listAvailable InvokeBuild )) {
    Install-Module InvokeBuild -ErrorAction Stop -scope CurrentUser -force
}
