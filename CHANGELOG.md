# Changelog

All notable changes to this project will be documented in this file.
The format is based on Keep a Changelog, and this project adheres to SemVer.

## [Unreleased]

## [0.3.0] - 2026-03-06
### Added
- Nouveau sink `Serilog` disponible via `Register-LoggerSink -Type Serilog`.
- Nouveau raccourci public `Initialize-LoggerSerilog`.
- Projection HTTP JSON Serilog-like avec `Timestamp`, `Level`, `MessageTemplate`, `RenderedMessage` et `Properties`.
- Documentation dédiée du sink Serilog avec exemples d'usage.

### Changed
- Le module exporte désormais `Initialize-LoggerSerilog`.
- La documentation utilisateur couvre maintenant l'usage du sink Serilog en complément des sinks `Console`, `File` et `Web`.

## [0.2.2] - 2026-03-05
### Fixed
- Format de ligne `Default` du sink fichier: indentation appliquée au message (après `[Component]`) pour garder une colonne composant stable.

## [0.2.1] - 2026-03-05
### Changed
- Workflow de publication CI ajusté pour autoriser un déclenchement manuel avec un tag de release en entrée.
- Tests CI durcis pour rendre le mock de date des snapshots indépendant de la locale.

### Fixed
- Script de publication `Scripts/Publish-PSGallery.ps1`: résolution explicite des chemins d'artifact avant import du manifeste.

## [0.2.0] - 2026-03-05
### Added
- Script de build `Scripts/Build-Module.ps1` pour générer un artifact minimal dans `dist/ITFabrik.Logger`.
- Exposition publique du sink Web via `Register-LoggerSink -Type Web` (`Url`, `APIKey`, `Headers`, `OnError`).
- Politique d'erreur explicite des sinks (`OnError = Warn|Continue|Throw`) et helper `Invoke-LoggerSinkError`.
- Couverture tests Pester pour la politique d'erreur et l'enregistrement des sinks.
- Fichier de settings `PSScriptAnalyzerSettings.psd1`.

### Changed
- Publication PSGallery basée sur artifact buildé (`dist/ITFabrik.Logger`) au lieu de la racine source.
- `Scripts/Publish-PSGallery.ps1` valide strictement le contenu artifact, le manifeste et l'import avant publication.
- Workflow `publish.yml` enrichi: build, contrôle strict des 4 fichiers, ScriptAnalyzer sur artifact, puis publish.
- Suppression de l'effet de bord à l'import: le module n'installe plus automatiquement la variable globale logger.
- Positionnement produit migré vers **ITFabrik.Stepper** (contrat `StepManagerLogger` conservé en legacy compat).
- Documentation release mise à jour pour la chaîne `build -> validate -> publish` et rollback associé.

### Fixed
- Suppression des `catch {}` silencieux dans les sinks fichier/web et meilleure observabilité des erreurs.

## [0.1.0] - 2025-11-03
### Added
- Logger Console aligné avec Write-StepMessage (icônes, couleurs, indentation, StepName)
- Logger Fichier avec formats Default et Cmtrace (compatible cmtrace.exe)
- Rotations: NewFile, Size, Daily, et mode sans rotation
- Encodages: UTF8BOM (défaut), UTF8, Unicode, etc.
- Documentation initiale (sinks, formats, configuration, rotation, troubleshooting)

### CI/CD
- Workflows Windows‑only: "CI - Tests", "CI - Coverage", "Publish to PowerShellGallery"
- Pester v5.5+: conversion psd1 → PesterConfiguration via New-PesterConfiguration
- Format CI GitHub (config.Output.CIFormat = 'GithubActions')
- Cache des modules PowerShell et installation conditionnelle de Pester
- Concurrency et workflow_dispatch pour exécutions manuelles

### Docs
- Badges README (Tests, Coverage, Release)
- Procédure de release et liens directs Releases
- Section "Exécuter les tests en local" (Pester v5)
- Roadmap mise à jour

### Fixed
- Erreurs d’invocation Pester (-Configuration incompatible avec -CI/-PassThru)

---

[Unreleased]: https://github.com/ITF-brik/itfabrik.logger/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/ITF-brik/itfabrik.logger/releases/tag/v0.3.0
[0.2.2]: https://github.com/ITF-brik/itfabrik.logger/releases/tag/v0.2.2
[0.2.1]: https://github.com/ITF-brik/itfabrik.logger/releases/tag/v0.2.1
[0.2.0]: https://github.com/ITF-brik/itfabrik.logger/releases/tag/v0.2.0
[0.1.0]: https://github.com/ITF-brik/itfabrik.logger/releases/tag/v0.1.0
