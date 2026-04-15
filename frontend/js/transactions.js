// User Management Page Logic
document.addEventListener('DOMContentLoaded', function () {
    initAppShell();

    // Elements
    const transactionsTableBody = document.getElementById('transactionsTableBody');
    const searchInput = document.getElementById('searchInput');
    const startDateInput = document.getElementById('startDate');
    const btnCancelFilterDate = document.getElementById('btnCancelDateFilter');
    const endDateInput = document.getElementById('endDate');
    const transactionModal = document.getElementById('transactionModal');

    let bsTransactionModal;
    if (transactionModal) bsTransactionModal = new bootstrap.Modal(transactionModal);

    // Load transaction
    loadTransactions();

    let apiTimeout;
    searchInput.addEventListener('input', function () {
        clearTimeout(apiTimeout);
        renderLoading();
        apiTimeout = setTimeout(() => loadTransactions(), 300);
    });

    endDateInput.addEventListener('change', function() {
        clearTimeout(apiTimeout);
        renderLoading();
        apiTimeout = setTimeout(() => loadTransactions(), 300);
        btnCancelFilterDate.classList.toggle('d-none');
        startDateInput.disabled = true;
        endDateInput.disabled = true;
    })

    btnCancelFilterDate.addEventListener('click', function() {
        startDateInput.value = "";
        endDateInput.value = "";
        btnCancelFilterDate.classList.toggle('d-none');
        renderLoading();
        loadTransactions();
        startDateInput.disabled = false;
        endDateInput.disabled = false;
    })

    // Load transaction from API
    async function loadTransactions() {
        const search = searchInput.value.trim();
        const startDate = startDateInput.value;
        const endDate = endDateInput.value;

        let params = new URLSearchParams();
        if (search) params.append('search', search);
        if(startDate && endDate) {
            params.append('start',startDate);
            params.append('end',endDate);
        }

        const queryString = params.toString() ? `?${params.toString()}` : '';

        try {
            const data = await api.get(`/transaction${queryString}`);
            renderTransactions(data.data.transactions);
            renderStats(data.data.stats)
        } catch (error) {
            transactionsTableBody.innerHTML = `
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

    // Render transaction table
    function renderTransactions(transactions) {
        if (!transactions || transactions.length === 0) {
            transactionsTableBody.innerHTML = `
                <tr>
                    <td colspan="6" class="text-center py-5">
                        <div class="empty-state">
                            <i class="bi bi-receipt"></i>
                            <p>Tidak ada transaksi ditemukan</p>
                        </div>
                    </td>
                </tr>`;
            return;
        }

        transactionsTableBody.innerHTML = transactions.map((transaction, i) => {
            return `
                <tr>
                    <td>${escapeHtml(transaction.id)}</td>
                    <td>${escapeHtml(formatDate(transaction.date))} ${escapeHtml(transaction.time)}</td>
                    <td>${escapeHtml(transaction.quantity)}</td>
                    <td>${escapeHtml(formatRupiah(transaction.total))}</td>
                    <td>${escapeHtml(transaction.payment_method)}</td>
                    <td class="text-center">
                        <button class="btn-action btn-edit" onclick="showTransaction(${transaction.id})">
                            <i class="bi bi-eye"></i>
                        </button>
                    </td>
                </tr>`;
        }).join('');
    }

    // Render statistics
    function renderStats(stats) {
        if (!stats) return;
        document.getElementById('statTotalTransaction').textContent = stats.total || 0;
        document.getElementById('statTotalRevenue').textContent = formatRupiah(Number(stats.revenue)) || 0;
        document.getElementById('statHighestTransaction').textContent = formatRupiah(stats.max) || 0;
        document.getElementById('statLowestTransaction').textContent = formatRupiah(stats.min) || 0;
    }

    function renderLoading() {
        transactionsTableBody.innerHTML = "";
        transactionsTableBody.innerHTML = 
        `
            <td colspan="6" class="text-center py-5">
                <div class="spinner-border spinner-border-sm text-secondary" role="status">
                    <span class="visually-hidden">Loading...</span>
                </div>
                <p class="mt-2 text-muted small">Memuat data transaksi...</p>
            </td>
        `;
    }

    window.showTransaction = async function (transactionId) {
        try {
            const transaction = await api.get(`/transaction/${transactionId}`);
            const [transaction_data] = transaction.data;
           
            document.getElementById('transaction_id').innerText = transaction_data.id;
            document.getElementById('transaction_date').innerText = formatDate(transaction_data.date);
            document.getElementById('transaction_time').innerText = transaction_data.time;
            document.getElementById('transaction_products').innerHTML = "";
            for (let i = 0; i < transaction_data.products.length; i++) {
                document.getElementById('transaction_products').innerHTML += 
                    `<li class="d-flex justify-content-between">
                        <span class="key">${transaction_data.products[i].name} <span class="total">x${transaction_data.products[i].details.quantity}</span></span>
                        <span class="value">${formatRupiah(transaction_data.products[i].details.price)}</span>
                    </li>`
            };
            document.getElementById('transaction_total').innerText = formatRupiah(transaction_data.total);

            bsTransactionModal.show();
        } catch (error) {
            alert("Gagal memuat data transaksi");
        }
    };

});

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function formatRupiah(value) {
    return value.toLocaleString('id-ID', { style: 'currency', currency: 'IDR' })
}

function formatDate(date) {
    const dateFormat = date.split("-");
    const dateFinalFormat = `${dateFormat[2]}-${dateFormat[1]}-${dateFormat[0]}`;
    return dateFinalFormat;
}