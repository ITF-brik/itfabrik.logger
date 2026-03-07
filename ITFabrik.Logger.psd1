@{
    RootModule        = 'ITFabrik.Logger.psm1'
    ModuleVersion     = '0.3.2'
    GUID              = '0e0c9a7a-2f7e-4a44-8c3d-9f1e4b8a3f21'
    Author            = 'IT FABRIK'
    CompanyName       = 'IT FABRIK'
    Copyright        = '(c) IT FABRIK. All rights reserved.'
    Description       = 'Logger: Implemente un logger compatible ITFabrik.Stepper via la variable legacy StepManagerLogger.'
    PowerShellVersion = '5.1'
    CompatiblePSEditions = @('Desktop','Core')
    FunctionsToExport = @('Initialize-LoggerService','Register-LoggerSink','Initialize-LoggerConsole','Initialize-LoggerFile','Initialize-LoggerSerilog','Disable-Logger')
    CmdletsToExport   = @()
    AliasesToExport   = @()
    VariablesToExport = @()
    # FormatsToProcess intentionally empty (no custom formatting file)
    FormatsToProcess = @()
    PrivateData       = @{
        PSData = @{
            Tags = @('logging','ITFabrik.Stepper','stepper','console')
            Prerelease = $null
        }
    }
}
