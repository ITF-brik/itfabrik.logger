function Initialize-LoggerFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$Path,
        [ValidateSet('Size','Daily','NewFile')] [string]$Rotation,
        [ValidateRange(0.001, 1024)] [double]$MaxSizeMB = 5,
        [ValidateRange(1, 100)] [int]$MaxRolls = 3,
        [ValidateSet('UTF8','UTF8BOM','ASCII','Unicode','UTF7','UTF32','Default','OEM')] [string]$Encoding = 'UTF8BOM',
        [ValidateSet('Warn','Continue','Throw')] [string]$OnError = 'Warn'
    )

    Initialize-LoggerService -Reset

    $sinkArgs = @{
        Type       = 'File'
        Path       = $Path
        FileFormat = 'Default'
        MaxSizeMB  = $MaxSizeMB
        MaxRolls   = $MaxRolls
        Encoding   = $Encoding
        OnError    = $OnError
    }
    if ($PSBoundParameters.ContainsKey('Rotation')) { $sinkArgs.Rotation = $Rotation }
    Register-LoggerSink @sinkArgs
}
