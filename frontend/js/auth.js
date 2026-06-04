// Auth Guard - checks authentication on protected pages
(function () {
    const currentPage = window.location.pathname.split('/').pop() || 'index.html';
    const publicPages = ['login.html'];
    const isPublicPage = publicPages.includes(currentPage);
    const token = api.getToken();

    if (!isPublicPage && !token) {
        window.location.href = 'login.html';
        return;
    }

    if (isPublicPage && token) {
        window.location.href = 'index.html';
        return;
    }

    const user = api.getUser();
    if (currentPage === 'users.html' && user && user.role === 'kasir') {
        window.location.href = 'index.html';
        return;
    }
})();

// Shared functions for authenticated pages
function initAppShell() {
    const user = api.getUser();
    if (!user) return;

    // Set user info in navbar
    const userNameEl = document.getElementById('userName');
    const userRoleEl = document.getElementById('userRole');

    if (userNameEl) userNameEl.textContent = user.name;
    if (userRoleEl) userRoleEl.textContent = user.role.charAt(0).toUpperCase() + user.role.slice(1);

    // Hide users menu if Kasir
    if (user.role === 'kasir') {
        const usersNav = document.querySelector('li[data-page="users"]');
        if (usersNav) usersNav.style.display = 'none';
    }

    // Sidebar toggle (mobile)
    const sidebarOpen = document.getElementById('sidebarOpen');
    const sidebarClose = document.getElementById('sidebarClose');
    const sidebar = document.getElementById('sidebar');
    const overlay = document.getElementById('sidebarOverlay');

    if (sidebarOpen) {
        sidebarOpen.addEventListener('click', () => {
            sidebar.classList.add('show');
            overlay.classList.add('show');
        });
    }

    if (sidebarClose) {
        sidebarClose.addEventListener('click', () => {
            sidebar.classList.remove('show');
            overlay.classList.remove('show');
        });
    }

    if (overlay) {
        overlay.addEventListener('click', () => {
            sidebar.classList.remove('show');
            overlay.classList.remove('show');
        });
    }

    // Logout handlers
    const btnLogout = document.getElementById('btnLogout');
    const btnLogoutMenu = document.getElementById('btnLogoutMenu');

    async function handleLogout(e) {
        e.preventDefault();
        try {
            await api.post('/logout');
        } catch (err) {
            // Even if logout fails on server, clear local
        }
        api.clearAuth();
        window.location.href = 'login.html';
    }

    if (btnLogout) btnLogout.addEventListener('click', handleLogout);
    if (btnLogoutMenu) btnLogoutMenu.addEventListener('click', handleLogout);
}

// Coming Soon toast
function showComingSoon(e) {
    if (e) e.preventDefault();
    const toastEl = document.getElementById('comingSoonToast');
    if (toastEl) {
        const toast = new bootstrap.Toast(toastEl);
        toast.show();
    }
}
