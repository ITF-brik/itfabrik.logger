# Format: Default

Rendu
- `[$Timestamp] [<Severity pad à 10>] [Component]<indent> Message`
- Exemple: `[2025-10-24 10:31:57] [      Info] [ITFabrik.Stepper]    Démarrage`

Détails
- Severité à largeur fixe (10), alignée à droite dans les crochets.
- Indentation: 2 espaces/niveau, placée après `[Component]`.
- `Timestamp` peut venir du dispatcher global si l'appelant le fournit; sinon il est calculé à l'écriture.

Note
- L’alignement (largeur et indentation) est désormais factorisé via un helper partagé (`Get-LoggerPrefix`) afin de conserver un rendu strictement cohérent entre Console et Fichier (Default).
