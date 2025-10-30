@{
    Run = @{ Path = 'Tests' }
    Output = @{ Verbosity = 'Normal' }
    CodeCoverage = @{
        Enabled = $true
        Path = @('ITFabrik.Logger.psm1','Public/*.ps1','Private/**/*.ps1')
        CoveragePercentTarget = 90
    }
}
