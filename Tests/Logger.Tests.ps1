$ErrorActionPreference = 'Stop'

Describe 'ITFabrik.Logger Module' {
    BeforeAll {
        $script:modulePath = Join-Path $PSScriptRoot '..\ITFabrik.Logger.psd1'
        Import-Module $script:modulePath -Force
    }

    It 'does not set StepManagerLogger on module import' {
        Disable-Logger
        Remove-Module ITFabrik.Logger -ErrorAction SilentlyContinue
        Import-Module $script:modulePath -Force
        { Get-Variable -Name StepManagerLogger -Scope Global -ErrorAction Stop } | Should -Throw
    }

    It 'exports helper functions' {
        Get-Command Initialize-LoggerConsole -Module 'ITFabrik.Logger' | Should -Not -BeNullOrEmpty
        Get-Command Disable-Logger -Module 'ITFabrik.Logger' | Should -Not -BeNullOrEmpty
    }

    It 'sets and removes StepManagerLogger' {
        Initialize-LoggerConsole
        (Get-Variable -Name StepManagerLogger -Scope Global -ErrorAction Stop).Value | Should -Not -BeNullOrEmpty
        Disable-Logger
        { Get-Variable -Name StepManagerLogger -Scope Global -ErrorAction Stop } | Should -Throw
    }
}


