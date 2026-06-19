# Schola Interlingua
Platteforma digital e de codice aperte pro promover le apprendimento de Interlingua IALA.

Iste sito es create e mantenite per **Ian Blas**.

### Gruppo dedicate a meliorar iste curso: https://t.me/scholainterlingua

---

## Stato actual del projecto
Le version principal de Schola Interlingua es ora le application **Flutter** disponibile in `flutter_app/`, pensate pro servir como base unic pro:
* web responsive
* Android
* iOS
* macOS

Le dossier `public/` contine le build web generate de iste application e es le variante publicabile del sito.

### Como executar le app Flutter localmente
1. Entra in `flutter_app/`
2. Executa `flutter pub get`
3. Pro web: `flutter run -d chrome` o `flutter build web`

Le contento del curso, lectiones, vocabulario, lecturas, audio, traduction per parola, progresso e repetition integrate es mantenite in le migration Flutter.

---

## 🚀 Como contribuir
Omne adjuta es benvenite! Si tu vole dar nos un mano pro meliorar iste platteforma, tu pote facer lo in plure manieras:

### 💻 Contribuer con codice
Si tu es un disveloppator o si le technologia te interessa, tu pote adjutar in iste manieras:
1. Face un **Fork** del repositorio.
2. Crea un nove **Branca** (branch) pro tu modificationes (`git checkout -b feature/nome-del-melioramento`).
3. Invia un **Pull Request** con un description detaliate del cambios.

### 💰 Donar via Bitcoin Cash (BCH)
Si tu prefere supportar le projecto financiarimente pro coperir le disveloppamento e le mantenentia, tu pote inviar un donation in Bitcoin Cash al sequente adresse: bitcoincash:qr34wjn3peyaza9r4f0vacaspcm3jdtp25cxg59zqk

*Tu contribution nos adjuta a mantener iste recurso libere e accessibile pro omnes.*

---

## 🛠️ Detalios Technic
Pro illes qui vole saper como le projecto es construite:
* **Hosting**: Le sito es actualmente hospitate in **Vercel**, con le build web de Flutter como front-end principal.
* **Base de datos**: Nos usa **Supabase** pro le gestion de usatores e le persistentia de datos.
* **Technologias**: Flutter, Supabase e assets del curso original mantenite in le migration.

### 🧩 Notas pro le practica del curso
* Le direction del exercitios de pratica (prompt/answer) segue le mesme logica de **Traducer**: le prompt es `term` e le responsa es `item[lang] || item.es`, ubi `lang` veni del selector de linguas in le navbar.
* Le teclado in schermo deriva su claves del responsa correcte (le litteras in le parola) e adde extras in base al lingua seligite: pro Espaniol, on include `áéíóúüñ`.

---

### Gratias
* Gratias special a Carmelo Serraino pro le contento fornite pro le curso.
* Multe gratias etiam a Martijn Dekker pro le audios del dece lectiones e pro su contributiones via pull requests.
* Un sincere gratias a tote illes qui contribue a meliorar iste repositorio con lor suggestiones e aportes.
* Un regratiamento special a Jacinto Jay Bowks, creator de Chatina, pro su valorose collaboration e supporto al projecto.
