# Changelog

All notable changes to this project will be documented in this file.
The format is based on Keep a Changelog, and this project adheres to SemVer.

## [Unreleased] (0.2.0)
### Added
- Helper partagé pour préfixe de message (icône/padding/indentation/StepName) [planned]
- Exposition StepName (+ ForegroundColor optionnel) jusqu’aux sinks [planned]
- Exemples de config psd1/JSON + Initialize-LoggerFromConfig [planned]
- Tests Pester supplémentaires (indentations multiples, padding Severity, cas limites Cmtrace) [planned]

### Changed
- Documentation et README à ajuster suite aux nouvelles API [planned]

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

[Unreleased]: https://github.com/ITF-brik/itfabrik.logger/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/ITF-brik/itfabrik.logger/releases/tag/v0.1.0
