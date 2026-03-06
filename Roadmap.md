# Roadmap

## Objective
Ajouter un nouveau sink `Serilog` à `ITFabrik.Logger` pour émettre des événements structurés compatibles avec l'écosystème Serilog, tout en conservant la compatibilité avec le contrat legacy `StepManagerLogger` et les sinks existants.

## Working Assumption
Le MVP introduit un **nouveau type de sink dédié** (`Serilog`) au lieu de surcharger `Web`, avec un premier transport **HTTP JSON structuré**. Cette option garde l'API explicite et limite le risque de régression sur le sink Web existant.

## Phase 1 - Contract Definition
- Définir le périmètre du mot "compatible":
  - mapping de niveaux
  - schéma d'événement
  - contraintes de transport
- Fixer le périmètre MVP:
  - compatibilité fonctionnelle avec les champs Serilog essentiels
  - pas de parité complète `LogEvent` tant que le contrat source n'expose pas propriétés/exception/template
- Status: **Done**

Deliverables:
- schéma cible du payload Serilog-like
- mapping des niveaux `Info|Success|Warning|Error|Debug|Verbose`
- limites explicites du MVP

## Phase 2 - Runtime Design
- Ajouter le type `Serilog` dans `Register-LoggerSink`.
- Ajouter un helper privé de projection d'événement vers le schéma Serilog-like.
- Ajouter `Invoke-SerilogSink.ps1` pour l'envoi HTTP JSON.
- Étendre `LoggerService.ConfigureService()` pour dispatcher vers le nouveau sink.
- Status: **Done**

Deliverables:
- `Private/Functions/Format-LoggerEventSerilog.ps1`
- `Private/Functions/Invoke-SerilogSink.ps1`
- `Public/Register-LoggerSink.ps1`
- `Private/Classes/LoggerService.ps1`

## Phase 3 - Public API & Usability
- Définir les options publiques minimales:
  - `-Url`
  - `-APIKey`
  - `-Headers`
  - `-OnError`
- Évaluer l'ajout d'un raccourci `Initialize-LoggerSerilog`.
- Documenter clairement la différence entre `Web` (générique) et `Serilog` (contrat structuré dédié).
- Status: **Done**

Deliverables:
- éventuel `Public/Initialize-LoggerSerilog.ps1`
- docs mises à jour

## Phase 4 - Validation
- Ajouter des tests Pester de registration du sink `Serilog`.
- Ajouter des tests de payload JSON:
  - niveau
  - timestamp
  - message rendu
  - propriétés standards projetées (`Component`, `IndentLevel`, `Host`, `ProcessId`)
- Ajouter des tests d'erreur (`Warn|Continue|Throw`) sur le nouveau sink.
- Status: **Done with local environment limitation**

Deliverables:
- `Tests/RegisterLoggerSink.Tests.ps1`
- `Tests/SerilogSink.Tests.ps1`
- mises à jour de couverture si nécessaire

## Phase 5 - Documentation & Release Readiness
- Mettre à jour `README.md`, `docs/configuration.md`, `docs/index.md`.
- Ajouter `docs/sinks/serilog.md`.
- Ajouter un exemple d'usage avec `ITFabrik.Stepper`.
- Status: **Done**

Deliverables:
- documentation utilisateur complète
- critères d'acceptation vérifiables

## Acceptance Criteria
- `Register-LoggerSink -Type Serilog ...` enregistre correctement le nouveau sink.
- Le dispatcher envoie un payload JSON structuré stable et documenté.
- Les politiques d'erreur `Warn|Continue|Throw` restent cohérentes avec les sinks existants.
- Les sinks `Console`, `File` et `Web` ne régressent pas.
- La documentation distingue clairement le sink `Serilog` du sink `Web`.
