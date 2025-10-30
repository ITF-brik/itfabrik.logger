# Roadmap

Objectifs réalisés
- Logger console aligné sur Write-StepMessage (icônes, couleurs, indentation, StepName)
- Logger fichier avec formats Default et CMTrace (XML‑like)
- Encodage par défaut UTF8BOM (accents OK dans CMTrace)
- Indentation placée après [Component] pour le format Default
- Champ Severity à largeur fixe dans le format Default
- Rotations: NewFile, Size, Daily, et rotation omise (écrase puis append par session)
- Dossier docs/ ajouté (sinks, formats, configuration, rotation, troubleshooting)

Court terme
- Uniformiser le calcul du préfixe (icône + padding + indentation + StepName) via un helper partagé (console + fichier Default)
- Exposer `StepName` (et éventuellement `ForegroundColor`) dans LoggerService jusqu’aux sinks
- Ajuster/étendre les tests Pester (exemples multi‑niveaux d’indentation, padding de Severity)

Moyen terme
- Réintroduire le Web sink (HTTP) côté API publique: paramètres `Url`, `APIKey`, `Headers`; POST JSON, gestion d’erreurs et retries, timeouts configurables
- Option de configuration centralisée (fichier JSON/psd1) pour enregistrer les sinks au chargement
- File sink asynchrone (buffer/queue) pour limiter l’impact I/O en scripts intensifs

Long terme / idées
- Support de “tree/branches” piloté (IsLast) pour les messages hiérarchiques
- Sortie structurée (JSON Lines) optionnelle pour ingestion SIEM
- Publication PSGallery + CI release (versioning sémantique, changelog automatique)
