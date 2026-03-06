function Format-LoggerEventSerilog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Component,
        [Parameter(Mandatory)][string]$Message,
        [Parameter(Mandatory)][ValidateSet('Info','Success','Warning','Error','Debug','Verbose')][string]$Severity,
        [int]$IndentLevel = 0,
        [AllowNull()][Nullable[datetime]]$Timestamp = $null
    )

    $levelMap = @{
        Info    = 'Information'
        Success = 'Information'
        Warning = 'Warning'
        Error   = 'Error'
        Debug   = 'Debug'
        Verbose = 'Verbose'
    }

    $effectiveTimestamp = Resolve-LoggerTimestamp -Timestamp $Timestamp
    $properties = [ordered]@{
        Component        = $Component
        SourceContext    = $Component
        IndentLevel      = $IndentLevel
        Host             = $env:COMPUTERNAME
        ProcessId        = $PID
        OriginalSeverity = $Severity
    }

    if ($Severity -eq 'Success') {
        $properties['Outcome'] = 'Success'
    }

    return [ordered]@{
        Timestamp       = $effectiveTimestamp.ToString('o')
        Level           = $levelMap[$Severity]
        MessageTemplate = $Message
        RenderedMessage = $Message
        Properties      = $properties
    }
}
