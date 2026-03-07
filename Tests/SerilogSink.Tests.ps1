$ErrorActionPreference = 'Stop'

Describe 'Serilog Sink (Invoke-SerilogSink)' {
    BeforeAll {
        $modulePath = Join-Path $PSScriptRoot '..\ITFabrik.Logger.psd1'
        Import-Module $modulePath -Force
    }

    It 'posts a Serilog-like JSON payload with merged headers' {
        InModuleScope 'ITFabrik.Logger' {
            $script:targetUrl = 'https://example.local/api/serilog'
            $script:capturedCall = $null

            Mock Invoke-RestMethod -ModuleName 'ITFabrik.Logger' -MockWith {
                param($Method, $Uri, $Headers, $Body, $ContentType, $ErrorAction)
                $script:capturedCall = @{
                    Method      = $Method
                    Uri         = $Uri
                    Headers     = $Headers
                    Body        = $Body
                    ContentType = $ContentType
                    ErrorAction = $ErrorAction
                }
            } -Verifiable

            Invoke-SerilogSink -Options @{ Url = $script:targetUrl; APIKey = 'abc'; Headers = @{ 'X-Env' = 'dev' } } -Component 'Unit.Component' -Message 'Processed item' -Severity 'Success' -IndentLevel 2

            Should -Invoke -CommandName Invoke-RestMethod -Times 1 -Exactly
            $script:capturedCall.Method | Should -Be 'Post'
            $script:capturedCall.Uri | Should -Be $script:targetUrl
            $script:capturedCall.Headers['X-API-Key'] | Should -Be 'abc'
            $script:capturedCall.Headers['X-Env'] | Should -Be 'dev'
            $script:capturedCall.ContentType | Should -Be 'application/json'
            $script:capturedCall.ErrorAction | Should -Be 'Stop'

            $payload = $script:capturedCall.Body | ConvertFrom-Json -Depth 10
            $payload.Timestamp | Should -Not -BeNullOrEmpty
            $payload.Level | Should -Be 'Information'
            $payload.MessageTemplate | Should -Be 'Processed item'
            $payload.RenderedMessage | Should -Be 'Processed item'
            $payload.Properties.Component | Should -Be 'Unit.Component'
            $payload.Properties.SourceContext | Should -Be 'Unit.Component'
            $payload.Properties.IndentLevel | Should -Be 2
            $payload.Properties.OriginalSeverity | Should -Be 'Success'
            $payload.Properties.Outcome | Should -Be 'Success'
            [int]$payload.Properties.ProcessId | Should -BeGreaterThan 0
        }
    }

    It 'uses a provided timestamp in the Serilog payload' {
        InModuleScope 'ITFabrik.Logger' {
            $script:targetUrl = 'https://example.local/api/serilog'
            $script:capturedCall = $null

            Mock Invoke-RestMethod -ModuleName 'ITFabrik.Logger' -MockWith {
                param($Method, $Uri, $Headers, $Body, $ContentType, $ErrorAction)
                $script:capturedCall = @{
                    Body = $Body
                }
            } -Verifiable

            Invoke-SerilogSink -Options @{ Url = $script:targetUrl } -Component 'Unit.Component' -Message 'Processed item' -Severity 'Info' -IndentLevel 2 -Timestamp ([datetime]'2025-01-01 12:34:56')

            Should -Invoke -CommandName Invoke-RestMethod -Times 1 -Exactly
            $script:capturedCall.Body | Should -Match '"Timestamp"\s*:\s*"2025-01-01T12:34:56\.0000000"'
        }
    }

    It 'initializes the service with a Serilog sink shortcut' {
        InModuleScope 'ITFabrik.Logger' {
            Initialize-LoggerSerilog -Url 'https://example.local/api/serilog' -APIKey 'key' -Headers @{ 'X-Test' = '1' }

            $svc = [LoggerService]::GetInstance()
            $sinks = $svc.GetSinks()
            $sinks.Count | Should -Be 1
            $sinks[0].Type | Should -Be 'Serilog'
            $sinks[0].Options.Url | Should -Be 'https://example.local/api/serilog'
            $Global:StepManagerLogger | Should -BeOfType ([scriptblock])
        }
    }
}
