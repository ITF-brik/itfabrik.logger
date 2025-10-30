function Format-LoggerLineDefault {
    param(
        [Parameter(Mandatory)][string]$Timestamp,
        [Parameter(Mandatory)][string]$Severity,
        [Parameter(Mandatory)][string]$Component,
        [Parameter(Mandatory)][string]$Message,
        [int]$IndentLevel = 0
    )

    # Uniform severity field width inside brackets, right-aligned
    $fieldWidth = 10
    $sevPadded = $Severity.PadLeft($fieldWidth)
    $indent = if ($IndentLevel -gt 0) { ' ' * ($IndentLevel * 2) } else { '' }
    return "[$Timestamp] [$sevPadded]$indent[$Component] $Message"
}
