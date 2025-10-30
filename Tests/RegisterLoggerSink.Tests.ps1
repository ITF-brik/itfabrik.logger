$ErrorActionPreference = 'Stop'

Describe 'Register-LoggerSink (parameter sets)' {
    BeforeAll {
        $modulePath = Join-Path $PSScriptRoot '..\ITFabrik.Logger.psd1'
        Import-Module $modulePath -Force
    }

    BeforeEach { InModuleScope 'ITFabrik.Logger' { [LoggerService]::Reset() } }

    It 'registers Console sink with default options' { InModuleScope 'ITFabrik.Logger' {
        Register-LoggerSink -Type Console -Format Default
        $svc = [LoggerService]::GetInstance()
        $sinks = $svc.GetSinks()
        $sinks.Count | Should -Be 1
        $sinks[0].Type | Should -Be 'Console'
        $sinks[0].Options.Format | Should -Be 'Default'
    } }

    It 'registers File sink with provided options' { InModuleScope 'ITFabrik.Logger' {
        $tmp = Join-Path $env:TEMP ("rg_sink_{0}.log" -f ([guid]::NewGuid().ToString('N')))
        Register-LoggerSink -Type File -Path $tmp -FileFormat Cmtrace -Rotation Daily -MaxSizeMB 1 -MaxRolls 5 -Encoding ASCII
        $s = ([LoggerService]::GetInstance()).GetSinks()
        $s.Count | Should -Be 1
        $s[0].Type | Should -Be 'File'
        $s[0].Options.Path | Should -Be $tmp
        $s[0].Options.Format | Should -Be 'Cmtrace'
        $s[0].Options.Rotation | Should -Be 'Daily'
        [double]$s[0].Options.MaxSizeMB | Should -Be 1
        [int]$s[0].Options.MaxRolls | Should -Be 5
        $s[0].Options.Encoding | Should -Be 'ASCII'
    } }

    It 'registers File sink with Rotation NewFile' { InModuleScope 'ITFabrik.Logger' {
        $tmp = Join-Path $env:TEMP ("rg_sink_{0}.log" -f ([guid]::NewGuid().ToString('N')))
        Register-LoggerSink -Type File -Path $tmp -FileFormat Default -Rotation NewFile -MaxSizeMB 2 -MaxRolls 2 -Encoding UTF8BOM
        $s = ([LoggerService]::GetInstance()).GetSinks()
        $s.Count | Should -Be 1
        $s[0].Type | Should -Be 'File'
        $s[0].Options.Rotation | Should -Be 'NewFile'
    } }
}

