(function (global) {
  const ESPEAK_BASE_URL = 'https://cdn.jsdelivr.net/npm/espeakng-emscripten@1.0.0/dist/';
  const ESPEAK_JS_URL = `${ESPEAK_BASE_URL}espeakng.js`;

  let espeakPromise = null;

  class AudioManager {
    constructor() {
      this.audioContext = null;
      this.currentSource = null;
    }

    getContext() {
      if (!this.audioContext) {
        this.audioContext = new (global.AudioContext || global.webkitAudioContext)();
      }
      return this.audioContext;
    }

    stop() {
      if (this.currentSource) {
        try {
          this.currentSource.stop();
        } catch (error) {
          // Ignorar si ya se detuvo.
        }
        this.currentSource.disconnect();
        this.currentSource = null;
      }
    }

    async playPcm(samples, sampleRate = 22050) {
      this.stop();
      const context = this.getContext();
      if (context.state === 'suspended') {
        await context.resume();
      }
      const normalized = normalizeSamples(samples);
      const buffer = context.createBuffer(1, normalized.length, sampleRate);
      buffer.getChannelData(0).set(normalized);
      const source = context.createBufferSource();
      source.buffer = buffer;
      source.connect(context.destination);
      source.start(0);
      this.currentSource = source;
      source.onended = () => {
        if (this.currentSource === source) {
          this.currentSource = null;
        }
      };
    }
  }

  const audioManager = new AudioManager();

  function normalizeSamples(samples) {
    if (!samples) return new Float32Array();
    if (samples instanceof Float32Array) return samples;
    if (samples instanceof Int16Array) {
      const output = new Float32Array(samples.length);
      for (let i = 0; i < samples.length; i += 1) {
        output[i] = samples[i] / 32768;
      }
      return output;
    }
    if (Array.isArray(samples)) {
      return new Float32Array(samples.map(value => value / 32768));
    }
    return new Float32Array();
  }

  function extractAudio(result) {
    if (!result) {
      throw new Error('Resultado de audio vacío.');
    }
    if (result.samples) {
      return {
        samples: result.samples,
        sampleRate: result.sampleRate || result.sample_rate || 22050
      };
    }
    if (result.audio) {
      return {
        samples: result.audio,
        sampleRate: result.sampleRate || result.sample_rate || 22050
      };
    }
    if (result.pcm) {
      return {
        samples: result.pcm,
        sampleRate: result.sampleRate || result.sample_rate || 22050
      };
    }
    if (result instanceof Int16Array || result instanceof Float32Array) {
      return {
        samples: result,
        sampleRate: result.sampleRate || 22050
      };
    }
    throw new Error('Formato de audio no reconocido.');
  }

  function loadScript(src) {
    return new Promise((resolve, reject) => {
      const existing = document.querySelector(`script[data-espeak-src="${src}"]`);
      if (existing) {
        if (existing.dataset.loaded === 'true') {
          resolve();
          return;
        }
        existing.addEventListener('load', () => resolve());
        existing.addEventListener('error', () => reject(new Error('No se pudo cargar eSpeak.')));
        return;
      }
      const script = document.createElement('script');
      script.src = src;
      script.async = true;
      script.dataset.espeakSrc = src;
      script.addEventListener('load', () => {
        script.dataset.loaded = 'true';
        resolve();
      });
      script.addEventListener('error', () => reject(new Error('No se pudo cargar eSpeak.')));
      document.head.appendChild(script);
    });
  }

  async function initEspeak() {
    if (espeakPromise) return espeakPromise;
    espeakPromise = (async () => {
      await loadScript(ESPEAK_JS_URL);
      const factory =
        global.createESpeakNG ||
        global.espeakng ||
        global.ESpeakNG ||
        global.createEspeakNG;
      if (typeof factory === 'function') {
        return factory({
          locateFile: (path) => `${ESPEAK_BASE_URL}${path}`
        });
      }
      if (global.Module && (global.Module.cwrap || global.Module.ccall)) {
        return global.Module;
      }
      throw new Error('No se encontró el módulo de eSpeak NG.');
    })();
    return espeakPromise;
  }

  function resolveLang(optionsLang) {
    if (optionsLang) return optionsLang;
    return 'ia';
  }

  async function synthesize(module, text, options) {
    if (typeof module.speak === 'function') {
      return module.speak(text, options);
    }
    if (typeof module.synthesize === 'function') {
      return module.synthesize(text, options);
    }
    if (typeof module.espeakng === 'function') {
      return module.espeakng(text, options);
    }
    throw new Error('API de síntesis no disponible.');
  }

  async function speak(text, options = {}) {
    const cleaned = (text || '').trim();
    if (!cleaned) return;
    const module = await initEspeak();
    audioManager.stop();
    const lang = resolveLang(options.lang);
    const rate = options.rate ?? 175;
    const pitch = options.pitch ?? 50;
    const result = await synthesize(module, cleaned, {
      lang,
      voice: lang,
      rate,
      speed: rate,
      pitch
    });
    const { samples, sampleRate } = extractAudio(result);
    await audioManager.playPcm(samples, sampleRate);
  }

  function stop() {
    audioManager.stop();
  }

  global.TTS = {
    initEspeak,
    speak,
    stop
  };
})(window);
