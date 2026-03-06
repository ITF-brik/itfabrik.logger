$ErrorActionPreference = 'Stop'

Describe 'Console Logger (color and format)' {
    BeforeAll {
        $modulePath = Join-Path $PSScriptRoot '..\ITFabrik.Logger.psd1'
        Import-Module $modulePath -Force
    }

    It 'formats Info with Gray' { InModuleScope 'ITFabrik.Logger' { $o = Format-ConsoleMessage -Component 'Unit' -Message 'Msg' -Severity 'Info' -IndentLevel 2; $o.ForegroundColor | Should -Be 'Gray'; $o.Text | Should -Match '\[Info\]' } }
    It 'formats Success with Green' { InModuleScope 'ITFabrik.Logger' { $o = Format-ConsoleMessage -Component 'Unit' -Message 'Msg' -Severity 'Success' -IndentLevel 2; $o.ForegroundColor | Should -Be 'Green'; $o.Text | Should -Match '\[Success\]' } }
    It 'formats Warning with Yellow' { InModuleScope 'ITFabrik.Logger' { $o = Format-ConsoleMessage -Component 'Unit' -Message 'Msg' -Severity 'Warning' -IndentLevel 2; $o.ForegroundColor | Should -Be 'Yellow'; $o.Text | Should -Match '\[Warning\]' } }
    It 'formats Error with Red' { InModuleScope 'ITFabrik.Logger' { $o = Format-ConsoleMessage -Component 'Unit' -Message 'Msg' -Severity 'Error' -IndentLevel 2; $o.ForegroundColor | Should -Be 'Red'; $o.Text | Should -Match '\[Error\]' } }
    It 'formats Debug with Cyan' { InModuleScope 'ITFabrik.Logger' { $o = Format-ConsoleMessage -Component 'Unit' -Message 'Msg' -Severity 'Debug' -IndentLevel 2; $o.ForegroundColor | Should -Be 'Cyan'; $o.Text | Should -Match '\[Debug\]' } }
    It 'formats Verbose with Magenta' { InModuleScope 'ITFabrik.Logger' { $o = Format-ConsoleMessage -Component 'Unit' -Message 'Msg' -Severity 'Verbose' -IndentLevel 2; $o.ForegroundColor | Should -Be 'Magenta'; $o.Text | Should -Match '\[Verbose\]' } }
    It 'uses a provided timestamp in console output' { InModuleScope 'ITFabrik.Logger' { $o = Format-ConsoleMessage -Component 'Unit' -Message 'Msg' -Severity 'Info' -IndentLevel 2 -Timestamp ([datetime]'2025-01-01 12:34:56'); $o.Text | Should -Match '^\[2025-01-01 12:34:56\]' } }
    It 'falls back to Get-Date when timestamp is absent' { InModuleScope 'ITFabrik.Logger' {
        Mock Get-Date -ModuleName 'ITFabrik.Logger' { [datetime]'2025-01-01 12:34:56' }
        $o = Format-ConsoleMessage -Component 'Unit' -Message 'Msg' -Severity 'Info'
        $o.Text | Should -Match '^\[2025-01-01 12:34:56\]'
    } }
}






