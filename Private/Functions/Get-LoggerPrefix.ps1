function Get-LoggerPrefix {
    param(
        [Parameter(Mandatory)][ValidateSet('Info','Success','Warning','Error','Debug','Verbose')][string]$Severity,
        [int]$IndentLevel = 0,
        [string]$StepName = ''
    )

    # Pad severity to a consistent visual width (inside or after brackets depending on consumer)
    $fieldWidth = 10
    $padCount = [Math]::Max(0, $fieldWidth - $Severity.Length)
    $severityPad = ' ' * $padCount

    $indent = if ($IndentLevel -gt 0) { ' ' * ($IndentLevel * 2) } else { '' }
    $stepTag = if ($StepName) { "[$StepName]" } else { '' }

    [pscustomobject]@{
        SeverityPad = $severityPad
        Indent      = $indent
        StepTag     = $stepTag
        FieldWidth  = $fieldWidth
    }
}
