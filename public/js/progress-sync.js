import { supabase } from "./supabase.js";

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
            data: progress,
            updated_at: new Date().toISOString()
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
            return;
        }

        // 👤 LOGUEADO
        const userId = session.user.id;

        const local = loadLocal();
        const remote = await loadRemote(userId);

        let finalProgress;

        if (local && remote) {
            // elegimos el más completo
            finalProgress =
                JSON.stringify(local).length >= JSON.stringify(remote).length
                    ? local
                    : remote;
        } else {
            finalProgress = local || remote || defaultProgress();
        }

        // sincronizamos ambos
        saveLocal(finalProgress);
        await saveRemote(userId, finalProgress);

        window.getProgress = () => finalProgress;

        window.saveProgress = async (p) => {
            finalProgress = p;
            saveLocal(p);
            await saveRemote(userId, p);
        };
    }

    document.addEventListener("DOMContentLoaded", setupProgressSync);

    // re-sync cuando el usuario se loguea
    supabase.auth.onAuthStateChange((event) => {
        if (event === "SIGNED_IN" || event === "SIGNED_OUT") {
            setupProgressSync();
        }
    });
})();
