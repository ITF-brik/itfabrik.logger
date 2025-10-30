$ErrorActionPreference = 'Stop'

Describe 'Additional coverage for console, file, web' {
    BeforeAll {
        $modulePath = Join-Path $PSScriptRoot '..\ITFabrik.Logger.psd1'
        Import-Module $modulePath -Force
    }

    It 'invokes SMConsoleLogger body (Info)' {
        InModuleScope 'ITFabrik.Logger' {
            # Exécute le corps sans moquer Write-Host (couverture)
            Invoke-SMConsoleLogger -Component 'Unit' -Message 'Hello' -Severity 'Info' -IndentLevel 1
        }
    }

    It 'dispatches Web sink through LoggerService' {
        InModuleScope 'ITFabrik.Logger' {
            Mock Invoke-WebSink -ModuleName 'ITFabrik.Logger' {}
            Initialize-LoggerService -Reset
            # Injection d'un sink Web directement via le service
            $svc = [LoggerService]::GetInstance()
            $svc.RegisterSink('Web', @{ Url = 'https://example.local/ingest' })
            & $Global:StepManagerLogger 'Comp' 'Msg' 'Info' 0
            Should -Invoke -CommandName Invoke-WebSink -Times 1 -Exactly
        }
    }

    It 'rotates file on NewFile mode' {
        InModuleScope 'ITFabrik.Logger' {
            $base = Join-Path $env:TEMP ("newfile_{0}.log" -f ([guid]::NewGuid().ToString('N')))
            # Pré-crée un fichier pour déclencher l'archive .1
            Set-Content -LiteralPath $base -Value 'old' -Encoding UTF8
            Invoke-FileSink -Options @{ Path = $base; Format = 'Default'; Rotation = 'NewFile'; MaxSizeMB = 1; MaxRolls = 2; Encoding = 'UTF8BOM' } -Component 'C' -Message 'N' -Severity 'Info' -IndentLevel 0
            Test-Path -LiteralPath ($base + '.1') | Should -BeTrue
            Test-Path -LiteralPath $base | Should -BeTrue
            Remove-Item -LiteralPath $base* -Force -ErrorAction SilentlyContinue
        }
    }

    It 'returns early when Url missing in Web sink' {
        InModuleScope 'ITFabrik.Logger' {
            { Invoke-WebSink -Options @{} -Component 'C' -Message 'M' -Severity 'Info' -IndentLevel 0 } | Should -Not -Throw
        }
    }

    It 'executes Initialize-LoggerService -Action callback' {
        InModuleScope 'ITFabrik.Logger' {
            { Initialize-LoggerService -Reset -Action { param($svc) $null = $svc } } | Should -Not -Throw
        }
    }

    It 'applies Daily rotation when path extension is not .log' {
        InModuleScope 'ITFabrik.Logger' {
            $base = Join-Path $env:TEMP ("dailyext_{0}.txt" -f ([guid]::NewGuid().ToString('N')))
            Invoke-FileSink -Options @{ Path = $base; Format = 'Default'; Rotation = 'Daily'; MaxSizeMB = 10; MaxRolls = 2; Encoding = 'UTF8' } -Component 'C' -Message 'M' -Severity 'Info' -IndentLevel 0
            $date = Get-Date -Format 'yyyy-MM-dd'
            $expected = "$base.$date"
            Test-Path -LiteralPath $expected | Should -BeTrue
            Remove-Item -LiteralPath $expected -Force -ErrorAction SilentlyContinue
        }
    }
}
