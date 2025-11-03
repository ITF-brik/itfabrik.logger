function Format-LoggerLineDefault {
    param(
        [Parameter(Mandatory)][string]$Timestamp,
        [Parameter(Mandatory)][string]$Severity,
        [Parameter(Mandatory)][string]$Component,
        [Parameter(Mandatory)][string]$Message,
        [int]$IndentLevel = 0
    )

    # Use shared prefix helper to keep width/indent consistent with console
    $parts = Get-LoggerPrefix -Severity $Severity -IndentLevel $IndentLevel
    $sevPadded = $Severity.PadLeft($parts.FieldWidth)
    $indent = $parts.Indent
    return "[$Timestamp] [$sevPadded]$indent[$Component] $Message"
}
