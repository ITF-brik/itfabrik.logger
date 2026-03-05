# Procedure de publication d'une nouvelle release

Ce guide decrit, pas a pas, comment publier une nouvelle version du module ITFabrik.Logger sur PowerShell Gallery en restant aligne entre `ModuleVersion` (manifeste) et le tag Git `vX.Y.Z`.

## 1) Pre-requis
- Secret GitHub `PSGALLERY_API_KEY` configure (repository > Settings > Secrets and variables > Actions).
- Git installe et configure (remote `origin` pointe sur GitHub).
- Tests Pester fonctionnels en local.
- Choisir une version SemVer: `MAJOR.MINOR.PATCH` (ex: 0.2.1).

## 2) Valider localement
- Lancer les tests:
  - Avec config (Pester v5):
    ```powershell
    Import-Module Pester -MinimumVersion 5.5.0 -Force
    $cfg = New-PesterConfiguration -Hashtable (Import-PowerShellDataFile 'Tests/PesterConfig.psd1')
    Invoke-Pester -Configuration $cfg
    ```
  - Ou simple: `Invoke-Pester -Path Tests`
- Lancer l'analyse statique:
  ```powershell
  Import-Module PSScriptAnalyzer -MinimumVersion 1.22.0 -Force
  $targets = @('ITFabrik.Logger.psm1','Public','Private')
  $issues = foreach ($target in $targets) {
    Invoke-ScriptAnalyzer -Path $target -Recurse -Settings 'PSScriptAnalyzerSettings.psd1'
  }
  if ($issues) {
    $issues | Format-Table -AutoSize
    throw "ScriptAnalyzer found $($issues.Count) issue(s)."
  }
  ```
- Construire l'artifact publie:
  ```powershell
  ./Scripts/Build-Module.ps1
  ```
- Verifier l'artifact (sans publier):
  ```powershell
  ./Scripts/Publish-PSGallery.ps1 -ModulePath .\dist\ITFabrik.Logger -ValidateOnly
  ```
- Corriger si besoin jusqu'a ce que tout passe.

## 3) Mettre a jour la version
- Ouvrir `ITFabrik.Logger.psd1` et definir `ModuleVersion = 'X.Y.Z'`.
- Mettre a jour `CHANGELOG.md` si necessaire.
- Commit & push:
  ```powershell
  git add ITFabrik.Logger.psd1 CHANGELOG.md
  git commit -m "Bump version to X.Y.Z"
  git push
  ```

## 4) Creer et pousser le tag a partir du manifeste
- Utiliser le script fourni pour assurer l'alignement:
  ```powershell
  ./Scripts/New-ReleaseTag.ps1 -Push
  ```
- Ce script lit `ModuleVersion`, cree le tag `vX.Y.Z` et le pousse.
- Un workflow GitHub (`.github/workflows/check-tag.yml`) verifie automatiquement que le tag matche la `ModuleVersion`.

## 5) Creer la release GitHub
- Aller sur GitHub > Releases > Draft a new release
  - Lien direct: https://github.com/ITF-brik/itfabrik.logger/releases/new
  - Liste des releases: https://github.com/ITF-brik/itfabrik.logger/releases
- Tag: selectionner le tag cree `vX.Y.Z`.
- Target branch: `main`.
- Titre/notes: copier le resume du `CHANGELOG.md`.
- Publier la release.

## 6) Publication PowerShell Gallery
- Le workflow `.github/workflows/publish.yml` se declenche sur `release: published`.
- Il execute la chaine complete:
  - Validation tag/version
  - Build de l'artifact (`Scripts/Build-Module.ps1`)
  - Verification stricte du contenu (`psd1`, `psm1`, `LICENSE`, `README.md`)
  - ScriptAnalyzer sur l'artifact build
  - Publication via `Scripts/Publish-PSGallery.ps1` (source: `dist/ITFabrik.Logger`)

## 7) Verifier la publication
- Installer la version publiee depuis PSGallery (depuis une session propre):
  ```powershell
  Install-Module ITFabrik.Logger -Repository PSGallery -Scope CurrentUser -Force -RequiredVersion X.Y.Z
  Import-Module ITFabrik.Logger -RequiredVersion X.Y.Z -Force
  Get-Module ITFabrik.Logger | Select-Object Name,Version,Path
  ```

## 8) Bonnes pratiques
- Respecter SemVer: PATCH = fix, MINOR = ajout non cassant, MAJOR = rupture.
- Ne pas tagger manuellement a la main; preferer `New-ReleaseTag.ps1`.
- Proteger `main` (PR + review) si depot public.
- Completer/tenir a jour `CHANGELOG.md`.

## 9) Rattrapage (en cas d'erreur)
- Tag et manifeste non alignes:
  - Corriger `ModuleVersion` puis re-creer le tag avec le script, ou
  - Supprimer le tag et le repusher:
    ```powershell
    git tag -d vX.Y.Z
    git push origin :refs/tags/vX.Y.Z
    ./Scripts/New-ReleaseTag.ps1 -Push
    ```
- Echec de publication (secret manquant): ajouter `PSGALLERY_API_KEY` dans les Secrets et republier la release.
- Echec validation artifact (missing/extra files):
  - Regenerer l'artifact localement:
    ```powershell
    ./Scripts/Build-Module.ps1
    ./Scripts/Publish-PSGallery.ps1 -ModulePath .\dist\ITFabrik.Logger -ValidateOnly
    ```
  - Corriger le build si le contenu n'est pas exactement: `ITFabrik.Logger.psd1`, `ITFabrik.Logger.psm1`, `LICENSE`, `README.md`.
- Echec ScriptAnalyzer sur artifact build:
  - Reproduire localement:
    ```powershell
    Import-Module PSScriptAnalyzer -MinimumVersion 1.22.0 -Force
    Invoke-ScriptAnalyzer -Path .\dist\ITFabrik.Logger\ITFabrik.Logger.psm1 -Settings .\PSScriptAnalyzerSettings.psd1
    ```
  - Corriger le code source, rebuild, puis relancer la publication.
- Version PSGallery a retirer: utiliser l'interface PSGallery (ou `Unpublish-Module` si applicable) et corriger la release.

## Fichiers et commandes utiles
- Manifeste: `ITFabrik.Logger.psd1`
- Script tag: `Scripts/New-ReleaseTag.ps1`
- Workflow verif tag: `.github/workflows/check-tag.yml`
- Workflow publication: `.github/workflows/publish.yml`
- Build artifact: `Scripts/Build-Module.ps1`, `dist/ITFabrik.Logger/`
- Tests: `Tests/`, `Tests/PesterConfig.psd1`
