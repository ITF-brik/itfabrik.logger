# Format: CMTrace

Rendu XML-like compatible `cmtrace.exe`
- `<![LOG[Message]LOG]!><time="HH:mm:ss.ffffff" date="M-d-yyyy" component="Component" context="User" type="N" thread="Id" file="">`
- `type`: 1=Info, 2=Warning, 3=Error (autres → 1)
- L’encodage du fichier doit être `UTF8BOM` (recommandé) ou `Unicode` pour un affichage correct des accents.

Remarques
- Le paramètre `Timestamp` n’est pas utilisé directement; l’heure/date sont recalculées.
- L’indentation optionnelle peut précéder le message (préfixes arbre pris en charge si configurés).

