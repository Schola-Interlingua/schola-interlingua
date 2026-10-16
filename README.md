# Schola Interlingua
Platteforma digital e de codice aperte pro promover le apprendimento de Interlingua IALA.

Le projecto es developpate e mantenite per Ian Blas, un disveloppator basate in Buenos Aires, Argentina, con foco in software educative, apprendimento de linguas e etymologia.

### Gruppo dedicate a meliorar iste curso: https://t.me/scholainterlingua

### Google Play: https://play.google.com/store/apps/details?id=com.scholainterlingua.app

### App Store: https://apps.apple.com/us/app/schola-interlingua/id6783944116

---

## Stato actual del projecto
Le version principal de Schola Interlingua es ora le application **Flutter** disponibile in `flutter_app/`, pensate pro servir como base unic pro:
* web responsive
* Android
* iOS
* macOS

Vercel compila `flutter_app/` a cata push e publica `flutter_app/build/web/`. Le dossier `public/` conserva le ancian build e le paginas static; su JavaScript non es plus usate como build de production.

### Publication web automatic
`vercel.json` defini `bash scripts/build_web.sh` como commando de build. Le script installa Flutter 3.44.7 al revision fixate, restaura le dependentias del lockfile, executa le analyse e le tests, e genera un nove build release. Un error stoppa le publication; il non ha fallback al ancian build.

Le integration Git de Vercel publica `main` in production e crea previews pro le altere brancas. Le paginas `/about`, `/privacy`, `/terms` e `/delete-account` es preservate. Le JavaScript usa un nomine con hash e le files es revalidate pro evitar versiones ancian in le navigator. `/build-info.json` identifica le commit publicate.

Pro verificar localmente con le SDK fixate: `SCHOLA_FLUTTER_BIN="$(command -v flutter)" bash scripts/build_web.sh`. Non es necessari copiar builds a `public/` ni committer files generate.

### Builds mobile automatic, sin publication
Le workflow [Mobile builds](https://github.com/Schola-Interlingua/schola-interlingua/actions/workflows/mobile-builds.yml) executa le analyse e le tests a cata push a `main`, pois compila Android e iOS in parallelo. Illo pote etiam esser executate manualmente con **Run workflow**. Flutter es fixate a 3.44.7, como le build web, e le dependentias debe respectar le lockfile.

In GitHub, aperi **Actions → Mobile builds → le execution → Artifacts** pro discargar le archivos (conservate durante 14 dies). Cata artifact include le commit, le execution e le checksums:

* **Android:** APK e AAB compilate in release con un clave de firma de test temporari. Le APK servi pro provas; illo non pote actualisar le app official signate e un altere execution pote requirer un reinstallo. Le AAB non es signate pro Google Play.
* **iOS:** archivo `.xcarchive.tar.gz` de dispositivo sin firma, e `.app.tar.gz` pro le simulator del architectura indicate in `BUILD-INFO.txt`. Le paquetes tar conserva permisos e ligamines symbolic. Pro installar in un iPhone o exportar un IPA distribuibile, le archivo necessita le firma e le provisioning de Apple. Pro le simulator, extrahe le app e usa `xcrun simctl install booted Runner.app` in un Mac compatibile.

Iste workflow non usa claves de production, non crea GitHub Releases e non invia builds a Google Play, App Store ni TestFlight. Le publication in le botecas resta manual. Le build number del app resta illo definite in `pubspec.yaml`; le nomine del artifact identifica le commit e le tentativa.

### Como executar le app Flutter localmente
1. Entra in `flutter_app/`
2. Executa `flutter pub get`
3. Pro web: `flutter run -d chrome` o `flutter build web`

Le contento del curso, lectiones, vocabulario, lecturas, audio, traduction per parola, progresso e repetition integrate es mantenite in le migration Flutter.

## Functiones principal
Le app include actualmente:
* lectiones e vocabulario structurate per nivellos
* lecturas, appendices e practica integrate
* quiz rapide e repaso rapide con audio de pronunciation super parolas e phrases
* completar phrases del textos e dictato con le audios existente
* registro interne local de tentativas e adjutas pro le practica
* jocos como le sopa de litteras con audio quando on toca le parola
* synchronization de progresso con Supabase quando le usator aperi session
* deletion de conto con passos de confirmation pro evitar deletion accidental
* supporto pro web, Android, iOS e macOS ab le mesme base de codice

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
Le catalogo de practica carga su tres fontes in parallelo e indexa le exercitios per ID, fonte e modo. Le partes del curso es calculate un vice per catalogo e reutilisate; le cache non contine progresso del usator. Le selection de repaso gruppa le historia un vice e ordina solmente le eventos del exercitios considerate.

Pro comparar iste calculos con le implementation anterior: in `flutter_app/`, executa `flutter test tool/benchmark_learning.dart --reporter expanded`. Iste benchmark mesura solmente le algoritmos, non le velocitate total del app o de un dispositivo. Le tests de equivalenta verifica le ordine, le partitiones de contento e le programmation de repaso con historias non ordinate e eventos al mesme instante.

* Le direction del exercitios de pratica (prompt/answer) segue le mesme logica de **Traducer**: le prompt es `term` e le responsa es `item[lang] || item.es`, ubi `lang` veni del selector de linguas in le navbar.
* Le teclado in schermo deriva su claves del responsa correcte (le litteras in le parola) e adde extras in base al lingua seligite: pro Espaniol, on include `áéíóúüñ`.

---

### Gratias
* Gratias special a Carmelo Serraino pro le contento fornite pro le curso.
* Multe gratias etiam a Martijn Dekker pro le audios del dece lectiones e pro su contributiones via pull requests.
* Un sincere gratias a tote illes qui contribue a meliorar iste repositorio con lor suggestiones e aportes.
* Un regratiamento special a Jacinto Jay Bowks, creator de Chatina, pro su valorose collaboration e supporto al projecto.


### Practica in contexto
Le nove practica appare intra le lectiones, ante le practica de vocabulario existente. `flutter_app/assets/data/learning_activities.json` contine le phrases a completar, le responsas acceptate e le explicationes. Le dictatos es construite ab `vocab.json` e le manifesto del audios, con un maximo de octo exercitios per session; le session sequente priorisa actividades non ancora practicate o plus ancian.

Le historia usa le clave local `learning_practice_events_v1`. Illo registra le modo, activitate, responsa, resultato, indicios, revelationes, reproductiones, numero de tentativa e tempore transcurrite. Un correcte post un error, un indicio o un audio repetite es distinguite de un correcte al prime tentativa sin adjuta. Le responsas revelate non conta como correctes. Le registro non modifica le SRS existente e non es synchronisate inter dispositivos. Illo resta interne; le interfacie presenta solmente completar phrases e dictato, sin un tabula de historia o statisticas.

Validation del practica (2026-10-16): 35 tests Flutter, analyse sin problemas e build web release correcte. Le nove tests verifica le fontes del 38 phrases, existentia del audios de dictato, correction, indicios, revelationes, errores de audio, persistentia, scripturas concurrente e navigation a un altere lection. Le verification in le navigator local includeva un error e un indicio ante le correcte, un dictato correcte sin indicio, reproduction de un phrase WAV (HTTP 200), repetition del audio, revelation del responsa e historia identic post recargar le pagina. Le tests de widgets include un viewport de 320 px; dispositivos iOS/Android non esseva probate.
