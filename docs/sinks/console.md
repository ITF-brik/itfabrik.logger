# Sink Console

- Format: identique à `Write-StepMessage` (icônes PS7+, padding, couleurs).
- Indentation: `IndentLevel` (2 espaces par niveau) avant le message.
- StepName: affiché entre crochets s'il est fourni.
- Component: non affiché (évite la duplication avec StepManager).

Note
- Padding de sévérité et indentation sont alignés avec le format Fichier (Default) grâce au helper partagé `Get-LoggerPrefix`.

Exemple
- `[2025-01-01 12:00:00] ✓···  [Step1] Démarrage`
