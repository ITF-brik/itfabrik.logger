$ErrorActionPreference = 'Stop'

Describe 'Sink error policy (OnError)' {
    BeforeAll {
        $modulePath = Join-Path $PSScriptRoot '..\ITFabrik.Logger.psd1'
        Import-Module $modulePath -Force
    }

    BeforeEach { InModuleScope 'ITFabrik.Logger' { [LoggerService]::Reset() } }

    It 'warns and continues on file sink failure by default' { InModuleScope 'ITFabrik.Logger' {
        Mock New-Item -ModuleName 'ITFabrik.Logger' { throw 'mkdir failed' }
        Mock Write-Warning -ModuleName 'ITFabrik.Logger' {}

        Initialize-LoggerService -Reset
        $path = Join-Path $env:TEMP ("itfabrik_logger_{0}\\app.log" -f ([guid]::NewGuid().ToString('N')))
        Register-LoggerSink -Type File -Path $path

        { & $Global:StepManagerLogger 'Comp' 'Hello' 'Info' 0 } | Should -Not -Throw
        Should -Invoke -CommandName Write-Warning -Times 1 -Exactly
    } }

    It 'throws when OnError is Throw on file sink failure' { InModuleScope 'ITFabrik.Logger' {
        Mock New-Item -ModuleName 'ITFabrik.Logger' { throw 'mkdir failed' }
        Mock Write-Warning -ModuleName 'ITFabrik.Logger' {}

        Initialize-LoggerService -Reset
        $path = Join-Path $env:TEMP ("itfabrik_logger_{0}\\app.log" -f ([guid]::NewGuid().ToString('N')))
        Register-LoggerSink -Type File -Path $path -OnError Throw

        { & $Global:StepManagerLogger 'Comp' 'Hello' 'Info' 0 } | Should -Throw
        Should -Invoke -CommandName Write-Warning -Times 0
    } }

    It 'warns and continues on web sink failure by default' { InModuleScope 'ITFabrik.Logger' {
        Mock Invoke-RestMethod -ModuleName 'ITFabrik.Logger' { throw 'http failed' }
        Mock Write-Warning -ModuleName 'ITFabrik.Logger' {}

        Initialize-LoggerService -Reset
        Register-LoggerSink -Type Web -Url 'https://example.local/ingest'

        { & $Global:StepManagerLogger 'Comp' 'Hello' 'Info' 0 } | Should -Not -Throw
        Should -Invoke -CommandName Write-Warning -Times 1 -Exactly
    } }

    It 'throws when OnError is Throw on web sink failure' { InModuleScope 'ITFabrik.Logger' {
        Mock Invoke-RestMethod -ModuleName 'ITFabrik.Logger' { throw 'http failed' }
        Mock Write-Warning -ModuleName 'ITFabrik.Logger' {}

        Initialize-LoggerService -Reset
        Register-LoggerSink -Type Web -Url 'https://example.local/ingest' -OnError Throw

        { & $Global:StepManagerLogger 'Comp' 'Hello' 'Info' 0 } | Should -Throw
        Should -Invoke -CommandName Write-Warning -Times 0
    } }
}
