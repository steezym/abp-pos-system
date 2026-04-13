// Login Page Logic
document.addEventListener('DOMContentLoaded', function () {
    const form = document.getElementById('loginForm');
    const emailInput = document.getElementById('email');
    const passwordInput = document.getElementById('password');
    const btnLogin = document.getElementById('btnLogin');
    const loginAlert = document.getElementById('loginAlert');
    const loginAlertMessage = document.getElementById('loginAlertMessage');

    // Hide alert on input
    emailInput.addEventListener('input', hideAlert);
    passwordInput.addEventListener('input', hideAlert);

    function hideAlert() {
        loginAlert.classList.add('d-none');
        emailInput.classList.remove('is-invalid');
        passwordInput.classList.remove('is-invalid');
    }

    function showAlert(message) {
        loginAlertMessage.textContent = message;
        loginAlert.classList.remove('d-none');
    }

    function setLoading(loading) {
        const btnText = btnLogin.querySelector('.btn-text');
        const btnLoader = btnLogin.querySelector('.btn-loader');
        btnLogin.disabled = loading;

        if (loading) {
            btnText.classList.add('d-none');
            btnLoader.classList.remove('d-none');
        } else {
            btnText.classList.remove('d-none');
            btnLoader.classList.add('d-none');
        }
    }

    // Handle login form submit
    form.addEventListener('submit', async function (e) {
        e.preventDefault();
        hideAlert();

        const email = emailInput.value.trim();
        const password = passwordInput.value;

        // Validation
        let isValid = true;
        if (!email || !email.includes('@')) {
            emailInput.classList.add('is-invalid');
            isValid = false;
        }
        if (!password) {
            passwordInput.classList.add('is-invalid');
            isValid = false;
        }
        if (!isValid) return;

        setLoading(true);

        try {
            const data = await api.post('/login', { email, password });

            // Save token and user
            api.setToken(data.data.token);
            api.setUser(data.data.user);

            // Redirect to dashboard
            window.location.href = 'index.html';
        } catch (error) {
            const msg = error.data?.message || error.data?.errors?.email?.[0] || 'Login gagal. Periksa email dan password Anda.';
            showAlert(msg);
        } finally {
            setLoading(false);
        }
    });

    // Focus email input on load
    emailInput.focus();
});
