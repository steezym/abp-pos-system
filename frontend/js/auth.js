// =========================
// CEK LOGIN DAN HAK AKSES
// =========================
(function () {

    // Ambil nama halaman saat ini
    // Contoh: users.html, login.html, index.html
    const currentPage = window.location.pathname.split('/').pop() || 'index.html';

    // Daftar halaman yang boleh dibuka tanpa login
    const publicPages = ['login.html'];

    // Cek apakah halaman saat ini termasuk halaman publik
    const isPublicPage = publicPages.includes(currentPage);

    // Ambil token login yang tersimpan
    const token = api.getToken();

    // Jika halaman membutuhkan login tetapi token tidak ada
    // arahkan ke halaman login
    if (!isPublicPage && !token) {
        window.location.href = 'login.html';
        return;
    }

    // Jika sudah login lalu membuka halaman login
    // arahkan ke dashboard
    if (isPublicPage && token) {
        window.location.href = 'index.html';
        return;
    }

    // Ambil data user yang sedang login
    const user = api.getUser();

    // Jika kasir mencoba membuka halaman users.html
    // maka kembalikan ke dashboard
    if (currentPage === 'users.html' && user && user.role === 'kasir') {
        window.location.href = 'index.html';
        return;
    }

})();


// =========================
// FUNGSI UMUM SETELAH LOGIN
// =========================
function initAppShell() {

    // Ambil data user yang sedang login
    const user = api.getUser();

    // Jika data user tidak ada, hentikan fungsi
    if (!user) return;

    // =========================
    // TAMPILKAN DATA USER
    // =========================

    // Ambil elemen nama dan role di navbar
    const userNameEl = document.getElementById('userName');
    const userRoleEl = document.getElementById('userRole');

    // Tampilkan nama user
    if (userNameEl) userNameEl.textContent = user.name;

    // Tampilkan role user
    // Contoh: kasir -> Kasir
    if (userRoleEl) {
        userRoleEl.textContent =
            user.role.charAt(0).toUpperCase() +
            user.role.slice(1);
    }

    // =========================
    // SEMBUNYIKAN MENU USERS
    // UNTUK ROLE KASIR
    // =========================
    if (user.role === 'kasir') {

        // Cari menu users
        const usersNav = document.querySelector('li[data-page="users"]');

        // Sembunyikan menu jika ditemukan
        if (usersNav) usersNav.style.display = 'none';
    }

    // =========================
    // SIDEBAR MOBILE
    // =========================

    // Tombol buka sidebar
    const sidebarOpen = document.getElementById('sidebarOpen');

    // Tombol tutup sidebar
    const sidebarClose = document.getElementById('sidebarClose');

    // Sidebar utama
    const sidebar = document.getElementById('sidebar');

    // Background gelap saat sidebar terbuka
    const overlay = document.getElementById('sidebarOverlay');

    // Saat tombol buka diklik
    if (sidebarOpen) {
        sidebarOpen.addEventListener('click', () => {

            // Tampilkan sidebar
            sidebar.classList.add('show');

            // Tampilkan overlay
            overlay.classList.add('show');
        });
    }

    // Saat tombol tutup diklik
    if (sidebarClose) {
        sidebarClose.addEventListener('click', () => {

            // Sembunyikan sidebar
            sidebar.classList.remove('show');

            // Sembunyikan overlay
            overlay.classList.remove('show');
        });
    }

    // Saat area overlay diklik
    if (overlay) {
        overlay.addEventListener('click', () => {

            // Tutup sidebar
            sidebar.classList.remove('show');

            // Hilangkan overlay
            overlay.classList.remove('show');
        });
    }

    // =========================
    // LOGOUT
    // =========================

    // Tombol logout di navbar
    const btnLogout = document.getElementById('btnLogout');

    // Tombol logout di menu mobile
    const btnLogoutMenu = document.getElementById('btnLogoutMenu');

    // Fungsi logout
    async function handleLogout(e) {

        // Cegah reload halaman
        e.preventDefault();

        try {

            // Kirim request logout ke server
            await api.post('/logout');

        } catch (err) {

            // Jika logout server gagal
            // tetap lanjut logout lokal
        }

        // Hapus token dan data user
        api.clearAuth();

        // Kembali ke halaman login
        window.location.href = 'login.html';
    }

    // Jalankan logout saat tombol logout diklik
    if (btnLogout) {
        btnLogout.addEventListener('click', handleLogout);
    }

    // Jalankan logout saat tombol logout menu diklik
    if (btnLogoutMenu) {
        btnLogoutMenu.addEventListener('click', handleLogout);
    }
}


// =========================
// TOAST COMING SOON
// =========================
function showComingSoon(e) {

    // Cegah aksi default link
    if (e) e.preventDefault();

    // Ambil elemen toast
    const toastEl = document.getElementById('comingSoonToast');

    // Jika toast ditemukan
    if (toastEl) {

        // Buat objek toast bootstrap
        const toast = new bootstrap.Toast(toastEl);

        // Tampilkan toast
        toast.show();
    }
}