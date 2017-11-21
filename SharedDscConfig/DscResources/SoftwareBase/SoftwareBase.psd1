@{
    
    # Script module or binary module file associated with this manifest.
    RootModule = 'SoftwareBase.schema.psm1'
    
    # Version number of this module.
    ModuleVersion = '0.0.1'
    
    # ID used to uniquely identify this module
    GUID = '78db8da3-b47e-4272-a24c-037842ff6164'
    
    # Author of this module
    Author = 'Gael Colas'
    
    # Company or vendor of this module
    CompanyName = 'SynEdgy Ltd'
    
    # Copyright statement for this module
    Copyright = '(c) 2017 Gael. All rights reserved.'
    
    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @('PSDesiredStateConfiguration')
    
    # DSC resources to export from this module
    DscResourcesToExport = @('SoftwareBase')
    
    }
    
    