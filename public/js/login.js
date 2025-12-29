import { supabase } from "./supabase.js";

document.addEventListener("DOMContentLoaded", () => {
    const form = document.getElementById("login-form");
    const emailInput = document.getElementById("email");
    const msg = document.getElementById("login-msg");

    // 🔒 Si no estamos en login.html, salimos sin romper nada
    if (!form || !emailInput || !msg) return;

    async function signInWithEmail(email) {
        msg.textContent = "Enviando link…";

        const { error } = await supabase.auth.signInWithOtp({
            email,
            options: {
                emailRedirectTo: window.location.origin
            }
        });

        if (error) {
            console.error(error);
            msg.textContent = "❌ Error al enviar el email";
        } else {
            msg.textContent = "📩 Te enviamos un link a tu email";
        }
    }

    form.addEventListener("submit", (e) => {
        e.preventDefault();

        const email = emailInput.value.trim();

        if (!email || !email.includes("@")) {
            msg.textContent = "Ingresá un email válido";
            return;
        }

        signInWithEmail(email);
    });
});
