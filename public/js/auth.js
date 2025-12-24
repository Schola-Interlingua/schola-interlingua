const SUPABASE_URL = "https://redvymknnxehwveyzmyw.supabase.co";
const SUPABASE_ANON_KEY =
    "sb_publishable_Glxb2zj9_JOfqbKu0oVy5Q_oUIl_leI";

const supabase = window.supabase.createClient(
    SUPABASE_URL,
    SUPABASE_ANON_KEY
);

// ---------- LOGIN FORM ----------
async function handleLogin(e) {
    e.preventDefault();

    const emailInput = document.getElementById("email");
    const msg = document.getElementById("login-msg");
    const email = emailInput.value.trim();

    if (!email || !email.includes("@")) {
        msg.textContent = "Ingresá un email válido";
        return;
    }

    msg.textContent = "Enviando link mágico…";

    const { error } = await supabase.auth.signInWithOtp({
        email,
        options: {
            emailRedirectTo: window.location.origin
        }
    });

    if (error) {
        console.error(error);
        msg.textContent = "❌ Error: " + error.message;
    } else {
        msg.textContent = "📩 Revisá tu email (spam también)";
    }
}

// ---------- SESSION CHECK ----------
async function checkAuth() {
    const { data } = await supabase.auth.getSession();
    if (data.session) {
        window.location.href = "/";
    }
}

// ---------- INIT ----------
document.addEventListener("DOMContentLoaded", () => {
    const form = document.getElementById("login-form");
    if (form) {
        form.addEventListener("submit", handleLogin);
    }

    checkAuth();
});
