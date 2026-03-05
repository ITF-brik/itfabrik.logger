param(
    [string]$ApiKey,
    [string]$Repository = 'PSGallery',
    [string]$ModulePath = (Join-Path $PSScriptRoot '..\dist\ITFabrik.Logger'),
    [switch]$ValidateOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$requiredFiles = @('ITFabrik.Logger.psd1', 'ITFabrik.Logger.psm1', 'LICENSE', 'README.md')

if (-not (Test-Path -LiteralPath $ModulePath)) {
    throw "ModulePath introuvable: $ModulePath. Exécutez d'abord ./Scripts/Build-Module.ps1"
}

$actualFiles = @(Get-ChildItem -LiteralPath $ModulePath -File | Select-Object -ExpandProperty Name)
$missing = @($requiredFiles | Where-Object { $_ -notin $actualFiles })
$extra = @($actualFiles | Where-Object { $_ -notin $requiredFiles })
if ($missing.Count -gt 0 -or $extra.Count -gt 0) {
    throw ("Contenu artifact invalide. Missing: [{0}] Extra: [{1}] (attendu: {2})" -f ($missing -join ', '), ($extra -join ', '), ($requiredFiles -join ', '))
}

$manifest = Join-Path $ModulePath 'ITFabrik.Logger.psd1'
if (-not (Test-Path -LiteralPath $manifest)) { throw "Manifest introuvable: $manifest" }

$name = (Import-PowerShellDataFile -LiteralPath $manifest).RootModule
if (-not $name -or -not (Test-Path -LiteralPath (Join-Path $ModulePath $name))) {
    throw "RootModule introuvable dans le manifeste: $name"
}

Test-ModuleManifest -Path $manifest | Out-Null
$imported = Import-Module -Name $manifest -Force -PassThru
if (-not $imported) { throw "Échec Import-Module sur artifact: $manifest" }
Remove-Module -Name $imported.Name -Force -ErrorAction SilentlyContinue

Write-Host "Publication du module depuis artifact: $ModulePath" -ForegroundColor Cyan

if ($ValidateOnly) {
    Write-Host "Validation-only: aucune publication exécutée." -ForegroundColor Green
    return
}

if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    throw 'ApiKey requis pour la publication (ou utiliser -ValidateOnly).'
}

try {
    Set-PSRepository -Name $Repository -InstallationPolicy Trusted -ErrorAction SilentlyContinue
} catch { }

Publish-Module -Path $ModulePath -Repository $Repository -NuGetApiKey $ApiKey -Verbose -Force
