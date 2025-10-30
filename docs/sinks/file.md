# Sink Fichier

- Formats: `Default`, `Cmtrace`.
- Encodage par défaut: `UTF8BOM` (recommandé pour CMTrace et accents).
- Indentation: appliquée après `[Component]` (2 espaces/niveau) en `Default`.

Paramètres (via `Register-LoggerSink -Type File`)
- `-Path <chemin>` (obligatoire)
- `-FileFormat Default|Cmtrace` (défaut: `Default`)
- `-Rotation Size|Daily|NewFile` (facultatif)
- `-MaxSizeMB <n>` (pour `Size`, défaut: 5)
- `-MaxRolls <n>` (défaut: 3)
- `-Encoding UTF8BOM|...` (défaut: `UTF8BOM`)

Rotation
- `NewFile`: archive le fichier existant une fois au premier write de la session, puis écrit dans un nouveau fichier.
- `Size`: roll numérique `.1`, `.2`, … quand la taille dépasse `MaxSizeMB`.
- `Daily`: suffixe `yyyy-MM-dd` dans le nom du fichier.
- Omit `-Rotation`: premier write écrase/crée, suivants ajoutent (session courante).

