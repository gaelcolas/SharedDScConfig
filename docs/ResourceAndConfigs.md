# Example of DSC Policy building blocks

## Resource

Resources are packaged within a Module, and are composed of the usual Get/Set/Test methods/functions, doing the actual work.
Those can offload parts of the processing to other functions, and it's recommended to keep the code DRY.
Within a Module's `DSCResources` Folder, under a `Resource` sub-folder, you'd find the following two files at least.

```PowerShell
# Resource.psm1
function Get-TargetResource
{
    ...
}

function Set-TargetResource
{
    ...
}

function Test-TargetResource
{
    ...
}
```

Along with a Schema.Mof

```PowerShell
# Resource.schema.mof
[ClassVersion("1.0.0.0"), FriendlyName("Resource")]
class Resource : OMI_BaseResource
{
    [Key, Description("Present or Absent?"), ValueMap{"Present","Absent"}, Values{"Present","Absent"}] String Ensure;
};
```

## Configuration

A configuration looks like a function, but with some convention-based specificities:
- Configuration Keyword
- an Import-DscResource keyword (context-sensitive!)
- Parameters (Optional)
- Node block (Optional)

```PowerShell
Configuration Module {
    Import-DscResource -Name Resource

    Node localhost {
        Resource MySampleResource {
            Ensure = 'Present'
        }
    }
}
```

## Composite Configuration

The composite configuration is a when a Configuration calls another one, also called sometime nested configuration.
The example from technet is quite explicit, for our example that'd be:
```PowerShell
# in a single script
Configuration MySubConfig {
    Param(
        [Parameter(Mandatory)]
        [ValidateSet('Absent','Present')]
        [String]$Ensure
    )
    Import-DscResource -Name Resource

    Resource MySampleResource {
        Ensure = 'Present'
    }
}

Configuration CompositeConfig
{
#  ...
    Node localhost {
        MySubConfig UsingNestedConfig {
            Ensure = 'Absent'
        }
    }
}

```


## Composite Resource

Those look like packaged composite Configuration, leveraging several Resources together by declaring how to use them, but allowing that configuration to be used and declared within a Configuration Script, as layer of abstraction.

As an example of a CompositeResource re-using the above resource, you'd have within a Module's `DSCResources` Folder, under a `CompositeResource` sub-folder, the following two files (note the difference in name/extension).

```PowerShell
# CompositeResource.psd1
@{

# Script module or binary module file associated with this manifest.
RootModule = 'CompositeResource.schema.psm1'

# Version number of this module.
ModuleVersion = '0.0.0.1'

# ID used to uniquely identify this module
GUID = 'e39521c2-9a27-4e6b-9014-f57ad72d8577'
}
```
and
```PowerShell
# CompositeResource.schema.psm1
Configuration CompositeResource
{
    param (

        [Parameter(Mandatory)]
        [ValidateSet('Absent','Present')]
        [String]$Ensure
    )

    Import-DscResource -ModuleName Resource

    Resource MyTestResource {
        Ensure = $Ensure
    }
    # ...
}
```
In a configuration document you'd use it likeso:
```PowerShell
Configuration UsingMyCompositeResource
{
#  ...
    Node localhost {
        CompositeResource MyInstanceOfIt {
            Ensure = 'Absent'
        }
    }
}

```