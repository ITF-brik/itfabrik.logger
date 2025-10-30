# Rotation

- Omit `-Rotation`: premier write écrase/crée, suivants ajoutent (par session/chemin).
- `NewFile`: archive le fichier existant (roll .1, .2, …) au premier write, puis écrit dans un nouveau fichier.
- `Size`: roll numérique quand la taille dépasse `MaxSizeMB` (conserve jusqu’à `MaxRolls`).
- `Daily`: suffixe `yyyy-MM-dd` dans le nom du fichier.

