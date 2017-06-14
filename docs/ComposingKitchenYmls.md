
# Composing Kitchen YAMLs

I [already Blogged about the architecture of the Yaml configuration files](https://gaelcolas.com/2016/07/11/introduction-to-kitchen-dsc/#kitchenyml), but the rough idea is at it segments the following:
- Driver: Virtualization/Cloud/Containerization management config for nodes to test on (SUT)
- Transport: Protocol (Ssh or WinRM) Test-kitchen uses to communicate with the SUT
- Provisioner: Mechanism to apply the configuration (DSC but could be Chef/Puppet/Ansible...)
- verifier: Tool that will be run to validate the applied configuration (Pester, Inspec...)
- Platforms: each platforms you want the test suites to run on (i.e. Win2016,2012R2,Win10...)
- suites: Different test cases you setup for your configurations on different nodes. Configurations are matched with their tests (so the `Default` configuration will apply, then the `Default` test will run to validate)


On a side note, the `Platforms x suites = test matrix` to run.

>If you have 3 Platforms, and 1 test suites, you'll have 3 test cases.

>If you have 3 platforms, and 2 test suites, you'll end up with 6 test cases.

## Composing Kitchen YAMLs

The problem with defining every bits into a single .kitchen.yml configuration file in the repository, is that some information is specific to your environment (the driver depends on where you want to create your SUTs: HyperV, Vagrant...), while some are specific to your project (where to find the DSC configuration script to run to generate the MOF).

The neat thing about kitchen yamls, is that you can split them in 3 different layers that are merged at runtime, by changing where Test-Kitchen will look for those layers via use of Environment variables.

One way to go about this is to define the following:
- Point the Global YAML configuration to a .kitchen.global.yml that has only the Driver configuration. (For instance, I set it at User level to use the vsphere instance at work, and Hyper-V on my laptop). I set the `$Env:KITCHEN_GLOBAL_YAML = "C:\Users\$Env:USERNAME\kitchen.global.yml"` in my PS Profile.
- The [standard YAML configuration `.kitchen.yml` ](./.kitchen.yml)  which defines project-specific information should ommit the driver block (as it changes from environment to environment), but should be committed in the repository (so if I have a globally defined driver, I can run the test suites as intended)
- The Local yaml `.kitchen.local.yml`, when it exists, can override any of the above. This is useful during development when you want to override some settings, without affecting others working on the same project. That one should not be committed to source control. You set this by doing `$Env:KITCHEN_LOCAL_YAML= '.kitchen.local.yml'`

However, you can leverage the same principle when you want to overrides some project specific information for specific environment. The Chef community sometimes creates a `.kitchen.azure.yml` for setting Azure specific information when the build runs in (or against) Azure.
The build script or CI tool uses conditional statement so that for instance:
```PowerShell
switch ($Env:BHBuildSystem) { # using BuildHelpers module
    'appveyor' { `$Env:KITCHEN_LOCAL_YAML= '.kitchen.azure.yml'` }
    # ... 
    default {`$Env:KITCHEN_LOCAL_YAML= '.kitchen.local.yml'` }
}
```
