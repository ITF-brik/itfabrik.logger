$ErrorActionPreference = 'Stop'

Describe 'Prefix snapshot (shared helper)' {
    BeforeAll {
        $modulePath = Join-Path $PSScriptRoot '..\ITFabrik.Logger.psd1'
        Import-Module $modulePath -Force
    }

    It 'Console prefix stays stable (Info, indent=2, step)' { InModuleScope 'ITFabrik.Logger' {
        Mock Get-Date {
            param([string]$Format)
            $fixed = [datetime]'2025-01-01 12:34:56'
            if ([string]::IsNullOrWhiteSpace($Format)) { return $fixed }
            return $fixed.ToString($Format, [System.Globalization.CultureInfo]::InvariantCulture)
        } -ModuleName 'ITFabrik.Logger'
        $o = Format-ConsoleMessage -Component 'Unit' -Message 'Msg' -Severity 'Info' -IndentLevel 2 -StepName 'Step'
        $expected = "[2025-01-01 12:34:56] [Info]" + (' ' * 6) + (' ' * 4) + "[Step] Msg"
        $o.Text | Should -Be $expected
    } }

    It 'File(Default) line stays stable (Info, indent=2)' { InModuleScope 'ITFabrik.Logger' {
        $ts = '2025-01-01 12:34:56'
        $line = Format-LoggerLineDefault -Timestamp $ts -Severity 'Info' -Component 'Unit' -Message 'Msg' -IndentLevel 2
        $expected = "[$ts] [" + (' ' * 6) + "Info]" + (' ' * 4) + "[Unit] Msg"
        $line | Should -Be $expected
    } }
}

