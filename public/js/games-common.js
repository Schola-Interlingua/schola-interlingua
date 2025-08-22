// Games Common JavaScript - Funciones compartidas para todos los juegos

// Configuración global
let vocabCache = null;
let currentLang = null;

// Función para cargar y cachear el vocabulario
async function loadVocab() {
    if (vocabCache) {
        return vocabCache;
    }
    
    try {
        const response = await fetch('/data/vocab.json');
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        vocabCache = await response.json();
        return vocabCache;
    } catch (error) {
        console.error('Error cargando vocabulario:', error);
        throw error;
    }
}

// Función para obtener el idioma activo
function getLang() {
    if (currentLang == null) {
        currentLang = localStorage.getItem('lang') || 'es';
    }
    return currentLang;
}

// Función para actualizar el idioma dinámicamente
function updateLang(newLang) {
    if (newLang && newLang !== currentLang) {
        currentLang = newLang;
        localStorage.setItem('lang', newLang);
        
        // Disparar evento personalizado
        const langChangeEvent = new CustomEvent('langChanged', { 
            detail: { newLang, oldLang: currentLang } 
        });
        document.dispatchEvent(langChangeEvent);
    }
}

// Función para barajar un array
function shuffle(arr) {
    const array = [...arr];
    for (let i = array.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [array[i], array[j]] = [array[j], array[i]];
    }
    return array;
}

// Función para tomar n elementos aleatorios de un array
function sample(arr, n) {
    const shuffled = shuffle(arr);
    return shuffled.slice(0, n);
}

// Función para normalizar texto (quitar diacríticos)
function normalize(s) {
    return s.normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '')
        .toLowerCase()
        .replace(/[^a-z]/g, '');
}

// Función para seleccionar término y glosa de un ítem
function pickTermAndGloss(item, lang) {
    const term = item.term;
    const gloss = item[lang] || item.en || term; // fallback a inglés si no existe el idioma
    return { term, gloss };
}

// Función para anunciar mensajes (accesibilidad)
function announce(msg) {
    const liveRegion = document.getElementById('live-region');
    if (liveRegion) {
        liveRegion.textContent = msg;
        // Limpiar después de un momento para permitir múltiples anuncios
        setTimeout(() => {
            liveRegion.textContent = '';
        }, 1000);
    }
}

// Función helper para la siguiente ronda
function nextRound(onBuild) {
    announce('¡Felicitaciones! Nueva ronda...');
    
    // Esperar un momento antes de construir la nueva ronda
    setTimeout(() => {
        onBuild();
        // Restaurar foco al primer elemento interactivo
        const firstInteractive = document.querySelector('[tabindex="0"], button, input, .game-cell, .game-card');
        if (firstInteractive) {
            firstInteractive.focus();
        }
    }, 1200);
}

// Función para obtener parámetros de URL
function getUrlParam(param) {
    const urlParams = new URLSearchParams(window.location.search);
    return urlParams.get(param);
}

// Función para generar seed aleatorio
function generateSeed() {
    return Math.floor(Math.random() * 1000000);
}

// Función para inicializar el idioma
function initLang() {
    currentLang = getLang();
    
    // Escuchar cambios en el idioma
    document.addEventListener('click', (e) => {
        if (e.target.classList.contains('lang-option')) {
            const newLang = e.target.dataset.lang;
            if (newLang && newLang !== currentLang) {
                currentLang = newLang;
                localStorage.setItem('lang', newLang);
                
                // Disparar evento personalizado para notificar el cambio de idioma
                const langChangeEvent = new CustomEvent('langChanged', { 
                    detail: { newLang, oldLang: currentLang } 
                });
                document.dispatchEvent(langChangeEvent);
            }
        }
    });
    
    // Escuchar cambios en localStorage (para sincronización entre pestañas)
    window.addEventListener('storage', (e) => {
        if (e.key === 'lang' && e.newValue && e.newValue !== currentLang) {
            currentLang = e.newValue;
            const langChangeEvent = new CustomEvent('langChanged', { 
                detail: { newLang: e.newValue, oldLang: currentLang } 
            });
            document.dispatchEvent(langChangeEvent);
        }
    });
}

// Función para manejar errores de carga
function handleLoadError(container, retryCallback) {
    container.innerHTML = `
        <div class="error-message">
            <p>Error al cargar el vocabulario. Por favor, intenta de nuevo.</p>
            <button class="btn btn-primary" onclick="location.reload()">Reintentar</button>
        </div>
    `;
}

// Inicializar cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', () => {
    initLang();
    
    // Crear región live para anuncios de accesibilidad si no existe
    if (!document.getElementById('live-region')) {
        const liveRegion = document.createElement('div');
        liveRegion.id = 'live-region';
        liveRegion.setAttribute('aria-live', 'polite');
        liveRegion.setAttribute('aria-atomic', 'true');
        liveRegion.style.position = 'absolute';
        liveRegion.style.left = '-10000px';
        liveRegion.style.width = '1px';
        liveRegion.style.height = '1px';
        liveRegion.style.overflow = 'hidden';
        document.body.appendChild(liveRegion);
    }
});

// Exportar funciones para uso en otros archivos
window.GamesCommon = {
    loadVocab,
    getLang,
    updateLang,
    shuffle,
    sample,
    normalize,
    pickTermAndGloss,
    announce,
    nextRound,
    getUrlParam,
    generateSeed,
    handleLoadError
};
