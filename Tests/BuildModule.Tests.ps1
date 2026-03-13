$ErrorActionPreference = 'Stop'

Describe 'Build-Module script' {
    It 'writes the bundled module as UTF-8 with BOM' {
        $outputRoot = Join-Path $env:TEMP ("itfabrik_logger_build_{0}" -f ([guid]::NewGuid().ToString('N')))

        try {
            & (Join-Path $PSScriptRoot '..\Scripts\Build-Module.ps1') -OutputRoot $outputRoot

            $modulePath = Join-Path $outputRoot 'ITFabrik.Logger.psm1'
            $bytes = [System.IO.File]::ReadAllBytes($modulePath)

            $bytes.Length | Should -BeGreaterThan 3
            ($bytes[0..2] -join ',') | Should -Be '239,187,191'
        } finally {
            Remove-Item -LiteralPath $outputRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
