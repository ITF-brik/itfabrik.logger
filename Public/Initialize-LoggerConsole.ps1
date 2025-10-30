function Initialize-LoggerConsole {
    [CmdletBinding()]
    param()

    Initialize-LoggerService -Reset
    Register-LoggerSink -Type Console
}
