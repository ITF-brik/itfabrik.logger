function Invoke-SMConsoleLogger {
    param(
        [Parameter(Mandatory)] [string]$Component,
        [Parameter(Mandatory)] [string]$Message,
        [Parameter(Mandatory)] [ValidateSet('Info','Success','Warning','Error','Debug','Verbose')] [string]$Severity,
        [int]$IndentLevel = 0,
        [string]$StepName = '',
        [string]$ForegroundColor
    )

    $obj = Format-ConsoleMessage -Component $Component -Message $Message -Severity $Severity -IndentLevel $IndentLevel -StepName $StepName -ForegroundColor $ForegroundColor
    Write-Host $obj.Text -ForegroundColor $obj.ForegroundColor
}

