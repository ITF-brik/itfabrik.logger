$ErrorActionPreference = 'Stop'

Describe 'File Logger' {
    BeforeAll {
        $modulePath = Join-Path $PSScriptRoot '..\ITFabrik.Logger.psd1'
        Import-Module $modulePath -Force
        $TestLog = Join-Path $env:TEMP ("logger_test_{0}.log" -f ([guid]::NewGuid().ToString('N')))
        Set-Variable -Name TestLog -Value $TestLog -Scope Script
    }

    AfterAll {
        Get-ChildItem "$($script:TestLog)*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    }

    It 'writes a line to the file' {
        Initialize-LoggerFile -Path $script:TestLog -MaxSizeMB 10 -MaxRolls 2
        & $Global:StepManagerLogger 'Unit' 'Hello world' 'Info' 0
        Start-Sleep -Milliseconds 50
        Get-Content -LiteralPath $script:TestLog -Raw | Should -Match 'Hello world'
    }

    It 'rotates when exceeding max size' {
        Initialize-LoggerFile -Path $script:TestLog -Rotation Size -MaxSizeMB 0.001 -MaxRolls 2
        $msg = 'X' * 5000
        1..5 | ForEach-Object { & $Global:StepManagerLogger 'Unit' $msg 'Info' 0 }
        Start-Sleep -Milliseconds 150
        ($rolls = Get-ChildItem -LiteralPath (Split-Path -Parent $script:TestLog) -Filter ("{0}.*" -f (Split-Path -Leaf $script:TestLog)) -ErrorAction SilentlyContinue) | Out-Null
        @($rolls | Where-Object { $_.Name -match '\.\d+$' }).Count | Should -BeGreaterThan 0
    }
}
