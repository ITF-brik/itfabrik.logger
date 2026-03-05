function Format-LoggerLineDefault {
    param(
        [Parameter(Mandatory)][string]$Timestamp,
        [Parameter(Mandatory)][string]$Severity,
        [Parameter(Mandatory)][string]$Component,
        [Parameter(Mandatory)][string]$Message,
        [int]$IndentLevel = 0
    )

    # Keep component column stable; indent applies to message content only.
    $parts = Get-LoggerPrefix -Severity $Severity -IndentLevel $IndentLevel
    $sevPadded = $Severity.PadLeft($parts.FieldWidth)
    $indent = $parts.Indent
    return "[$Timestamp] [$sevPadded][$Component] $indent$Message"
}
