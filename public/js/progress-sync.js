const supabase = window.supabaseInstance;

(function () {
    const STORAGE_KEY = "si_progress";

    /* ---------- Local ---------- */
    function loadLocal() {
        const data = localStorage.getItem(STORAGE_KEY);
        return data ? JSON.parse(data) : null;
    }

    function saveLocal(progress) {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(progress));
    }

    function defaultProgress() {
        return {
            lessons: {},
            streak: { current: 0, best: 0, last_study_date: null }
        };
    }

    /* ---------- Supabase ---------- */
    async function loadRemote(userId) {
        const { data, error } = await supabase
            .from("progress")
            .select("data")
            .eq("user_id", userId)
            .single();

        if (error) return null;
        return data?.data || null;
    }

    async function saveRemote(userId, progress) {
        await supabase.from("progress").upsert({
            user_id: userId,
            data: progress
        });
    }

    /* ---------- Sync ---------- */
    async function setupProgressSync() {
        const { data } = await supabase.auth.getSession();
        const session = data.session;

        // 👤 INVITADO
        if (!session) {
            window.getProgress = () => loadLocal() || defaultProgress();
            window.saveProgress = (p) => saveLocal(p);
            // Mostrar botones de exportar/importar para usuarios no logueados
            const exportBtn = document.getElementById('export-progress');
            const importBtn = document.getElementById('import-progress');
            if (exportBtn) exportBtn.style.display = '';
            if (importBtn) importBtn.style.display = '';
            return;
        }

        // 👤 LOGUEADO
        const userId = session.user.id;

        const remote = await loadRemote(userId);
        const progress = remote || defaultProgress();

        window.getProgress = () => progress;

        window.saveProgress = async (p) => {
            await saveRemote(userId, p);
        };

        window.dispatchEvent(new Event("progress-sync-ready"));


        // Ocultar botones de exportar/importar para usuarios logueados
        const exportBtn = document.getElementById('export-progress');
        const importBtn = document.getElementById('import-progress');
        if (exportBtn) exportBtn.style.display = 'none';
        if (importBtn) importBtn.style.display = 'none';
    }

    document.addEventListener("DOMContentLoaded", setupProgressSync);

    // re-sync cuando el usuario se loguea
    supabase.auth.onAuthStateChange(async (event) => {
        if (event === "SIGNED_IN" || event === "SIGNED_OUT") {
            await setupProgressSync();
        }
    });
})();
