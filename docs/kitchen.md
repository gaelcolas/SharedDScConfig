# Using Test-Kitchen

Here's some information about using Test-Kitchen with this layout.

The goal behind this setup is to follow the best practices outlined in [The Release Pipeline Model](https://aka.ms/TRPM).

Although this project does not rely on test-kitchen, it is my current tool of choice for TDD of Policy-Driven Infrastructure, as it [drastically improves the feedback loop](./FeedbackLoop.md), so I want to keep it compatible by either adapting the project, or adapting the test-kitchen components (i.e. kitchen-dsc).

Test-Kitchen is a tool that enables a TDD workflow with quick iterations, while __abstracting the platform__ it runs on, by use of its different drivers: vagrant, vSphere, HyperV, Docker, Azure, EC2 and so on...

## Implementation

I explain in more details the [kitchen configuration composition in this linked page](./ComposingKitchenYmls.md), but here's the highlight of the implementation.

The way test-kitchen works with this configuration is as follow:
- it uses a `.kitchen.global.yml` (in my case) configuration for the driver (which depends on the environment. On my laptop I use Hyper-V, vsphere at work...)
- the repository's `.kitchen.yml` defines the project specific configuration (what are the test suites, the Dsc configuration scripts, the path to the pester tests...)
- I sometimes use a `.kitchen.local.yml`, to override some configuration during development (i.e. when I want to try a new image I created or tweaked, without affecting other users)

This is controlled by some tweaks in my profile, changing some variables used by Test-Kitchen.

## PS Profile tweaks

```PowerShell
$Env:KITCHEN_GLOBAL_YAML = "C:\src\.kitchen.global.yml"
$Env:KITCHEN_LOCAL_YAML = '.kitchen.local.yml'

$vmTemplateCred = import-clixml $Profile\..\vmTemplateCred
$Env:vmusername = $vmTemplateCred.Username
$Env:vmpassword = $vmTemplateCred.GetNetworkCredential().Password
```

## 