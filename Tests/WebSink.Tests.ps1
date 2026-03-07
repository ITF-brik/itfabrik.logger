$ErrorActionPreference = 'Stop'

Describe 'Web Sink (Invoke-WebSink)' {
    BeforeAll {
        $modulePath = Join-Path $PSScriptRoot '..\ITFabrik.Logger.psd1'
        Import-Module $modulePath -Force
    }

    It 'posts JSON with APIKey and merged headers' {
        InModuleScope 'ITFabrik.Logger' {
            $script:targetUrl = 'https://example.local/api/logs'
            Mock Invoke-RestMethod -ModuleName 'ITFabrik.Logger' -Verifiable -ParameterFilter {
                $Method -eq 'Post' -and
                $Uri -eq $script:targetUrl -and
                $Headers['X-API-Key'] -eq 'abc' -and
                $Headers['X-Extra'] -eq '1' -and
                $ContentType -eq 'application/json' -and
                ($Body -is [string]) -and ($Body -match '"component"\s*:\s*"Unit"') -and ($Body -match '"severity"\s*:\s*"Info"')
            } | Out-Null

            Invoke-WebSink -Options @{ Url = $script:targetUrl; APIKey = 'abc'; Headers = @{ 'X-Extra' = '1' } } -Component 'Unit' -Message 'Hi' -Severity 'Info' -IndentLevel 1

            Should -Invoke -CommandName Invoke-RestMethod -Times 1 -Exactly
        }
    }

    It 'uses a provided timestamp in the web payload' {
        InModuleScope 'ITFabrik.Logger' {
            $script:targetUrl = 'https://example.local/api/logs'
            $script:capturedBody = $null
            Mock Invoke-RestMethod -ModuleName 'ITFabrik.Logger' -MockWith {
                param($Method, $Uri, $Headers, $Body, $ContentType, $ErrorAction)
                $script:capturedBody = $Body
            } -Verifiable

            Invoke-WebSink -Options @{ Url = $script:targetUrl } -Component 'Unit' -Message 'Hi' -Severity 'Info' -IndentLevel 1 -Timestamp ([datetime]'2025-01-01 12:34:56')

            Should -Invoke -CommandName Invoke-RestMethod -Times 1 -Exactly
            $script:capturedBody | Should -Match '"timestamp"\s*:\s*"2025-01-01T12:34:56\.0000000"'
        }
    }
}
