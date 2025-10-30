$ErrorActionPreference = 'Stop'

Describe 'LoggerService (configure and dispatch)' {
    BeforeAll {
        $modulePath = Join-Path $PSScriptRoot '..\ITFabrik.Logger.psd1'
        Import-Module $modulePath -Force
    }

    BeforeEach { InModuleScope 'ITFabrik.Logger' { [LoggerService]::Reset() } }

    It 'initializes service and sets StepManagerLogger' { InModuleScope 'ITFabrik.Logger' {
        Initialize-LoggerService -Reset
        (Get-Variable -Name StepManagerLogger -Scope Global -ErrorAction Stop).Value | Should -BeOfType [scriptblock]
    } }

    It 'dispatches to all registered sinks' { InModuleScope 'ITFabrik.Logger' {
        Mock Invoke-SMConsoleLogger -ModuleName 'ITFabrik.Logger' {}
        Mock Invoke-FileSink -ModuleName 'ITFabrik.Logger' {}
        Mock Invoke-WebSink -ModuleName 'ITFabrik.Logger' {}

        Initialize-LoggerService -Reset
        Register-LoggerSink -Type Console
        Register-LoggerSink -Type File -Path (Join-Path $env:TEMP ("disp_{0}.log" -f ([guid]::NewGuid().ToString('N'))))
        # Web sink registration is not exposed publicly; tested separately in WebSink.Tests.ps1

        & $Global:StepManagerLogger 'Comp' 'Hello' 'Warning' 1

        Should -Invoke -CommandName Invoke-SMConsoleLogger -Times 1 -Exactly
        Should -Invoke -CommandName Invoke-FileSink -Times 1 -Exactly
        # Web sink not registered here
    } }
}
