(async function () {
    const STORAGE_KEY = 'si_progress';

    async function getSession() {
        const { data } = await supabase.auth.getSession();
        return data.session;
    }

    function loadLocal() {
        const data = localStorage.getItem(STORAGE_KEY);
        return data ? JSON.parse(data) : { lessons: {}, streak: {} };
    }

    function saveLocal(progress) {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(progress));
    }

    async function loadRemote(userId) {
        const { data } = await supabase
            .from('progress')
            .select('data')
            .eq('user_id', userId)
            .single();

        return data?.data || null;
    }

    async function saveRemote(userId, progress) {
        await supabase
            .from('progress')
            .upsert({
                user_id: userId,
                data: progress,
                updated_at: new Date().toISOString()
            });
    }

    async function syncProgress() {
        const session = await getSession();

        if (!session) {
            window.getProgress = loadLocal;
            window.saveProgress = saveLocal;
            return;
        }

        const userId = session.user.id;
        const local = loadLocal();
        const remote = await loadRemote(userId);

        let finalProgress;

        if (local && remote) {
            finalProgress =
                JSON.stringify(local).length > JSON.stringify(remote).length
                    ? local
                    : remote;
        } else {
            finalProgress = local || remote || { lessons: {}, streak: {} };
        }

        saveLocal(finalProgress);
        await saveRemote(userId, finalProgress);

        window.getProgress = () => finalProgress;
        window.saveProgress = async (p) => {
            saveLocal(p);
            await saveRemote(userId, p);
        };
    }

    document.addEventListener('DOMContentLoaded', syncProgress);
    window.addEventListener('user-logged-in', syncProgress);
    window.addEventListener('user-logged-out', syncProgress);
})();
