function Format-LoggerLineCmtrace {
    param(
        [Parameter(Mandatory)][string]$Timestamp,
        [Parameter(Mandatory)][string]$Severity,
        [Parameter(Mandatory)][string]$Component,
        [Parameter(Mandatory)][string]$Message,
        [int]$IndentLevel = 0,
        [bool]$IsLast = $false
    )
    # CMTrace XML-like format expected by cmtrace.exe
    # <![LOG[Message]LOG]!><time="HH:mm:ss.ffffff" date="M-d-yyyy" component="..." context="user" type="N" thread="id" file="">

    # Map Severity to CMTrace numeric type (1=Info, 2=Warning, 3=Error)
    $type = switch ($Severity) {
        'Warning' { '2' }
        'Error'   { '3' }
        default   { '1' }
    }

    $time    = Get-Date -Format 'HH:mm:ss.ffffff'
    $date    = Get-Date -Format 'M-d-yyyy'
    $context = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $thread  = [Threading.Thread]::CurrentThread.ManagedThreadId

    $prefix = ''
    if ($IndentLevel -gt 1) {
        for ($i = 1; $i -lt $IndentLevel; $i++) { $prefix += '│  ' }
    }
    if ($IndentLevel -gt 0) {
        $branchGlyph = if ($IsLast) { '└─ ' } else { '├─ ' }
        $prefix += $branchGlyph
    }
    $msgWithIndent = "$prefix$Message"

    $content = ('<![LOG[{0}]LOG]!><time="{1}" date="{2}" component="{3}" context="{4}" type="{5}" thread="{6}" file="">' -f `
        $msgWithIndent, $time, $date, $Component, $context, $type, $thread)
    return $content
}
