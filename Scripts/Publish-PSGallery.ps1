param(
    [Parameter(Mandatory)] [string]$ApiKey,
    [string]$Repository = 'PSGallery'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$manifest = Join-Path $PSScriptRoot '..\ITFabrik.Logger.psd1'
if (-not (Test-Path -LiteralPath $manifest)) { throw "Manifest introuvable: $manifest" }

$moduleRoot = Split-Path -Parent $manifest
$name = (Import-PowerShellDataFile -LiteralPath $manifest).RootModule
if (-not $name -or -not (Test-Path -LiteralPath (Join-Path $moduleRoot $name))) {
    throw "RootModule introuvable dans le manifeste: $name"
}

Write-Host "Publication du module depuis: $moduleRoot" -ForegroundColor Cyan

try {
    Set-PSRepository -Name $Repository -InstallationPolicy Trusted -ErrorAction SilentlyContinue
} catch { }

Publish-Module -Path $moduleRoot -Repository $Repository -NuGetApiKey $ApiKey -Verbose -Force

