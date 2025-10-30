function Initialize-LoggerFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$Path,
        [ValidateSet('Size','Daily','NewFile')] [string]$Rotation,
        [ValidateRange(0.001, 1024)] [double]$MaxSizeMB = 5,
        [ValidateRange(1, 100)] [int]$MaxRolls = 3,
        [ValidateSet('UTF8','UTF8BOM','ASCII','Unicode','UTF7','UTF32','Default','OEM')] [string]$Encoding = 'UTF8BOM'
    )

    Initialize-LoggerService -Reset

    $args = @{
        Type       = 'File'
        Path       = $Path
        FileFormat = 'Default'
        MaxSizeMB  = $MaxSizeMB
        MaxRolls   = $MaxRolls
        Encoding   = $Encoding
    }
    if ($PSBoundParameters.ContainsKey('Rotation')) { $args.Rotation = $Rotation }
    Register-LoggerSink @args
}
