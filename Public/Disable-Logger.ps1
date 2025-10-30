function Disable-Logger {
    [CmdletBinding()]
    param()

    Remove-Variable -Name StepManagerLogger -Scope Global -ErrorAction SilentlyContinue
}
