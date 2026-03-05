function Register-LoggerSink {
    [CmdletBinding(DefaultParameterSetName='Console')]
    param(
        [Parameter(Mandatory)][ValidateSet('Console','File','Web')][string]$Type,

        # Console
        [Parameter(ParameterSetName='Console')][ValidateSet('Default')][string]$Format = 'Default',

        # File
        [Parameter(Mandatory, ParameterSetName='File')][string]$Path,
        [Parameter(ParameterSetName='File')][ValidateSet('Default','Cmtrace')][string]$FileFormat = 'Default',
        [Parameter(ParameterSetName='File')][ValidateSet('Size','Daily','NewFile')][string]$Rotation,
        [Parameter(ParameterSetName='File')][ValidateRange(0.001,1024)][double]$MaxSizeMB = 5,
        [Parameter(ParameterSetName='File')][ValidateRange(1,100)][int]$MaxRolls = 3,
        [Parameter(ParameterSetName='File')][ValidateSet('UTF8','UTF8BOM','ASCII','Unicode','UTF7','UTF32','Default','OEM')][string]$Encoding = 'UTF8BOM',
        [Parameter(ParameterSetName='File')]
        [Parameter(ParameterSetName='Web')]
        [ValidateSet('Warn','Continue','Throw')][string]$OnError = 'Warn',

        # Web
        [Parameter(Mandatory, ParameterSetName='Web')][string]$Url,
        [Parameter(ParameterSetName='Web')][string]$APIKey,
        [Parameter(ParameterSetName='Web')][hashtable]$Headers
    )

    $svc = [LoggerService]::GetInstance()
    switch ($Type) {
        'Console' {
            $svc.RegisterSink('Console', @{ Format = $Format })
        }
        'File' {
            $svc.RegisterSink('File', @{ Path = $Path; Format = $FileFormat; Rotation = $Rotation; MaxSizeMB = $MaxSizeMB; MaxRolls = $MaxRolls; Encoding = $Encoding; OnError = $OnError })
        }
        'Web' {
            $svc.RegisterSink('Web', @{ Url = $Url; APIKey = $APIKey; Headers = $Headers; OnError = $OnError })
        }
    }
}
