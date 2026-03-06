class LoggerSink {
    [string]$Type
    [hashtable]$Options
    LoggerSink([string]$type, [hashtable]$options) {
        $this.Type = $type
        $this.Options = $options
    }
}

class LoggerService {
    hidden static [LoggerService] $instance
    [System.Collections.ArrayList]$Sinks

    LoggerService() {
        $this.Sinks = [System.Collections.ArrayList]::new()
    }

    static [LoggerService] GetInstance() {
        if (-not [LoggerService]::instance) { [LoggerService]::instance = [LoggerService]::new() }
        return [LoggerService]::instance
    }

    static [void] Reset() {
        [LoggerService]::instance = [LoggerService]::new()
    }

    [void] RegisterSink([string]$type, [hashtable]$options) {
        [void]$this.Sinks.Add([LoggerSink]::new($type, $options))
    }

    [object[]] GetSinks() { return ,$this.Sinks.ToArray() }

    [void] ConfigureService() {
        $dispatcher = {
            param(
                [Parameter(Mandatory)] [string]$Component,
                [Parameter(Mandatory)] [string]$Message,
                [Parameter(Mandatory)] [ValidateSet('Info','Success','Warning','Error','Debug','Verbose')] [string]$Severity,
                [int]$IndentLevel = 0,
                [AllowNull()][Nullable[datetime]]$Timestamp = $null
            )
            $svc = [LoggerService]::GetInstance()
            foreach ($sink in $svc.Sinks) {
                switch ($sink.Type.ToLower()) {
                    'console' { Invoke-SMConsoleLogger $Component $Message $Severity $IndentLevel -Timestamp $Timestamp }
                    'file'    { Invoke-FileSink -Options $sink.Options -Component $Component -Message $Message -Severity $Severity -IndentLevel $IndentLevel -Timestamp $Timestamp }
                    'web'     { Invoke-WebSink  -Options $sink.Options -Component $Component -Message $Message -Severity $Severity -IndentLevel $IndentLevel -Timestamp $Timestamp }
                    'serilog' { Invoke-SerilogSink -Options $sink.Options -Component $Component -Message $Message -Severity $Severity -IndentLevel $IndentLevel -Timestamp $Timestamp }
                }
            }
        }
        Set-Variable -Name 'StepManagerLogger' -Scope Global -Value $dispatcher
    }
}
