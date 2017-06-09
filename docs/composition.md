# DSC Configuration Granularity


DSC offers different ways of abstraction and composability (quick overview below).

- [Resource](https://msdn.microsoft.com/en-us/powershell/dsc/authoringresourcemof) (or [class based](https://msdn.microsoft.com/en-us/powershell/dsc/authoringresourceclass))
- [Configuration](https://msdn.microsoft.com/en-us/powershell/dsc/configurations)
- [Composite Configuration](https://msdn.microsoft.com/en-us/powershell/dsc/compositeconfigs)
- [Composite Resource](https://msdn.microsoft.com/en-us/powershell/dsc/authoringresourcecomposite)

And here's a rule of thumb on how you can compose them:
- If you need to manage something that does not have a resource for it already, go with a custom resource (and share it if makes sense!)
- If a resource exist but is missing feature, consider contributing directly
- if you want to have a higher level abstraction:
    - Start by composing the resource in a Configuration
    - When you need to improve visibility, subdivide the configuration with nesting
    - if you need to re-use component of the sub configuration, refactor in Composite Resource

**Always** remember that the goal of DSC is to create a human-readable Policy document that give a good idea of the current configuration, at least for the layer of abstraction you're looking at.
The layers you create are there to contain change within a manageable scope, so that they are decoupled from one another.

One way to compose Node configuration from different sub-configurations is to use a root configuration that dot source the sub-configurations and call the nested configuration function, as per the [ticketmaster example by Mike Walker](https://github.com/Ticketmaster/DscExamples/blob/master/NestedConfigs/RootConfiguration.ps1)

Although it may look like the best option, it has severe drawbacks:
- It does not allow using the DSL syntax (hiding away the policy)
- it forces you to Import the DSC resources in the Root configuration (has to be constant)

```PowerShell
. $here\..\SharedDscConfig.ps1

Configuration Default {
    
    #The 'parameter' for ModuleName can't be a variable here
    # and the import in sub-resources are ignored
    Import-DSCresource -ModuleName PSDesiredStateConfiguration

    node $AllNodes.Nodename {
        #This is ok
        SharedDscConfig -blah 'a'
        
        #This is the best declarative syntax we can do
        $MySharedDscConfig = @{
            blah = 'c'
        }
        SharedDscConfig @MySharedDscConfig

        #this does not work (unless the SharedDscConfig is in the same file)
        #dot sourcing does not work either
        #SharedDscConfig Test {
        #    Blah = 'b'
        #}
    }
}
```

---

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