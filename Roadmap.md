# Roadmap

Objectifs réalisés
- Logger console aligné sur Write-StepMessage (icônes, couleurs, indentation, StepName)
- Logger fichier avec formats Default et Cmtrace (XML-like)
- Encodage par défaut UTF8BOM (accents OK dans Cmtrace)
- Indentation placée après [Component] pour le format Default
- Champ Severity à largeur fixe dans le format Default
- Rotations: NewFile, Size, Daily, et rotation omise (écrase puis append par session)
- Documentation initiale dans `docs/` (sinks, formats, configuration, rotation, troubleshooting)
- CI GitHub Actions (Windows): tests Pester v5 avec configuration, coverage gate, cache des modules, concurrency et triggers manuels
- Publication automatisée PowerShell Gallery via release GitHub (tag `vX.Y.Z` aligné à `ModuleVersion`); badges CI/Coverage/Release dans le README

Court terme
- Uniformiser le calcul du préfixe (icône + padding + indentation + StepName) via un helper partagé (console + fichier Default)
- Exposer `StepName` (et éventuellement `ForegroundColor`) dans LoggerService jusqu'aux sinks de manière formelle
- Étendre les tests Pester (multi‑niveaux d'indentation, padding de Severity, cas limites Cmtrace)
- Ajouter un exemple de configuration (psd1/JSON) et un helper d'initialisation pour enregistrer les sinks au chargement

Moyen terme
- Réintroduire le Web sink (HTTP) côté API publique: `Url`, `ApiKey`, `Headers`; POST JSON, gestion d'erreurs/retries, timeouts configurables
- File sink asynchrone (buffer/queue) pour limiter l'impact I/O en scripts intensifs
- Changelog automatique (génération à partir des commits/tags) et notes de version

Long terme / idées
- Support de tree/branches piloté (IsLast) pour les messages hiérarchiques
- Sortie structurée optionnelle (JSON Lines) pour ingestion SIEM
- Intégrations possibles: adaptateur style Serilog, syslog/ETW

