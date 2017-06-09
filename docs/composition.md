# DSC Configuration Granularity


DSC offers different ways of abstraction and composability ([see examples here](./ResourceAndConfigs.md) or follow the link to documentation).

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

So the way to package some configuration to be re-used, is via Composite Resource.
In the end, those are just Configuration Packaged in a certain way.
