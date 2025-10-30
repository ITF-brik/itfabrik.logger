function Format-ConsoleMessage {
    param(
        [Parameter(Mandatory)] [string]$Component,
        [Parameter(Mandatory)] [string]$Message,
        [Parameter(Mandatory)] [ValidateSet('Info','Success','Warning','Error','Debug','Verbose')] [string]$Severity,
        [int]$IndentLevel = 0,
        [string]$StepName = '',
        [string]$ForegroundColor
    )

    # Standardise le préfixe pour rester stable en test
    $prefixRaw = "[$Severity]"

    switch ($Severity) {
        'Info'    { $prefix = $prefixRaw + (' ' * 4) ; if(-not $ForegroundColor){ $ForegroundColor = 'Gray' } }
        'Success' { $prefix = $prefixRaw + (' ' * 3) ; if(-not $ForegroundColor){ $ForegroundColor = 'Green' } }
        'Warning' { $prefix = $prefixRaw + (' ' * 4) ; if(-not $ForegroundColor){ $ForegroundColor = 'Yellow' } }
        'Error'   { $prefix = $prefixRaw + (' ' * 3) ; if(-not $ForegroundColor){ $ForegroundColor = 'Red' } }
        'Debug'   { $prefix = $prefixRaw + (' ' * 3) ; if(-not $ForegroundColor){ $ForegroundColor = 'Cyan' } }
        'Verbose' { $prefix = $prefixRaw + (' ' * 3) ; if(-not $ForegroundColor){ $ForegroundColor = 'Magenta' } }
        default   { $prefix = $prefixRaw + (' ' * 3) ; if(-not $ForegroundColor){ $ForegroundColor = 'White' } }
    }

    $indent = if ($IndentLevel -gt 0) { ' ' * ($IndentLevel * 2) } else { '' }
    $now = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    $step = if ($StepName) { "[$StepName]" } else { '' }
    $text = "[$now] $prefix$indent$step $Message"

    [pscustomobject]@{
        Text = $text
        ForegroundColor = $ForegroundColor
    }
}
