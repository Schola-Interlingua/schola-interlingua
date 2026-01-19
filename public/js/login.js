import { supabase } from "./supabase.js";

const form = document.getElementById("login-form");
const emailInput = document.getElementById("email");
const msg = document.getElementById("login-msg");

async function signInWithEmail(email) {
    msg.textContent = "Inviante ligamine…";

    const { error } = await supabase.auth.signInWithOtp({
        email,
        options: {
            emailRedirectTo: window.location.origin
        }
    });

    if (error) {
        console.error(error);
        msg.textContent = "❌ Error al inviar le e-mail, proba de novo plus tarde.";
    } else {
        msg.textContent = "📩 Nos ha inviate un ligamine per e-mail.";
    }
}

if (form) {
    form.addEventListener("submit", (e) => {
        e.preventDefault();
        const email = emailInput.value.trim();
        if (!email || !email.includes("@")) {
            msg.textContent = "Entra un e-mail valide.";
            return;
        }
        signInWithEmail(email);
    });
}
