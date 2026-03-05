# Roadmap

## Objective
Publier sur PowerShell Gallery un module **buildé** contenant uniquement:
- `ITFabrik.Logger.psd1`
- `ITFabrik.Logger.psm1`
- `LICENSE`
- `README.md`

## Phase 1 - Build System
- Créer `Scripts/Build-Module.ps1`.
- Générer `dist/ITFabrik.Logger/ITFabrik.Logger.psm1` self-contained (merge ordonné des classes/fonctions publiques/privées).
- Copier `ITFabrik.Logger.psd1`, `LICENSE`, `README.md` dans `dist/ITFabrik.Logger`.
- Adapter le manifeste dist (au minimum vérifier `RootModule`; option: `FileList` explicite).
- Status: **Done**

Deliverables:
- `Scripts/Build-Module.ps1`
- `dist/ITFabrik.Logger/*` généré localement

## Phase 2 - Publish Path Hardening
- Modifier `Scripts/Publish-PSGallery.ps1` pour publier depuis `dist/ITFabrik.Logger`.
- Ajouter un garde: erreur si `dist` absent ou incomplet.
- Status: **Done**

Deliverables:
- `Scripts/Publish-PSGallery.ps1` mis à jour

## Phase 3 - Workflow Integration
- Mettre à jour `.github/workflows/publish.yml`:
  - build artifact
  - vérification contenu minimal
  - publication depuis `dist`
- Conserver validation tag/version déjà existante.
- Status: **Done**

Deliverables:
- `.github/workflows/publish.yml` mis à jour

## Phase 4 - Validation
- Ajouter des checks build:
  - `Test-ModuleManifest` sur `dist/ITFabrik.Logger/ITFabrik.Logger.psd1`
  - `Import-Module` sur artifact dist
  - ScriptAnalyzer sur artifact buildé (si pertinent)
- Ajouter un check de contenu strict (exactement 4 fichiers attendus).
- Status: **Done**

Deliverables:
- validation script intégrée au build/publish

## Phase 5 - Release Readiness
- Mettre à jour documentation release pour inclure la chaîne build -> validate -> publish.
- Ajouter rollback guide si publication Gallery échoue.
- Status: **Done**

Deliverables:
- docs release alignées

## Acceptance Criteria
- Le package publié contient uniquement les 4 fichiers demandés.
- `Import-Module` fonctionne depuis l’artifact publié.
- Workflow publish échoue si artifact incomplet/non buildé.
- Tag et `ModuleVersion` restent alignés.
