import { supabase } from "./supabase.js";

let authBtn = null;

/* ---------- UI ---------- */

function setLoggedOutUI() {
    if (!authBtn) return;

    authBtn.classList.remove("logged-in");
    authBtn.textContent = "Login";
    authBtn.title = "";

    authBtn.onclick = () => {
        window.location.href = "/login/login.html";
    };
}

function setLoggedInUI(user) {
    if (!authBtn) return;

    authBtn.classList.add("logged-in");
    authBtn.innerHTML = '<i class="fa fa-user-o"></i>';
    authBtn.title = user.email;

    authBtn.onclick = async () => {
        const ok = confirm("Cerrar sesión?");
        if (!ok) return;

        await supabase.auth.signOut();
        location.reload();
    };
}

/* ---------- Auth state ---------- */

async function checkAuth() {
    const { data } = await supabase.auth.getSession();
    const session = data.session;

    if (session?.user) {
        setLoggedInUI(session.user);
        window.dispatchEvent(new Event("user-logged-in"));
    } else {
        setLoggedOutUI();
        window.dispatchEvent(new Event("user-logged-out"));
    }
}

supabase.auth.onAuthStateChange((_event, session) => {
    if (session?.user) {
        setLoggedInUI(session.user);
        window.dispatchEvent(new Event("user-logged-in"));
    } else {
        setLoggedOutUI();
        window.dispatchEvent(new Event("user-logged-out"));
    }
});

/* ---------- Init ---------- */

document.addEventListener("DOMContentLoaded", () => {
    authBtn = document.getElementById("auth-btn");
    checkAuth();
});
