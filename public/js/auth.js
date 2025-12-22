const SUPABASE_URL = "https://redvymknnxehwveyzmyw.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_Glxb2zj9_JOfqbKu0oVy5Q_oUIl_leI";

const supabase = window.supabase.createClient(
    SUPABASE_URL,
    SUPABASE_ANON_KEY
);

window.authState = {
    user: null
};

// Chequear sesión al cargar
async function initAuth() {
    const { data: { session } } = await supabase.auth.getSession();
    window.authState.user = session?.user || null;
}

initAuth();

// Login magic link
async function loginWithMagicLink(email) {
    const { error } = await supabase.auth.signInWithOtp({
        email,
        options: {
            emailRedirectTo: window.location.origin
        }
    });

    if (error) throw error;
}

// Logout
async function logout() {
    await supabase.auth.signOut();
    window.authState.user = null;
}

window.loginWithMagicLink = loginWithMagicLink;
window.logout = logout;