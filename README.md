# Shared Dsc Configurations

This project is intended to suggest a new structure for sharing DSC Configuration, taking most of the ideas from Michael Greene in [the dscconfigurations repo](https://github.com/powershell/dscconfigurations).

## Intent

The intent is to have a more familiar structure to standard PowerShell modules. Not only this would help user adoption by
reducing the bar of entry, it would allow Build tools, tasks and scripts to be more standardized and re-usable.

- Allow direct re-use in Production (no copy-paste/modification of DSC Config or data)()
- Declare Dependencies in Module Manifest for Pulling requirements from gallery
- Reduce bar of entry with familiar scaffolding
- Embed test/default Configuration Data
- Be CI/CD tool independant
- Support test-kitchen model (i.e. module injection, Test Suite)
- De-Clutter module once published to Gallery (i.e. Removing .Build files)

## Decisions made

### Repository Structure
The Shared Configuration should be self contained, but will require files for building/testing or development.
The repository will hence need some project files on top of the files required for functionality.

Adopting the 2 layers structure like so:
```
+-- ConfigurationName\
    +-- ConfigurationName\
```
Allows to place Project files like build, CI configs and so on at the top level, ad everything under the second level are required files that will be uploaded to the PSGallery.

![example](.\media\FileTree.png)

Within that second layer, the Configuration looks like a standard module with some specificities, the benefits are multiple:
- Familiar module layout
- easy packaging
- Explicit dependencies in psd1 (pull all in one command from gallery)
- Metadata for gallery search


### Configuration Data

This is, to me, the most important, and also the trickiest to do right.

The configuration data, IMO, should be managed in a 'override-only' way to preserve the cattle vs pet case. That is: everything is standard (the standard/best practice data being shared along the configuration script), but can be overriden in specific cases when required.
This cannot be done out of the box, but it's possible using scripts/module (the goal behind my [Datum](https://github.com/gaelcolas/datum) module).

The challenge is then to manage the config data for a shared config in a way compatible with using a ConfigData module such as Datum.
Not easy... ideas welcome.