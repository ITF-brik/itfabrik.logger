function Format-ConsoleMessage {
    param(
        [Parameter(Mandatory)] [string]$Component,
        [Parameter(Mandatory)] [string]$Message,
        [Parameter(Mandatory)] [ValidateSet('Info','Success','Warning','Error','Debug','Verbose')] [string]$Severity,
        [int]$IndentLevel = 0,
        [string]$StepName = '',
        [string]$ForegroundColor
    )

    # Préfixe partagé (padding sévérité, indentation, step)
    $parts = Get-LoggerPrefix -Severity $Severity -IndentLevel $IndentLevel -StepName $StepName

    switch ($Severity) {
        'Info'    { if(-not $ForegroundColor){ $ForegroundColor = 'Gray' } }
        'Success' { if(-not $ForegroundColor){ $ForegroundColor = 'Green' } }
        'Warning' { if(-not $ForegroundColor){ $ForegroundColor = 'Yellow' } }
        'Error'   { if(-not $ForegroundColor){ $ForegroundColor = 'Red' } }
        'Debug'   { if(-not $ForegroundColor){ $ForegroundColor = 'Cyan' } }
        'Verbose' { if(-not $ForegroundColor){ $ForegroundColor = 'Magenta' } }
        default   { if(-not $ForegroundColor){ $ForegroundColor = 'White' } }
    }

    $now = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    $prefix = "[$Severity]" + $parts.SeverityPad
    $text = "[$now] $prefix$($parts.Indent)$($parts.StepTag) $Message"

    [pscustomobject]@{
        Text = $text
        ForegroundColor = $ForegroundColor
    }
}
