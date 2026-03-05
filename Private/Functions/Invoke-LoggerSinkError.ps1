function Invoke-LoggerSinkError {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Sink,
        [Parameter(Mandatory)][string]$Action,
        [Parameter(Mandatory)][System.Management.Automation.ErrorRecord]$ErrorRecord,
        [ValidateSet('Warn','Continue','Throw')][string]$Policy = 'Warn'
    )

    $message = "ITFabrik.Logger sink '$Sink' failed during ${Action}: $($ErrorRecord.Exception.Message)"

    switch ($Policy) {
        'Throw' { throw $ErrorRecord }
        'Warn' { Write-Warning $message }
        'Continue' { }
    }
}
