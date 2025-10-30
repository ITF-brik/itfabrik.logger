function Invoke-WebSink {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][hashtable]$Options,
        [Parameter(Mandatory)][string]$Component,
        [Parameter(Mandatory)][string]$Message,
        [Parameter(Mandatory)][ValidateSet('Info','Success','Warning','Error','Debug','Verbose')][string]$Severity,
        [int]$IndentLevel = 0
    )

    $url = $Options.Url
    if (-not $url) { return }
    $apiKey = $Options.APIKey
    $headers = @{}
    if ($apiKey) { $headers['X-API-Key'] = $apiKey }
    if ($Options.Headers -is [hashtable]) { $Options.Headers.GetEnumerator() | ForEach-Object { $headers[$_.Key] = $_.Value } }
    $payload = [ordered]@{
        timestamp  = (Get-Date).ToString('o')
        component  = $Component
        message    = $Message
        severity   = $Severity
        indent     = $IndentLevel
        host       = $env:COMPUTERNAME
        processId  = $PID
    }
    try {
        Invoke-RestMethod -Method Post -Uri $url -Headers $headers -Body ($payload | ConvertTo-Json -Depth 5) -ContentType 'application/json' -ErrorAction SilentlyContinue | Out-Null
    } catch { }
}

