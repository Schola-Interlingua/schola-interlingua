const SUPABASE_URL = "https://redvymknnxehwveyzmyw.supabase.co";
const SUPABASE_ANON_KEY =
    "sb_publishable_Glxb2zj9_JOfqbKu0oVy5Q_oUIl_leI";

const supabase = window.supabase.createClient(
    SUPABASE_URL,
    SUPABASE_ANON_KEY
);

let authBtn = null;


function setLoggedOutUI() {
    if (!authBtn) return;
    authBtn.textContent = "Entrar";
    authBtn.title = "";
    authBtn.onclick = loginWithMagicLink;
}

function setLoggedInUI(email) {
    if (!authBtn) return;
    authBtn.textContent = "Salir";
    authBtn.title = email;
    authBtn.onclick = logout;
}


async function loginWithMagicLink() {
    const email = prompt("Ingresá tu email para recibir el link mágico:");

    if (!email) return;
    if (!email.includes("@")) {
        alert("Ingresá un email válido");
        return;
    }

    const { error } = await supabase.auth.signInWithOtp({
        email,
        options: {
            emailRedirectTo: window.location.origin
        }
    });

    if (error) {
        console.error(error);
        alert("Error al enviar el link: " + error.message);
    } else {
        alert("📩 Te enviamos un link a tu email");
    }
}


async function logout() {
    await supabase.auth.signOut();
    localStorage.removeItem("si_supabase_uid");
    location.reload();
}


async function checkAuth() {
    const { data } = await supabase.auth.getSession();
    const session = data.session;

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


document.addEventListener("DOMContentLoaded", async () => {
    authBtn = document.getElementById("auth-btn");
    if (!authBtn) return;

    await checkAuth();
});
