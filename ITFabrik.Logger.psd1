@{
    RootModule        = 'ITFabrik.Logger.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = '0e0c9a7a-2f7e-4a44-8c3d-9f1e4b8a3f21'
    Author            = 'IT FABRIK'
    CompanyName       = 'IT FABRIK'
    Copyright        = '(c) IT FABRIK. All rights reserved.'
    Description       = 'Logger: Implemente un logger compatible StepManager via la variable StepManagerLogger.'
    PowerShellVersion = '5.1'
    CompatiblePSEditions = @('Desktop','Core')
    FunctionsToExport = @('Initialize-LoggerService','Register-LoggerSink','Initialize-LoggerConsole','Initialize-LoggerFile','Disable-Logger')
    CmdletsToExport   = @()
    AliasesToExport   = @()
    VariablesToExport = @()
    # FormatsToProcess intentionally empty (no custom formatting file)
    FormatsToProcess = @()
    PrivateData       = @{
        PSData = @{
            Tags = @('logging','StepManager','console')
        }
    }
}

