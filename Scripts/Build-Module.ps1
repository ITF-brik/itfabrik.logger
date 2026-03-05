param(
    [string]$OutputRoot = (Join-Path $PSScriptRoot '..\dist\ITFabrik.Logger'),
    [switch]$SkipValidation
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-OrderedScriptFile {
    param(
        [Parameter(Mandatory)][string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) { return @() }
    return @(Get-ChildItem -LiteralPath $Path -Filter *.ps1 -File | Sort-Object Name)
}

function Add-FileSection {
    param(
        [Parameter(Mandatory)][System.Text.StringBuilder]$Builder,
        [Parameter(Mandatory)][System.IO.FileInfo]$File,
        [Parameter(Mandatory)][string]$ModuleRoot
    )

    $relative = $File.FullName.Replace($ModuleRoot, '').TrimStart('\')
    [void]$Builder.AppendLine("# region $relative")
    [void]$Builder.AppendLine((Get-Content -LiteralPath $File.FullName -Raw).TrimEnd())
    [void]$Builder.AppendLine("# endregion")
    [void]$Builder.AppendLine()
}

$moduleRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$sourcePsd1 = Join-Path $moduleRoot 'ITFabrik.Logger.psd1'
$sourcePsm1 = Join-Path $moduleRoot 'ITFabrik.Logger.psm1'
$sourceReadme = Join-Path $moduleRoot 'README.md'
$sourceLicense = Join-Path $moduleRoot 'LICENSE'

foreach ($path in @($sourcePsd1, $sourcePsm1, $sourceReadme, $sourceLicense)) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Required source file not found: $path"
    }
}

$privateClasses = Get-OrderedScriptFile -Path (Join-Path $moduleRoot 'Private\Classes')
$privateFunctions = Get-OrderedScriptFile -Path (Join-Path $moduleRoot 'Private\Functions')
$publicFunctions = Get-OrderedScriptFile -Path (Join-Path $moduleRoot 'Public')

$exportLines = @(Get-Content -LiteralPath $sourcePsm1 | Where-Object { $_ -match '^\s*Export-ModuleMember\b' })
if (-not $exportLines) {
    throw "No Export-ModuleMember line found in source psm1: $sourcePsm1"
}

if (Test-Path -LiteralPath $OutputRoot) {
    [System.IO.Directory]::Delete($OutputRoot, $true)
}
[System.IO.Directory]::CreateDirectory($OutputRoot) | Out-Null

$distPsm1 = Join-Path $OutputRoot 'ITFabrik.Logger.psm1'
$builder = [System.Text.StringBuilder]::new()
[void]$builder.AppendLine('# Built file. Do not edit directly; edit source files and rebuild.')
[void]$builder.AppendLine("# Build timestamp: $(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK')")
[void]$builder.AppendLine()

foreach ($file in $privateClasses) { Add-FileSection -Builder $builder -File $file -ModuleRoot $moduleRoot }
foreach ($file in $privateFunctions) { Add-FileSection -Builder $builder -File $file -ModuleRoot $moduleRoot }
foreach ($file in $publicFunctions) { Add-FileSection -Builder $builder -File $file -ModuleRoot $moduleRoot }

[void]$builder.AppendLine('# Exports')
foreach ($line in $exportLines) { [void]$builder.AppendLine($line.TrimEnd()) }

Set-Content -LiteralPath $distPsm1 -Value $builder.ToString().TrimEnd() -Encoding UTF8
Copy-Item -LiteralPath $sourcePsd1 -Destination (Join-Path $OutputRoot 'ITFabrik.Logger.psd1') -Force
Copy-Item -LiteralPath $sourceReadme -Destination (Join-Path $OutputRoot 'README.md') -Force
Copy-Item -LiteralPath $sourceLicense -Destination (Join-Path $OutputRoot 'LICENSE') -Force

$distPsd1 = Join-Path $OutputRoot 'ITFabrik.Logger.psd1'
Update-ModuleManifest -Path $distPsd1 -FileList @('ITFabrik.Logger.psd1', 'ITFabrik.Logger.psm1', 'LICENSE', 'README.md')

if (-not $SkipValidation) {
    Test-ModuleManifest -Path $distPsd1 | Out-Null

    $imported = Import-Module -Name $distPsd1 -Force -PassThru
    if (-not $imported) {
        throw "Unable to import built module from $distPsd1"
    }
    Remove-Module -Name $imported.Name -Force -ErrorAction SilentlyContinue
}

$outputFiles = Get-ChildItem -LiteralPath $OutputRoot -File | Sort-Object Name
Write-Output "Built module artifact at: $OutputRoot"
Write-Output 'Files:'
$outputFiles | ForEach-Object { Write-Output (" - {0}" -f $_.Name) }
