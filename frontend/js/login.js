// =========================
// LOGIKA HALAMAN LOGIN
// =========================
document.addEventListener('DOMContentLoaded', function () {

    // Ambil semua elemen yang dibutuhkan dari halaman
    const form = document.getElementById('loginForm');
    const usernameInput = document.getElementById('username');
    const passwordInput = document.getElementById('password');
    const btnLogin = document.getElementById('btnLogin');
    const loginAlert = document.getElementById('loginAlert');
    const loginAlertMessage = document.getElementById('loginAlertMessage');

    // =========================
    // SEMBUNYIKAN ERROR SAAT MENGETIK
    // =========================

    // Saat user mengetik username atau password,
    // pesan error sebelumnya akan disembunyikan
    usernameInput.addEventListener('input', hideAlert);
    passwordInput.addEventListener('input', hideAlert);

    function hideAlert() {

        // Sembunyikan kotak alert
        loginAlert.classList.add('d-none');

        // Hapus tanda merah pada input
        usernameInput.classList.remove('is-invalid');
        passwordInput.classList.remove('is-invalid');
    }

    // =========================
    // TAMPILKAN / SEMBUNYIKAN PASSWORD
    // =========================

    // Cari tombol/icon mata
    const togglePassword = document.querySelector('.toggle-password');

    if (togglePassword) {

        // Saat icon mata diklik
        togglePassword.addEventListener('click', function () {

            // Jika password tersembunyi maka tampilkan
            // Jika sedang tampil maka sembunyikan kembali
            const type =
                passwordInput.getAttribute('type') === 'password'
                    ? 'text'
                    : 'password';

            passwordInput.setAttribute('type', type);

            // Ubah icon mata terbuka / tertutup
            this.classList.toggle('bi-eye');
            this.classList.toggle('bi-eye-slash');
        });
    }

    // =========================
    // MENAMPILKAN PESAN ERROR
    // =========================
    function showAlert(message) {

        // Isi pesan error
        loginAlertMessage.textContent = message;

        // Tampilkan kotak alert
        loginAlert.classList.remove('d-none');
    }

    // =========================
    // MODE LOADING TOMBOL LOGIN
    // =========================
    function setLoading(loading) {

        // Teks normal tombol
        const btnText = btnLogin.querySelector('.btn-text');

        // Spinner/loading tombol
        const btnLoader = btnLogin.querySelector('.btn-loader');

        // Nonaktifkan tombol saat loading
        btnLogin.disabled = loading;

        if (loading) {

            // Sembunyikan teks Login
            btnText.classList.add('d-none');

            // Tampilkan spinner loading
            btnLoader.classList.remove('d-none');

        } else {

            // Tampilkan kembali teks Login
            btnText.classList.remove('d-none');

            // Sembunyikan spinner loading
            btnLoader.classList.add('d-none');
        }
    }

    // =========================
    // PROSES LOGIN
    // =========================

    // Jalankan saat form login disubmit
    form.addEventListener('submit', async function (e) {

        // Cegah halaman refresh
        e.preventDefault();

        // Sembunyikan error lama
        hideAlert();

        // Ambil data yang diketik user
        const username = usernameInput.value.trim();
        const password = passwordInput.value;

        // =========================
        // VALIDASI INPUT
        // =========================

        let isValid = true;

        // Jika username kosong
        if (!username) {

            // Beri tanda merah
            usernameInput.classList.add('is-invalid');
            isValid = false;
        }

        // Jika password kosong
        if (!password) {

            // Beri tanda merah
            passwordInput.classList.add('is-invalid');
            isValid = false;
        }

        // Hentikan proses jika ada data yang kosong
        if (!isValid) return;

        // Aktifkan loading
        setLoading(true);

        try {

            // =========================
            // KIRIM DATA LOGIN KE SERVER
            // =========================

            const data = await api.post('/login', {
                username,
                password
            });

            // =========================
            // SIMPAN DATA LOGIN
            // =========================

            // Simpan token autentikasi
            api.setToken(data.data.token);

            // Simpan data user
            api.setUser(data.data.user);

            // =========================
            // PINDAH KE DASHBOARD
            // =========================

            window.location.href = 'index.html';

        } catch (error) {

            // =========================
            // JIKA LOGIN GAGAL
            // =========================

            // Ambil pesan error dari server
            const msg =
                error.data?.message ||
                error.data?.errors?.username?.[0] ||
                'Login gagal. Periksa username dan password Anda.';

            // Tampilkan pesan error
            showAlert(msg);

        } finally {

            // =========================
            // MATIKAN LOADING
            // =========================

            setLoading(false);
        }
    });

    // =========================
    // FOKUS KE INPUT USERNAME
    // =========================

    // Saat halaman dibuka, kursor langsung berada
    // di kolom username agar user bisa langsung mengetik
    usernameInput.focus();
});