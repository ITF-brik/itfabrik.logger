function Initialize-LoggerService {
    [CmdletBinding()]
    param(
        [switch]$Reset,
        [scriptblock]$Action
    )

    if ($Reset) { [LoggerService]::Reset() | Out-Null }
    $svc = [LoggerService]::GetInstance()
    $svc.ConfigureService()
    if ($Action) { & $Action -ArgumentList $svc }
}
