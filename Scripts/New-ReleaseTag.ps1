<#!
.SYNOPSIS
  Crée un tag Git vX.Y.Z à partir de la ModuleVersion du manifeste.

.DESCRIPTION
  Lit `ITFabrik.Logger.psd1`, récupère `ModuleVersion`, vérifie le format SemVer
  basique, vérifie l'absence d'un tag existant du même nom, puis crée un tag
  annoté `vX.Y.Z`. Avec `-Push`, pousse le tag vers `origin`.

.PARAMETER Push
  Si présent, exécute `git push origin vX.Y.Z` après création du tag.

.EXAMPLE
  ./Scripts/New-ReleaseTag.ps1 -Push
  # Crée et pousse le tag correspondant à ModuleVersion.

.NOTES
  Nécessite Git installé et accessible dans le PATH.
#>
param(
    [switch]$Push
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$manifestPath = Join-Path $repoRoot 'ITFabrik.Logger.psd1'
if (-not (Test-Path -LiteralPath $manifestPath)) {
    throw "Manifest introuvable: $manifestPath"
}

$manifest = Import-PowerShellDataFile -LiteralPath $manifestPath
$version  = [string]$manifest.ModuleVersion
if ([string]::IsNullOrWhiteSpace($version)) {
    throw 'ModuleVersion manquante dans le manifeste.'
}

# Validation SemVer simple: X.Y.Z (optionnels pré-release/build non gérés ici)
if ($version -notmatch '^[0-9]+\.[0-9]+\.[0-9]+$') {
    throw "ModuleVersion '$version' n'est pas au format X.Y.Z"
}

$tag = "v$version"
Write-Host "Version du manifeste: $version -> Tag: $tag" -ForegroundColor Cyan

# Vérifie que Git est disponible
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'Git introuvable dans le PATH.'
}

# S'assure que l'on se trouve à la racine du dépôt
Push-Location $repoRoot
try {
    # Vérifie que le repo est Git
    git rev-parse --git-dir *> $null 2>&1
} catch {
    Pop-Location
    throw "Le dossier '$repoRoot' n'est pas un dépôt Git."
}

try {
    # Vérifie si le tag existe déjà
    $existing = git tag -l $tag
    if ($existing) {
        throw "Le tag '$tag' existe déjà. Rien à faire."
    }

    # Crée un tag annoté
    git tag -a $tag -m "Release $tag"
    Write-Host "Tag créé localement: $tag" -ForegroundColor Green

    if ($Push) {
        # Détermine le remote par défaut (origin)
        $remote = (git remote 2>$null) | Where-Object { $_ -eq 'origin' } | Select-Object -First 1
        if (-not $remote) { $remote = 'origin' }
        git push $remote $tag
        Write-Host "Tag poussé vers '$remote': $tag" -ForegroundColor Green
    }
} finally {
    Pop-Location
}

