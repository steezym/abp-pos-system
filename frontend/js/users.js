// =========================
// LOGIKA HALAMAN PENGGUNA (USER MANAGEMENT)
// =========================
document.addEventListener('DOMContentLoaded', function () {
    
    // Inisialisasi tampilan dasar (navbar, sidebar, cek hak akses)
    initAppShell();

    // =========================
    // MENGAMBIL ELEMEN DARI HTML
    // =========================
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

    // =========================
    // INISIALISASI MODAL (POPUP BOOTSTRAP)
    // =========================
    let bsUserModal, bsDeleteModal, bsResetModal;
    if (userModal) bsUserModal = new bootstrap.Modal(userModal);
    if (deleteModal) bsDeleteModal = new bootstrap.Modal(deleteModal);

    const resetPasswordModal = document.getElementById('resetPasswordModal');
    const btnConfirmReset = document.getElementById('btnConfirmReset');
    if (resetPasswordModal) bsResetModal = new bootstrap.Modal(resetPasswordModal);

    // =========================
    // CEK HAK AKSES PENGGUNA SAAT INI
    // =========================
    const currentUser = api.getUser();
    
    // Cek apakah pengguna yang sedang login ini adalah Manager
    const isManager = currentUser && currentUser.role === 'manager';

    // Jika yang login adalah Manager, kunci pilihan role "admin" dan "manager"
    // (Manager hanya boleh membuat/mengedit kasir)
    if (isManager) {
        const adminOption = document.querySelector('#inputRole option[value="admin"]');
        const managerOption = document.querySelector('#inputRole option[value="manager"]');
        if (adminOption) adminOption.disabled = true;
        if (managerOption) managerOption.disabled = true;
    }

    // =========================
    // TAMPILKAN DATA PENGGUNA PERTAMA KALI
    // =========================
    loadUsers();

    // =========================
    // FITUR PENCARIAN (SEARCH)
    // =========================
    let searchTimeout;
    searchInput.addEventListener('input', function () {
        // Hapus timer sebelumnya jika pengguna mengetik cepat
        clearTimeout(searchTimeout);
        // Tunggu 300 milidetik setelah berhenti mengetik baru lakukan pencarian
        searchTimeout = setTimeout(() => loadUsers(), 300);
    });

    // =========================
    // FITUR FILTER ROLE (DROPDOWN)
    // =========================
    roleFilter.addEventListener('change', () => loadUsers());

    // =========================
    // TOMBOL TAMBAH PENGGUNA BARU
    // =========================
    btnAddUser.addEventListener('click', function () {
        // Kosongkan form dari data lama
        resetForm();
        
        // Ubah judul modal
        userModalLabel.textContent = 'Tambah Pengguna';
        
        // Munculkan kolom password (wajib diisi saat buat baru)
        document.getElementById('passwordGroup').style.display = 'block';
        document.getElementById('inputPassword').setAttribute('required', 'required');
        
        // Sembunyikan pilihan status (karena pengguna baru otomatis aktif)
        document.getElementById('statusGroup').style.display = 'none';
        
        // Perlebar tampilan dropdown Role
        const roleGroup = document.getElementById('roleGroup');
        if (roleGroup) {
            roleGroup.classList.remove('col-md-6');
            roleGroup.classList.add('col-md-12');
        }
        
        // Set status default menjadi 'aktif'
        document.getElementById('inputStatus').value = 'aktif';

        // Pastikan dropdown Role bisa dipilih kembali (tidak terkunci)
        const roleSelect = document.getElementById('inputRole');
        if (roleSelect) {
            roleSelect.disabled = false;
            roleSelect.title = '';
        }
    });

    // =========================
    // PROSES SIMPAN PENGGUNA (TAMBAH / EDIT)
    // =========================
    userForm.addEventListener('submit', async function (e) {
        // Jangan refresh halaman saat tombol simpan ditekan
        e.preventDefault(); 

        // Cek apakah ada inputan yang kosong atau tidak valid
        if (!userForm.checkValidity()) {
            userForm.classList.add('was-validated');
            return;
        }

        // Ambil ID pengguna (jika kosong berarti ini Tambah Baru, jika ada isinya berarti Edit)
        const userId = document.getElementById('userId').value;
        
        // Kumpulkan data yang diketik
        const userData = {
            name: document.getElementById('inputName').value.trim(),
            username: document.getElementById('inputUsername').value.trim(),
            role: document.getElementById('inputRole').value,
            status: document.getElementById('inputStatus').value,
        };

        // Jika Tambah Baru, ambil data password
        if (!userId) {
            userData.password = document.getElementById('inputPassword').value;
        }

        // Aktifkan mode loading pada tombol
        setFormLoading(true);

        try {
            if (userId) {
                // Proses Edit Data ke server (PUT)
                await api.put(`/users/${userId}`, userData);
                showSuccessToast('Pengguna berhasil diperbarui');
            } else {
                // Proses Tambah Data ke server (POST)
                await api.post('/users', userData);
                showSuccessToast('Pengguna berhasil ditambahkan');
            }

            // Tutup popup modal
            bsUserModal.hide();
            
            // Perbarui/refresh data tabel
            loadUsers();
        } catch (error) {
            // Tampilkan error jika misalnya username sudah terpakai
            const errors = error.data?.errors;
            if (errors) {
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
            // Matikan mode loading pada tombol
            setFormLoading(false);
        }
    });

    // =========================
    // PROSES KONFIRMASI HAPUS PENGGUNA
    // =========================
    btnConfirmDelete.addEventListener('click', async function () {
        // Ambil ID pengguna yang mau dihapus dari kolom tersembunyi
        const userId = document.getElementById('deleteUserId').value; 

        try {
            // Kirim perintah hapus ke server
            await api.delete(`/users/${userId}`);
            
            // Tampilkan pesan sukses
            showSuccessToast('Pengguna berhasil dihapus');
            
            // Tutup modal hapus
            bsDeleteModal.hide();
            
            // Perbarui/refresh tabel
            loadUsers();
        } catch (error) {
            // Tampilkan error jika gagal menghapus
            alert(error.data?.message || 'Gagal menghapus pengguna');
        }
    });

    // =========================
    // FUNGSI MEMUAT DATA PENGGUNA DARI SERVER
    // =========================
    async function loadUsers() {
        // Ambil kata kunci pencarian dan filter role
        const search = searchInput.value.trim();
        const role = roleFilter.value;

        // Susun parameter URL
        let params = new URLSearchParams();
        if (search) params.append('search', search);
        if (role && role !== 'semua') params.append('role', role);

        const queryString = params.toString() ? `?${params.toString()}` : '';

        try {
            // Minta data ke backend API
            const data = await api.get(`/users${queryString}`);
            
            // Gambar ulang tabel HTML berdasarkan data
            renderUsers(data.data.users);
            
            // Perbarui kotak-kotak statistik di atas tabel
            renderStats(data.data.stats);
        } catch (error) {
            // Tampilkan pesan error jika server mati
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

    // =========================
    // FUNGSI MENGGAMBAR TABEL HTML
    // =========================
    function renderUsers(users) {
        // Jika data kosong
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

        // Looping (ulangi) setiap data user menjadi bentuk baris tabel <tr>
        usersTableBody.innerHTML = users.map((user, i) => {
            // Format tanggal bergabung menjadi format rapi
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
                    <td>${escapeHtml(user.username)}</td>
                    <td><span class="badge-role badge-${user.role}">${capitalizeFirst(user.role)}</span></td>
                    <td><span class="badge-status badge-${user.status}">${capitalizeFirst(user.status)}</span></td>
                    <td>${formattedDate}</td>
                    <td class="text-center">
                        ${!isManager ? `
                        <button class="btn-action btn-reset-pw" onclick="confirmResetPassword(${user.id}, '${escapeHtml(user.name)}')" title="Reset Password">
                            <i class="bi bi-key"></i>
                        </button>
                        ` : ''}
                        
                        ${!(isManager && (user.role === 'admin' || user.role === 'manager')) ? `
                        <button class="btn-action btn-edit" onclick="editUser(${user.id})" title="Edit">
                            <i class="bi bi-pencil"></i>
                        </button>
                        ` : ''}
                        
                        ${!isManager ? (
                            user.id === currentUser.id
                            ? `<button class="btn-action btn-delete-disabled" disabled title="Tidak dapat menghapus akun sendiri">
                                <i class="bi bi-trash3-fill"></i>
                               </button>`
                            : `<button class="btn-action btn-delete" onclick="confirmDelete(${user.id}, '${escapeHtml(user.name)}')" title="Hapus">
                                <i class="bi bi-trash3-fill"></i>
                               </button>`
                        ) : ''}
                    </td>
                </tr>`;
        }).join('');
    }

    // =========================
    // FUNGSI MEMPERBARUI KARTU STATISTIK
    // =========================
    function renderStats(stats) {
        if (!stats) return;
        document.getElementById('statTotal').textContent = stats.total || 0;
        document.getElementById('statAdmin').textContent = stats.admin || 0;
        document.getElementById('statManager').textContent = stats.manager || 0;
        document.getElementById('statKasir').textContent = stats.kasir || 0;
    }

    // =========================
    // FUNGSI KLIK TOMBOL EDIT PENGGUNA
    // =========================
    window.editUser = async function (userId) {
        try {
            // Ambil data detail 1 orang pengguna dari server
            const data = await api.get(`/users/${userId}`);
            const user = data.data;

            // Masukkan data tersebut ke dalam kolom-kolom form
            document.getElementById('userId').value = user.id;
            document.getElementById('inputName').value = user.name;
            document.getElementById('inputUsername').value = user.username;
            document.getElementById('inputRole').value = user.role;
            document.getElementById('inputStatus').value = user.status;
            
            // Sembunyikan kolom password saat mengedit (karena tidak diubah di sini)
            document.getElementById('passwordGroup').style.display = 'none';
            document.getElementById('inputPassword').removeAttribute('required');

            // Munculkan kolom pilihan Status (aktif/nonaktif)
            document.getElementById('statusGroup').style.display = 'block';
            const roleGroup = document.getElementById('roleGroup');
            if (roleGroup) {
                roleGroup.classList.remove('col-md-12');
                roleGroup.classList.add('col-md-6');
            }

            // Kunci pilihan "Nonaktif" dan Dropdown Role jika sedang mengedit akun milik sendiri
            const statusSelect = document.getElementById('inputStatus');
            const roleSelect = document.getElementById('inputRole');
            const nonaktifOption = statusSelect.querySelector('option[value="nonaktif"]');
            
            if (user.id === currentUser.id) {
                // Kunci agar tidak bisa disabotase diri sendiri
                if (nonaktifOption) nonaktifOption.disabled = true;
                roleSelect.disabled = true;
                roleSelect.title = 'Anda tidak dapat mengubah role akun sendiri';
            } else {
                // Buka kuncian jika mengedit orang lain
                if (nonaktifOption) nonaktifOption.disabled = false;
                roleSelect.disabled = false;
                roleSelect.title = '';
            }

            // Ubah judul modal dan tampilkan modal
            userModalLabel.textContent = 'Edit Pengguna';
            bsUserModal.show();
        } catch (error) {
            alert('Gagal memuat data pengguna');
        }
    };

    // =========================
    // FUNGSI MUNCULKAN POPUP KONFIRMASI HAPUS
    // =========================
    window.confirmDelete = function (userId, userName) {
        document.getElementById('deleteUserId').value = userId;
        document.getElementById('deleteUserName').textContent = `Apakah Anda yakin ingin menghapus "${userName}"?`;
        bsDeleteModal.show();
    };

    // =========================
    // FUNGSI MUNCULKAN POPUP RESET PASSWORD
    // =========================
    window.confirmResetPassword = function (userId, userName) {
        document.getElementById('resetUserId').value = userId;
        document.getElementById('resetUserName').textContent = `Masukkan password baru untuk ${userName}:`;
        document.getElementById('resetNewPassword').value = '';
        document.getElementById('resetNewPassword').classList.remove('is-invalid');
        bsResetModal.show();
    };

    // =========================
    // PROSES RESET PASSWORD BARU
    // =========================
    if (btnConfirmReset) {
        btnConfirmReset.addEventListener('click', async function () {
            const userId = document.getElementById('resetUserId').value;
            const newPasswordInput = document.getElementById('resetNewPassword');
            const newPassword = newPasswordInput.value;

            // Validasi password minimal 6 karakter
            if (newPassword.length < 6) {
                newPasswordInput.classList.add('is-invalid');
                return;
            }

            const btnText = btnConfirmReset.querySelector('.btn-text');
            const btnLoader = btnConfirmReset.querySelector('.btn-loader');

            // Aktifkan mode loading
            btnConfirmReset.disabled = true;
            btnText.classList.add('d-none');
            btnLoader.classList.remove('d-none');

            try {
                // Kirim password baru ke server
                await api.post(`/users/${userId}/reset-password`, { password: newPassword });
                
                // Tutup popup
                bsResetModal.hide();
                showSuccessToast('Password berhasil diubah!');
            } catch (error) {
                alert(error.data?.message || 'Gagal mereset password');
            } finally {
                // Matikan mode loading
                btnConfirmReset.disabled = false;
                btnText.classList.remove('d-none');
                btnLoader.classList.add('d-none');
            }
        });
    }

    // =========================
    // FUNGSI BERSIHKAN FORM
    // =========================
    function resetForm() {
        // Kosongkan seluruh inputan text
        userForm.reset();
        
        // Hapus tanda merah/hijau sisa validasi sebelumnya
        userForm.classList.remove('was-validated');
        document.getElementById('userId').value = '';
        document.querySelectorAll('.is-invalid').forEach(el => el.classList.remove('is-invalid'));
    }

    // =========================
    // FUNGSI LOADING PADA TOMBOL FORM
    // =========================
    function setFormLoading(loading) {
        const btnText = btnSaveUser.querySelector('.btn-text');
        const btnLoader = btnSaveUser.querySelector('.btn-loader');
        
        // Kunci tombol agar tidak diklik dua kali
        btnSaveUser.disabled = loading;

        if (loading) {
            btnText.classList.add('d-none');
            btnLoader.classList.remove('d-none');
        } else {
            btnText.classList.remove('d-none');
            btnLoader.classList.add('d-none');
        }
    }

    // =========================
    // FUNGSI TAMPILKAN NOTIFIKASI SUKSES (TOAST)
    // =========================
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

// =========================
// FUNGSI BANTUAN (UTILITIES)
// =========================

// Mengamankan teks dari kode jahat (XSS)
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Mengubah huruf pertama jadi huruf besar
function capitalizeFirst(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
}
