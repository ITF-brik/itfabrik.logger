function Resolve-LoggerTimestamp {
    [CmdletBinding()]
    param(
        [AllowNull()][Nullable[datetime]]$Timestamp = $null
    )

    if ($null -ne $Timestamp) {
        return [datetime]$Timestamp
    }

    return Get-Date
}
