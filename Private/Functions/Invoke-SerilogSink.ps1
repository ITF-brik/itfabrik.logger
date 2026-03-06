function Invoke-SerilogSink {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][hashtable]$Options,
        [Parameter(Mandatory)][string]$Component,
        [Parameter(Mandatory)][string]$Message,
        [Parameter(Mandatory)][ValidateSet('Info','Success','Warning','Error','Debug','Verbose')][string]$Severity,
        [int]$IndentLevel = 0,
        [AllowNull()][Nullable[datetime]]$Timestamp = $null
    )

    $url = $Options.Url
    if (-not $url) { return }

    $onError = ($Options.OnError | ForEach-Object { $_ }) -as [string]
    if (-not $onError) { $onError = 'Warn' }
    if ($onError -notin @('Warn','Continue','Throw')) { $onError = 'Warn' }

    $headers = @{}
    if ($Options.APIKey) { $headers['X-API-Key'] = $Options.APIKey }
    if ($Options.Headers -is [hashtable]) {
        $Options.Headers.GetEnumerator() | ForEach-Object { $headers[$_.Key] = $_.Value }
    }

    $payload = Format-LoggerEventSerilog -Component $Component -Message $Message -Severity $Severity -IndentLevel $IndentLevel -Timestamp $Timestamp

    try {
        Invoke-RestMethod -Method Post -Uri $url -Headers $headers -Body ($payload | ConvertTo-Json -Depth 8) -ContentType 'application/json' -ErrorAction Stop | Out-Null
    } catch {
        Invoke-LoggerSinkError -Sink 'Serilog' -Action 'posting Serilog payload' -ErrorRecord $_ -Policy $onError
    }
}
