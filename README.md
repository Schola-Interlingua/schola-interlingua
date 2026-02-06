# Schola Interlingua

Platteforma digital e de codice aperte pro promover le apprendimento de Interlingua IALA.

Iste sito es create e mantenite per **Ian Blas**.

### Gruppo dedicate a meliorar iste curso: https://t.me/scholainterlingua

---

## Structura del projecto

```
schola-interlingua/
├── public/                     # Tote le files del sito web
│   ├── index.html              # Pagina principal
│   ├── curso.html              # Grilla del curso con tote le lectiones thematic
│   ├── css/
│   │   └── styles.css          # Stilo global (themas, modo obscur, responsive)
│   ├── js/                     # Modulos JavaScript
│   │   ├── include.js          # Carga componentes (navbar, footer), metadata, analytics
│   │   ├── nav.js              # Navigation, authentication UI, modo obscur
│   │   ├── exercises.js        # Systema de exercitios de traduction
│   │   ├── quiz.js             # Quiz interactive con optiones multiple
│   │   ├── vocab-table.js      # Tabla de vocabulario multilingual
│   │   ├── tooltip.js          # Tooltips de vocabulario
│   │   ├── progress.js         # Systema de progresso (localStorage + Supabase)
│   │   ├── supabase.js         # Configuration del cliente Supabase
│   │   ├── anki.js             # Exportation de cartas Anki per lection
│   │   ├── anki-all.js         # Exportation Anki pro lecturas
│   │   ├── login.js            # Authentication via email
│   │   ├── vocab.js            # Utilitates de vocabulario
│   │   └── games-common.js     # Logica commun pro jocos
│   ├── components/             # Componentes HTML reutilisabile
│   │   ├── navbar.html         # Barra de navigation
│   │   ├── footer.html         # Pie de pagina
│   │   └── exercise.html       # Template de exercitios
│   ├── data/
│   │   └── vocab.json          # Base de datos de vocabulario (13 linguas)
│   ├── lection/               # 10 lectiones principal (con audio, imagines, grammatica)
│   │   └── lection[1-10].html
│   ├── lessons/               # 33 lectiones thematic (vocabulario + exercitios)
│   │   └── [thema].html
│   ├── lecturas/              # 10 textos de lectura comprehensibile
│   │   └── [titulo].html
│   ├── appendice/             # Material de referentia
│   │   ├── grammatica.html
│   │   ├── numeros.html
│   │   └── contos.html
│   ├── games/                 # Jocos interactive
│   │   └── wordsearch.html
│   ├── audios/                # Files MP3 (un per lection)
│   ├── images/                # Illustrationes e logo
│   └── icons/                 # Favicons e assets PWA
├── CONTRIBUTING.md            # Guida detaliate pro contributores
├── README.md                  # Iste file
└── LICENSE                    # GNU GPL v3
```

## Architectura technic

Iste projecto es un **sito web static** sin processo de compilation — le files se servi directemente.

| Componente         | Technologia                                    |
| ------------------ | ---------------------------------------------- |
| **Frontend**       | HTML5, CSS3, JavaScript vanilla (ES6 modules)  |
| **Hosting**        | Vercel                                         |
| **Base de datos**  | Supabase (PostgreSQL) — authentication e datos |
| **Icones**         | Font Awesome 6.4.0 (CDN)                       |
| **Analytics**      | Vercel Web Analytics                           |
| **Chat IA**        | Chatina (widget externe)                       |

### Como le sito functiona

1. **Componentes compartite**: `include.js` carga le `navbar.html` e `footer.html` dynamicamente in cata pagina via `fetch()`.
2. **Vocabulario**: Tote le datos de vocabulario es in `data/vocab.json`, organisate per lection/thema, con traductiones in 13 linguas.
3. **Exercitios**: `exercises.js` lege le vocabulario de `vocab.json` e genera bloccos de 5 parolas pro traducer.
4. **Quizzes**: `quiz.js` genera questiones aleatori con 4 optiones a partir del vocabulario.
5. **Linguas**: Le usator elige su lingua via le menu — le selection se salva in `localStorage` e affecta le tablas de vocabulario e exercitios.
6. **Progresso**: Le systema registra le lectiones completate in `localStorage` e, si le usator es authenticate, le synchronisa con Supabase.

### Execution local

Proque es un sito static, il basta un servitor local:

```bash
# Con Python
python3 -m http.server 8000 -d public

# Con Node.js (npx)
npx serve public

# Con PHP
php -S localhost:8000 -t public
```

Pois aperi `http://localhost:8000` in tu navigator.

---

## Como contribuir

Omne adjuta es benvenite! Vide le file **[CONTRIBUTING.md](CONTRIBUTING.md)** pro un guida detaliate con exemplos e instructiones passo a passo.

Manieras de contribuer:
- Adder o corriger vocabulario e traductiones
- Crear nove lectiones thematic
- Adder nove lecturas (textos de lectura)
- Meliorar le stilo o le functionalitate del sito
- Reportar errores o suggerer melioramentos via [Issues](https://github.com/Schola-Interlingua/schola-interlingua/issues)

### Contribution rapide

1. Face un **Fork** del repositorio
2. Crea un **branca**: `git checkout -b feature/tu-melioramento`
3. Face tu cambios e invia un **Pull Request**

### Donar via Bitcoin Cash (BCH)

Si tu prefere supportar le projecto financiarimente:

`bitcoincash:qr34wjn3peyaza9r4f0vacaspcm3jdtp25cxg59zqk`

*Tu contribution nos adjuta a mantener iste recurso libere e accessibile pro omnes.*

---

## Gratias

* Gratias special a **Carmelo Serraino** pro le contento fornite pro le curso.
* Multe gratias a **Martijn Dekker** pro le audios del dece lectiones e pro su contributiones via pull requests.
* Un sincere gratias a tote illes qui contribue a meliorar iste repositorio con lor suggestiones e aportes.
* Un regratiamento special a **Jacinto Jay Bowks**, creator de Chatina, pro su valorose collaboration e supporto al projecto.

---

## Licentia

Iste projecto es publicate sub le [GNU General Public License v3.0](LICENSE).
