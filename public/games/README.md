# Juegos Educativos - Schola Interlingua

Esta sección contiene juegos interactivos diseñados para ayudar a los estudiantes a practicar y mejorar su vocabulario en Interlingua.

## Juegos Disponibles

### Sopa de letras (`wordsearch.html`)

**Descripción**: Juego clásico de sopa de letras donde los jugadores deben encontrar palabras ocultas en una grilla de 10x10.

**Características**:
- **Palabras**: 6-8 términos aleatorios del vocabulario de Interlingua
- **Direcciones**: Horizontal, vertical y diagonal (ambas direcciones)
- **Interacción**: 
  - Mouse: Clic y arrastre para seleccionar letras
  - Teclado: Shift + flechas para navegar
- **Feedback visual**: Palabras encontradas se marcan en verde
- **Nuevas rondas**: Automáticas al completar todas las palabras

**Mecánica**:
1. Las palabras se colocan aleatoriamente en la grilla
2. Los espacios vacíos se llenan con letras aleatorias
3. El jugador selecciona letras consecutivas
4. Si la selección forma una palabra válida, se marca como encontrada
5. Al encontrar todas las palabras, se inicia una nueva ronda


## Características Comunes

### Vocabulario
- **Fuente**: Todos los juegos utilizan el archivo `public/data/vocab.json`
- **Selección**: Palabras se eligen aleatoriamente de todas las categorías
- **Filtros**: Solo se incluyen términos de longitud apropiada para cada juego

### Idiomas
- **Idioma activo**: Se obtiene de `localStorage.getItem('lang')` o español por defecto
- **Fallback**: Si no existe traducción en el idioma seleccionado, se usa inglés
- **Cambio dinámico**: Los juegos se recargan automáticamente al cambiar idioma

### Accesibilidad
- **Navegación por teclado**: Todos los elementos son accesibles via teclado
- **ARIA**: Uso de `aria-live` para anuncios de estado
- **Foco visible**: Indicadores claros de foco y selección
- **Lectores de pantalla**: Compatible con tecnologías asistivas

### Responsividad
- **Diseño adaptativo**: Funciona en dispositivos móviles y de escritorio
- **CSS Grid**: Layouts flexibles que se adaptan al tamaño de pantalla
- **Touch-friendly**: Interacciones optimizadas para dispositivos táctiles

## Estructura de Archivos

```
/games/
├── wordsearch.html     # Juego de sopa de letras
└── README.md          # Esta documentación

/js/
└── games-common.js    # Funciones compartidas entre juegos
```

## Funciones Comunes (`games-common.js`)

### Gestión de Vocabulario
- `loadVocab()`: Carga y cachea el archivo de vocabulario
- `getLang()`: Obtiene el idioma activo
- `pickTermAndGloss(item, lang)`: Extrae término y traducción de un ítem

### Utilidades
- `shuffle(arr)`: Baraja un array
- `sample(arr, n)`: Selecciona n elementos aleatorios
- `normalize(s)`: Normaliza texto (quita diacríticos)

### Gestión de Juegos
- `nextRound(onBuild)`: Helper para iniciar nueva ronda
- `announce(msg)`: Anuncia mensajes para accesibilidad
- `handleLoadError(container)`: Maneja errores de carga

## Personalización

### Nuevos Juegos
Para agregar un nuevo juego:

1. Crear archivo HTML en `/games/`
2. Incluir `games-common.js` y `include.js`
3. Usar las funciones comunes para consistencia
4. Agregar enlace en el navbar

### Modificaciones
- **Estilos**: Los juegos usan las variables CSS del tema principal
- **Vocabulario**: Se puede modificar la lógica de selección en cada juego
- **Idiomas**: Agregar nuevos idiomas en `vocab.json` y el navbar

## Compatibilidad

- **Navegadores**: Chrome, Firefox, Safari, Edge (versiones modernas)
- **Dispositivos**: Desktop, tablet, móvil
- **JavaScript**: ES6+ (no requiere transpilación)
- **Dependencias**: Solo archivos locales del proyecto

## Solución de Problemas

### Error de Carga de Vocabulario
- Verificar que `vocab.json` existe y es válido
- Revisar la consola del navegador para errores de red
- Usar el botón "Reintentar" que aparece automáticamente

### Problemas de Rendimiento
- Los juegos generan contenido off-DOM antes de inyectarlo
- Las rondas se limpian completamente antes de crear nuevas
- El vocabulario se cachea después de la primera carga

### Problemas de Accesibilidad
- Verificar que el foco se restaure correctamente
- Comprobar que los anuncios ARIA funcionen
- Probar navegación completa por teclado
