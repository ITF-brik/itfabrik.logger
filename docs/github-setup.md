# Procedure GitHub pour ITFabrik.Logger

Ce document decrit la creation du depot GitHub, la configuration des secrets et des workflows pour publier le module sur PowerShell Gallery et executer les tests Pester.

## 1) Creer le depot sur GitHub
- Nom: `ITFabrik.Logger`
- Visibilite: Public (recommande pour un module publie)
- Ne pas initialiser avec README / .gitignore / licence (ces fichiers existent deja localement)

Via l'UI GitHub:
1. New repository ^ Name: `ITFabrik.Logger`
2. Public
3. Laisser decoche "Add a README", "Add .gitignore", "Choose a license"
4. Create repository

Option CLI (si GitHub CLI):
```bash
gh repo create ITFabrik.Logger --public --source . --remote origin --push
```

## 2) Preparer le depot local
Dans `c:\Developpement\Scripting\Modules\ITFabrik.Logger`:
```powershell
git init
git branch -M main
# Optionnel : identite locale si necessaire
git config user.name "Votre Nom"
git config user.email "votre.email@domaine"
```
Un `.gitignore` adapte a ete ajoute: `.gitignore`.
Puis premier commit:
```powershell
git add .
git commit -m "Initial commit: ITFabrik.Logger"
```

## 3) Lier le remote et pousser
Recuperez l'URL GitHub (ex: `https://github.com/<org>/ITFabrik.Logger.git`) puis:
```powershell
git remote add origin https://github.com/<org>/ITFabrik.Logger.git
git push -u origin main
```

## 4) Configurer GitHub Actions
Deux workflows existent dans `.github/workflows`:
- Publication: `.github/workflows/publish.yml` - declenche manuellement (`workflow_dispatch`) ou lors d'une release publiee; publie sur PowerShell Gallery via `Scripts/Publish-PSGallery.ps1`.
- CI Pester: `.github/workflows/ci.yml` - execute les tests Pester sur `push` et `pull_request`.

Permissions Actions (par defaut suffisantes):
- Settings ^ Actions ^ General ^ Workflow permissions ^ Read repository contents

## 5) Secret PowerShell Gallery
Le workflow de publication requiert `PSGALLERY_API_KEY`.
- PowerShell Gallery ^ Profile ^ API Keys ^ Creer une cle (Scope: Push, expiration selon besoin)
- GitHub ^ Repository ^ Settings ^ Secrets and variables ^ Actions ^ New repository secret
  - Name: `PSGALLERY_API_KEY`
  - Value: la cle API copiee

## 6) Publier une nouvelle version

Deux options pour garder `ModuleVersion` et le tag `vX.Y.Z` alignes:

- Source de verite = manifeste (recommande)
  1. Mettre a jour `ModuleVersion` dans `ITFabrik.Logger.psd1`.
  2. Commit & push:
     ```powershell
     git add ITFabrik.Logger.psd1
     git commit -m "Bump version to X.Y.Z"
     git push
     ```
  3. Creer et (optionnel) pousser le tag depuis le manifeste:
     ```powershell
     ./Scripts/New-ReleaseTag.ps1 -Push
     ```
  4. Creer une release GitHub (le tag existe deja):
     - Releases ^ Draft a new release
     - Tag: selectionner `vX.Y.Z`
     - Target: `main`
     - Publish release

- Source de verite = tag (moins pratique)
  - Creer un tag `vX.Y.Z`, puis mettre a jour manuellement `ModuleVersion = 'X.Y.Z'` dans le manifeste dans le meme commit/PR. (Le workflow refusera la publication si non aligne.)

Le workflow de publication contient une etape de validation qui echoue si `ModuleVersion` <> `vX.Y.Z`.

## 7) Bonnes pratiques
- Proteger `main` (PRs et reviews) une fois le depot public.
- Maintenir `ModuleVersion` et le tag `vX.Y.Z` alignes.
- Ajouter des Topics GitHub: `powershell`, `powershell-module`, `logging`.
- Tests Pester: les fichiers dans `Tests/` sont lances par `.github/workflows/ci.yml`.

References utiles:
- Workflow publication: `.github/workflows/publish.yml`
- Workflow CI: `.github/workflows/ci.yml`
- Validation tag à la poussée: `.github/workflows/check-tag.yml`
- Script de publication: `Scripts/Publish-PSGallery.ps1`
- Manifest module: `ITFabrik.Logger.psd1`
