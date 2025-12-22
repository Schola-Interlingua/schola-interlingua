const SUPABASE_URL = "https://redvymknnxehwveyzmyw.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_Glxb2zj9_JOfqbKu0oVy5Q_oUIl_leI";

const supabase = window.supabase.createClient(
    SUPABASE_URL,
    SUPABASE_ANON_KEY
);

let authBtn;

// 3️⃣ UI
function setLoggedOutUI() {
    if (!authBtn) return;
    authBtn.textContent = "Entrar";
    authBtn.onclick = loginWithMagicLink;
}

function setLoggedInUI(email) {
    if (!authBtn) return;
    authBtn.textContent = "Salir";
    authBtn.title = email;
    authBtn.onclick = logout;
}

// 4️⃣ LOGIN MAGIC LINK
async function loginWithMagicLink() {
    const email = prompt("Ingresá tu email para recibir el link mágico:");
    if (!email) return;

    const { error } = await supabase.auth.signInWithOtp({
        email,
        options: {
            emailRedirectTo: window.location.origin
        }
    });

    if (error) {
        alert("Error: " + error.message);
    } else {
        alert("📩 Te enviamos un link a tu email");
    }
}

// 5️⃣ LOGOUT
async function logout() {
    await supabase.auth.signOut();
    localStorage.removeItem("si_supabase_uid");
    location.reload();
}

// 6️⃣ SESIÓN
async function checkAuth() {
    const {
        data: { session }
    } = await supabase.auth.getSession();

    if (session && session.user) {
        localStorage.setItem("si_supabase_uid", session.user.id);
        setLoggedInUI(session.user.email);
        window.dispatchEvent(new Event("user-logged-in"));
    } else {
        localStorage.removeItem("si_supabase_uid");
        setLoggedOutUI();
        window.dispatchEvent(new Event("user-logged-out"));
    }
}

// 7️⃣ LISTENER DE CAMBIOS
supabase.auth.onAuthStateChange((_event, session) => {
    if (session && session.user) {
        localStorage.setItem("si_supabase_uid", session.user.id);
        setLoggedInUI(session.user.email);
        window.dispatchEvent(new Event("user-logged-in"));
    } else {
        localStorage.removeItem("si_supabase_uid");
        setLoggedOutUI();
        window.dispatchEvent(new Event("user-logged-out"));
    }
});

// 8️⃣ INIT
document.addEventListener("DOMContentLoaded", async () => {
    authBtn = document.getElementById("auth-btn");
    if (!authBtn) return;
    await checkAuth();
});