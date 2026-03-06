function Initialize-LoggerSerilog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Url,
        [string]$APIKey,
        [hashtable]$Headers,
        [ValidateSet('Warn','Continue','Throw')][string]$OnError = 'Warn'
    )

    Initialize-LoggerService -Reset

    $sinkArgs = @{
        Type    = 'Serilog'
        Url     = $Url
        OnError = $OnError
    }

    if ($PSBoundParameters.ContainsKey('APIKey')) { $sinkArgs.APIKey = $APIKey }
    if ($PSBoundParameters.ContainsKey('Headers')) { $sinkArgs.Headers = $Headers }

    Register-LoggerSink @sinkArgs
}
