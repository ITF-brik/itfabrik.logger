# Load private classes and functions first
Get-ChildItem -Path "$PSScriptRoot\Private\Classes" -Filter *.ps1 -File -ErrorAction SilentlyContinue |
    ForEach-Object { . $_.FullName }
Get-ChildItem -Path "$PSScriptRoot\Private\Functions" -Filter *.ps1 -File -ErrorAction SilentlyContinue |
    ForEach-Object { . $_.FullName }

# Load public functions if present
Get-ChildItem -Path "$PSScriptRoot\Public" -Filter *.ps1 -File -ErrorAction SilentlyContinue |
    ForEach-Object { . $_.FullName }



# Automatically register default logger if none set yet
try {
    $existing = $null
    try { $existing = (Get-Variable -Name 'StepManagerLogger' -Scope Global -ErrorAction Stop).Value } catch { $existing = $null }
    if ($null -eq $existing) {
        $Global:StepManagerLogger = ${function:Invoke-SMConsoleLogger}
    }
} catch { }

Export-ModuleMember -Function Initialize-LoggerService,Register-LoggerSink,Initialize-LoggerConsole,Initialize-LoggerFile,Disable-Logger

