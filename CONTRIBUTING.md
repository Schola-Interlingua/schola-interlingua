# Guia pro contributores — Schola Interlingua

Gratias pro tu interesse in contribuer a Schola Interlingua! Iste guida explica como le projecto functiona e como tu pote adjutar, passo a passo.

---

## Configuration initial

### 1. Fork e clone

```bash
# 1. Face un fork in GitHub (button "Fork" in alto a dextra)

# 2. Clona tu fork
git clone https://github.com/TU-USATOR/schola-interlingua.git
cd schola-interlingua

# 3. Adde le repositorio original como "upstream"
git remote add upstream https://github.com/Schola-Interlingua/schola-interlingua.git
```

### 2. Execution local

Le sito non require compilation ni installationes. Tu solo necessita un servitor local:

```bash
# Con Python (le plus simple)
python3 -m http.server 8000 -d public

# Con Node.js
npx serve public

# Con PHP
php -S localhost:8000 -t public
```

Aperi `http://localhost:8000` in tu navigator pro vider le sito.

### 3. Crea un branca pro tu cambios

```bash
git checkout -b feature/description-del-cambio
```

---

## Typos de contribution

### A. Adder o corriger vocabulario

Le vocabulario es in **`public/data/vocab.json`**. Cata lection o thema ha un array de objectos con le termino in Interlingua e su traduction in 13 linguas.

**Formato de un entrata de vocabulario:**

```json
{
  "term": "appartamento",
  "es": "departamento, apartamento",
  "en": "apartment",
  "ru": "квартира",
  "de": "Wohnung",
  "fr": "appartement",
  "it": "appartamento",
  "pt": "apartamento",
  "zh": "公寓",
  "ja": "アパート",
  "ca": "apartament",
  "ko": "아파트",
  "la": "apartamentum",
  "eo": "apartamento"
}
```

**Linguas supportate:** `es` (espaniol), `en` (anglese), `ru` (russo), `de` (germano), `fr` (francese), `it` (italiano), `pt` (portugese), `zh` (chinese), `ja` (japonese), `ca` (catalan), `ko` (coreano), `la` (latino), `eo` (esperanto).

**Pro adder un parola a un lection existente**, trova le array correspondente e adde le objecto:

```json
{
  "lection1": [
    ... parolas existente ...,
    {
      "term": "nove-parola",
      "es": "traducción",
      "en": "translation",
      ...
    }
  ]
}
```

**Pro corriger un traduction**, cerca le termino in le file e modifica le valor correspondente.

> **Nota:** Non es necessari completar tote le 13 linguas. Adde le linguas que tu cognosce; le systema monstra `es` (espaniol) como fallback si un lingua manca.

---

### B. Crear un nove lection thematic

Le lectiones thematic es le paginas in `public/lessons/`. Illos monstra vocabulario, quiz e exercitios de traduction.

**Passos:**

#### 1. Crear le file HTML

Crea `public/lessons/tu-thema.html` con iste structura:

```html
<!DOCTYPE html>
<html lang="es">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="stylesheet" href="/css/styles.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="apple-touch-icon" sizes="180x180" href="/icons/apple-touch-icon.png">
  <link rel="icon" type="image/png" sizes="32x32" href="/icons/favicon-32x32.png">
  <link rel="icon" type="image/png" sizes="16x16" href="/icons/favicon-16x16.png">
  <link rel="manifest" href="/icons/site.webmanifest">
  <link rel="icon" href="/icons/favicon.ico" type="image/x-icon">
  <title>Schola Interlingua - Tu Thema</title>
</head>

<body>
  <nav></nav>
  <main>
    <section id="vocab">
      <h2>Vocabulario</h2>
      <table class="table table-striped vocab-table">
        <thead>
          <tr>
            <th>Interlingua</th>
            <th>Tu lingua</th>
          </tr>
        </thead>
        <tbody></tbody>
      </table>
    </section>
    <div id="quiz-container"></div>
    <div id="exercise-container" data-lesson="tu-thema"></div>
    <script src="/js/quiz.js"></script>
    <script src="/js/exercises.js"></script>
    <script src="/js/tooltip.js"></script>
    <script src="/js/vocab-table.js"></script>
  </main>
  <footer></footer>
  <script src="/js/include.js"></script>
  <script src="/js/anki.js"></script>
</body>

</html>
```

> **Importante:** Le valor de `data-lesson` in le `exercise-container` debe corresponder exactemente al clave in `vocab.json`.

#### 2. Adder vocabulario in vocab.json

Adde un nove clave in `public/data/vocab.json`:

```json
{
  ... entratas existente ...,
  "tu-thema": [
    {
      "term": "parola1",
      "es": "...",
      "en": "...",
      ...
    },
    {
      "term": "parola2",
      "es": "...",
      "en": "...",
      ...
    }
  ]
}
```

#### 3. Registrar le lection in nav.js

Aperi `public/js/nav.js` e adde le slug del thema al array `cursoSlugs` e un icone al objecto `iconMap`:

```javascript
// In cursoSlugs, adde al fin:
const cursoSlugs = [
  "basico1", "basico2", ... "technologia",
  "tu-thema"   // <-- adde hic
];

// In iconMap, adde un icone Font Awesome:
const iconMap = {
  ... entratas existente ...,
  'tu-thema': 'fas fa-icon-nome'    // <-- adde hic
};
```

Trova icones disponibile in: https://fontawesome.com/icons (version 6, solo le icones gratuite/solid).

#### 4. Verificar

Aperi `http://localhost:8000/curso.html` e verifica que le nove lection appare. Clicca sur illo e verifica que le tabella de vocabulario, le quiz e le exercitios functiona.

---

### C. Adder un lectura (texto de comprehension)

Le lecturas es textos narrative in Interlingua, in `public/lecturas/`.

**Crea `public/lecturas/titulo-del-texto.html`:**

```html
<!DOCTYPE html>
<html lang="es">

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="../css/styles.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <title>Titulo del texto — Schola Interlingua</title>
</head>

<body>
  <nav></nav>
  <main>
    <section class="card reading-container">
      <h1 class="reading-title" data-tooltips>Titulo del texto</h1>
      <article class="reading-body" data-tooltips>
        <p>Prime paragrapho del texto in Interlingua...</p>
        <p>Secunde paragrapho...</p>
        <!-- Continua con plus paragraphos -->
      </article>
    </section>
  </main>
  <footer></footer>
  <script src="../js/include.js"></script>
  <script type="module" src="../js/login.js"></script>
  <script type="module" src="../js/nav.js"></script>
  <script src="../js/tooltip.js"></script>
  <script src="../js/anki-all.js"></script>
  <script src="../js/vocab.js"></script>
  <script src="../js/readings.js"></script>
</body>

</html>
```

> **Nota:** Le attributo `data-tooltips` activa le tooltips de vocabulario super le parolas del texto. Le paths usa `../` proque le lecturas es in un subdirectorio.

Pois, adde un ligamine in `public/components/navbar.html` sub le menu "Lege":

```html
<li><a href="/lecturas/titulo-del-texto.html">Titulo del texto</a></li>
```

---

### D. Modificar le stilo (CSS)

Tote le stilos es in un sol file: **`public/css/styles.css`**.

Le sito usa **variabiles CSS** pro le thema. Le principal:

```css
:root {
  --primary-color: #082743;
  --primary-light: #0d3a5f;
  --bg-color: #f5f5f5;
  --card-bg: #ffffff;
  --text-color: #333;
  --shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}
```

Le **modo obscur** se activa con le classe `dark-mode` in `<body>`. Pro assecurar que tu stilos functiona in ambe modos, usa le variabiles CSS o adde regulas sub `body.dark-mode`.

Le sito es **responsive** con media queries. Le puncto de ruptura principal es `600px` (mobile).

---

### E. Meliorar le JavaScript

Le modulos principal e lor functiones:

| File              | Responsabilitate                                                             |
| ----------------- | ---------------------------------------------------------------------------- |
| `include.js`      | Carga componentes (navbar, footer), initialisa metadata, analytics, scripts  |
| `nav.js`          | Navigation, dropdowns, authentication UI, modo obscur, lista de lectiones    |
| `exercises.js`    | Genera exercitios de traduction in bloccos de 5 parolas desde `vocab.json`   |
| `quiz.js`         | Quiz con 4 optiones aleatori per question, basate in `vocab.json`            |
| `vocab-table.js`  | Monstra le tabella de vocabulario con le lingua seligite per le usator       |
| `progress.js`     | Registra lectiones completate in localStorage e synchronisa con Supabase     |
| `tooltip.js`      | Tooltips interactive que monstra traductiones al passar le mouse             |
| `anki.js`         | Exporta le vocabulario de un lection como file de cartas Anki                |

**Punctos a considerar:**
- Le projecto usa **JavaScript vanilla** (sin frameworks). Mantene le cosas simple.
- Le modulos in `/js/` se carga como ES6 modules (`type="module"`) o como scripts classic, secundo le caso.
- Le vocabulario se carga sempre desde `/data/vocab.json` via `fetch()`.
- Le lingua del usator se lege de `localStorage.getItem('lang')`, con `'es'` como valor predeterminate.

---

### F. Reportar errores o suggerer melioramentos

Si tu non scribe codice, tu pote ancora adjutar multo:

1. **Aperir un Issue** in https://github.com/Schola-Interlingua/schola-interlingua/issues
2. Describer le error o suggestion con le plus detalio possibile
3. Si es un error visual, include un captura de schermo

---

## Como inviar tu contribution

### 1. Assecura que tu branca es actualisate

```bash
git fetch upstream
git rebase upstream/main
```

### 2. Verifica que nihil es rupte

Aperi le sito localmente e verifica:
- [ ] Le pagina principal carga correctemente
- [ ] Le navigation functiona (tote le menus)
- [ ] Si tu modificava vocabulario: le tabella, quiz e exercitios monstra le datos correcte
- [ ] Si tu creava un nove pagina: illo es accessibile e functiona
- [ ] Le modo obscur functiona ancora
- [ ] Le sito functiona in mobile (redimensiona le navigator)

### 3. Commit e push

```bash
git add -A
git commit -m "Describe tu cambios brevemente"
git push origin feature/description-del-cambio
```

### 4. Crea un Pull Request

Va a tu fork in GitHub e clicca "Compare & pull request". Describe:
- Que tu cambiava
- Proque tu lo cambiava
- Como verificar le cambios

---

## Conventiones del projecto

- **Lingua del codice**: commentarios e nomines de variabiles pote esser in espaniol o in interlingua
- **Lingua del contento**: le lectiones e textos de lectura es in **Interlingua**
- **Indentation**: 2 spatios
- **Nomines de files**: minuscula con hyphens (`mi-thema.html`, non `MiThema.html`)
- **Imagines**: formato PNG, collocate in `public/images/`
- **Audios**: formato MP3, collocate in `public/audios/`

---

## Questiones?

Junge te a nostre gruppo in Telegram: https://t.me/scholainterlingua
