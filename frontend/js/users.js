// User Management Page Logic
document.addEventListener('DOMContentLoaded', function () {
    initAppShell();

    // Elements
    const usersTableBody = document.getElementById('usersTableBody');
    const searchInput = document.getElementById('searchInput');
    const roleFilter = document.getElementById('roleFilter');
    const userForm = document.getElementById('userForm');
    const userModal = document.getElementById('userModal');
    const userModalLabel = document.getElementById('userModalLabel');
    const btnAddUser = document.getElementById('btnAddUser');
    const btnSaveUser = document.getElementById('btnSaveUser');
    const btnConfirmDelete = document.getElementById('btnConfirmDelete');
    const deleteModal = document.getElementById('deleteModal');

    let bsUserModal, bsDeleteModal, bsResetModal, bsResetResultModal;
    if (userModal) bsUserModal = new bootstrap.Modal(userModal);
    if (deleteModal) bsDeleteModal = new bootstrap.Modal(deleteModal);

    const resetPasswordModal = document.getElementById('resetPasswordModal');
    const resetResultModal = document.getElementById('resetResultModal');
    const btnConfirmReset = document.getElementById('btnConfirmReset');
    if (resetPasswordModal) bsResetModal = new bootstrap.Modal(resetPasswordModal);
    if (resetResultModal) bsResetResultModal = new bootstrap.Modal(resetResultModal);

    // Load users
    loadUsers();

    // Search with debounce
    let searchTimeout;
    searchInput.addEventListener('input', function () {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(() => loadUsers(), 300);
    });

    // Filter by role
    roleFilter.addEventListener('change', () => loadUsers());

    // Add user button - reset form
    btnAddUser.addEventListener('click', function () {
        resetForm();
        userModalLabel.textContent = 'Tambah Pengguna';
        document.getElementById('inputPassword').setAttribute('required', 'required');
        document.getElementById('passwordHint').style.display = 'none';
    });

    // Save user (create or update)
    userForm.addEventListener('submit', async function (e) {
        e.preventDefault();

        if (!userForm.checkValidity()) {
            userForm.classList.add('was-validated');
            return;
        }

        const userId = document.getElementById('userId').value;
        const userData = {
            name: document.getElementById('inputName').value.trim(),
            email: document.getElementById('inputEmail').value.trim(),
            role: document.getElementById('inputRole').value,
            status: document.getElementById('inputStatus').value,
        };

        const password = document.getElementById('inputPassword').value;
        if (password) {
            userData.password = password;
        }

        setFormLoading(true);

        try {
            if (userId) {
                await api.put(`/users/${userId}`, userData);
                showSuccessToast('Pengguna berhasil diperbarui');
            } else {
                userData.password = password;
                await api.post('/users', userData);
                showSuccessToast('Pengguna berhasil ditambahkan');
            }

            bsUserModal.hide();
            loadUsers();
        } catch (error) {
            const errors = error.data?.errors;
            if (errors) {
                // Show validation errors
                Object.keys(errors).forEach(field => {
                    const input = document.getElementById('input' + field.charAt(0).toUpperCase() + field.slice(1));
                    if (input) {
                        input.classList.add('is-invalid');
                        const feedback = input.nextElementSibling;
                        if (feedback && feedback.classList.contains('invalid-feedback')) {
                            feedback.textContent = errors[field][0];
                        }
                    }
                });
            } else {
                alert(error.data?.message || 'Terjadi kesalahan');
            }
        } finally {
            setFormLoading(false);
        }
    });

    // Delete confirmation
    btnConfirmDelete.addEventListener('click', async function () {
        const userId = document.getElementById('deleteUserId').value;
        try {
            await api.delete(`/users/${userId}`);
            showSuccessToast('Pengguna berhasil dihapus');
            bsDeleteModal.hide();
            loadUsers();
        } catch (error) {
            alert(error.data?.message || 'Gagal menghapus pengguna');
        }
    });

    // Load users from API
    async function loadUsers() {
        const search = searchInput.value.trim();
        const role = roleFilter.value;

        let params = new URLSearchParams();
        if (search) params.append('search', search);
        if (role && role !== 'semua') params.append('role', role);

        const queryString = params.toString() ? `?${params.toString()}` : '';

        try {
            const data = await api.get(`/users${queryString}`);
            renderUsers(data.data.users);
            renderStats(data.data.stats);
        } catch (error) {
            usersTableBody.innerHTML = `
                <tr>
                    <td colspan="6" class="text-center py-5">
                        <div class="empty-state">
                            <i class="bi bi-exclamation-circle"></i>
                            <p>Gagal memuat data. Pastikan server backend berjalan.</p>
                        </div>
                    </td>
                </tr>`;
        }
    }

    // Render users table
    function renderUsers(users) {
        if (!users || users.length === 0) {
            usersTableBody.innerHTML = `
                <tr>
                    <td colspan="6" class="text-center py-5">
                        <div class="empty-state">
                            <i class="bi bi-people"></i>
                            <p>Tidak ada pengguna ditemukan</p>
                        </div>
                    </td>
                </tr>`;
            return;
        }

        usersTableBody.innerHTML = users.map((user, i) => {
            const date = new Date(user.created_at);
            const formattedDate = date.toLocaleDateString('id-ID', { day: '2-digit', month: 'short', year: 'numeric' });

            return `
                <tr>
                    <td>
                        <div class="user-cell">
                            <div class="user-cell-avatar">
                                <i class="bi bi-person-fill"></i>
                            </div>
                            <span class="user-cell-name">${escapeHtml(user.name)}</span>
                        </div>
                    </td>
                    <td>${escapeHtml(user.email)}</td>
                    <td><span class="badge-role badge-${user.role}">${capitalizeFirst(user.role)}</span></td>
                    <td><span class="badge-status badge-${user.status}">${capitalizeFirst(user.status)}</span></td>
                    <td>${formattedDate}</td>
                    <td class="text-center">
                        <button class="btn-action btn-reset-pw" onclick="confirmResetPassword(${user.id}, '${escapeHtml(user.name)}')" title="Reset Password">
                            <i class="bi bi-key-fill"></i>
                        </button>
                        <button class="btn-action btn-edit" onclick="editUser(${user.id})" title="Edit">
                            <i class="bi bi-pencil"></i>
                        </button>
                        <button class="btn-action btn-delete" onclick="confirmDelete(${user.id}, '${escapeHtml(user.name)}')" title="Hapus">
                            <i class="bi bi-trash3-fill"></i>
                        </button>
                    </td>
                </tr>`;
        }).join('');
    }

    // Render statistics
    function renderStats(stats) {
        if (!stats) return;
        document.getElementById('statTotal').textContent = stats.total || 0;
        document.getElementById('statAdmin').textContent = stats.admin || 0;
        document.getElementById('statManager').textContent = stats.manager || 0;
        document.getElementById('statKasir').textContent = stats.kasir || 0;
    }

    // Edit user - load data into form
    window.editUser = async function (userId) {
        try {
            const data = await api.get(`/users/${userId}`);
            const user = data.data;

            document.getElementById('userId').value = user.id;
            document.getElementById('inputName').value = user.name;
            document.getElementById('inputEmail').value = user.email;
            document.getElementById('inputRole').value = user.role;
            document.getElementById('inputStatus').value = user.status;
            document.getElementById('inputPassword').value = '';
            document.getElementById('inputPassword').removeAttribute('required');
            document.getElementById('passwordHint').style.display = 'block';

            userModalLabel.textContent = 'Edit Pengguna';
            bsUserModal.show();
        } catch (error) {
            alert('Gagal memuat data pengguna');
        }
    };

    // Confirm delete
    window.confirmDelete = function (userId, userName) {
        document.getElementById('deleteUserId').value = userId;
        document.getElementById('deleteUserName').textContent = `Apakah Anda yakin ingin menghapus "${userName}"?`;
        bsDeleteModal.show();
    };

    // Confirm reset password
    window.confirmResetPassword = function (userId, userName) {
        document.getElementById('resetUserId').value = userId;
        document.getElementById('resetUserName').textContent = `Apakah Anda yakin ingin mereset password "${userName}"?`;
        bsResetModal.show();
    };

    // Reset password confirmation handler
    if (btnConfirmReset) {
        btnConfirmReset.addEventListener('click', async function () {
            const userId = document.getElementById('resetUserId').value;
            const btnText = btnConfirmReset.querySelector('.btn-text');
            const btnLoader = btnConfirmReset.querySelector('.btn-loader');

            btnConfirmReset.disabled = true;
            btnText.classList.add('d-none');
            btnLoader.classList.remove('d-none');

            try {
                const data = await api.post(`/users/${userId}/reset-password`);
                bsResetModal.hide();

                // Show result modal with new password
                document.getElementById('newPasswordDisplay').textContent = data.data.new_password;
                bsResetResultModal.show();
            } catch (error) {
                alert(error.data?.message || 'Gagal mereset password');
            } finally {
                btnConfirmReset.disabled = false;
                btnText.classList.remove('d-none');
                btnLoader.classList.add('d-none');
            }
        });
    }

    // Copy password to clipboard
    const btnCopyPassword = document.getElementById('btnCopyPassword');
    if (btnCopyPassword) {
        btnCopyPassword.addEventListener('click', function () {
            const pw = document.getElementById('newPasswordDisplay').textContent;
            navigator.clipboard.writeText(pw).then(() => {
                btnCopyPassword.innerHTML = '<i class="bi bi-check-lg"></i>';
                setTimeout(() => {
                    btnCopyPassword.innerHTML = '<i class="bi bi-clipboard"></i>';
                }, 2000);
            });
        });
    }

    // Reset form
    function resetForm() {
        userForm.reset();
        userForm.classList.remove('was-validated');
        document.getElementById('userId').value = '';
        document.querySelectorAll('.is-invalid').forEach(el => el.classList.remove('is-invalid'));
    }

    // Form loading state
    function setFormLoading(loading) {
        const btnText = btnSaveUser.querySelector('.btn-text');
        const btnLoader = btnSaveUser.querySelector('.btn-loader');
        btnSaveUser.disabled = loading;

        if (loading) {
            btnText.classList.add('d-none');
            btnLoader.classList.remove('d-none');
        } else {
            btnText.classList.remove('d-none');
            btnLoader.classList.add('d-none');
        }
    }

    // Show success toast
    function showSuccessToast(message) {
        const toastEl = document.getElementById('successToast');
        const msgEl = document.getElementById('successToastMessage');
        if (msgEl) msgEl.innerHTML = `<i class="bi bi-check-circle me-2"></i>${message}`;
        if (toastEl) {
            const toast = new bootstrap.Toast(toastEl);
            toast.show();
        }
    }
});

// Utility functions
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function capitalizeFirst(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
}
