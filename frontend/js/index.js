document.addEventListener('DOMContentLoaded', async function () {
    initAppShell();

    function getDefaultDateRange() {
        const end = new Date();

        const start = new Date();
        start.setDate(end.getDate() - (12 * 7)); // 20 weeks ago

        const format = (date) => date.toISOString().split('T')[0];

        return {
            start: format(start),
            end: format(end)
        };
    }

    // load data produk
    try {
        console.log('load data product')
        const res = await api.get('/products');
        updateStats(res.list);
    } catch (err) {
        console.error('Gagal load data:', err);
    }

    function updateStats(products) {
        const total = products.length;
        const lowStock = products.filter(p => p.stock <= p.min_stock && p.stock > 0).length;

        document.getElementById('statTotalProduct').innerText = total;
        document.getElementById('statLowStock').innerText = lowStock;
    }

    //load data transaksi
    const transactionsTableBody = document.getElementById('transactionsTableBody');
    const btnHarian = document.getElementById('harian');
    const btnMingguan = document.getElementById('mingguan');
    const startDateInput = document.getElementById('startDate');
    const endDateInput = document.getElementById('endDate');

    const { start, end } = getDefaultDateRange();

    if (startDateInput && endDateInput) {
        startDateInput.value = start;
        endDateInput.value = end;
    }

    let currentMode = 'daily';
    btnHarian.classList.add('active');
    loadTransactions()
    loadTrendChart('weekly');
    loadTodayRevenue();

    async function loadTransactions() {
        try {
            const data = await api.get('/transaction');
            renderTransactions(data.data.transactions);
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

    btnHarian.addEventListener('click', () => {

        currentMode = 'daily';

        btnHarian.classList.add('active');
        btnMingguan.classList.remove('active');

        loadTrendChart('daily');
    });

    btnMingguan.addEventListener('click', () => {

        currentMode = 'weekly';

        btnMingguan.classList.add('active');
        btnHarian.classList.remove('active');

        loadTrendChart('weekly');
    });

    async function loadTrendChart(mode = 'daily') {

        try {

            const startDate = startDateInput?.value;
            const endDate = endDateInput?.value;

            let params = new URLSearchParams();

            if(startDate && endDate){
                params.append('start', startDate);
                params.append('end', endDate);
            }

            const queryString =
                params.toString()
                    ? `?${params.toString()}`
                    : '';

            const endpoint =
                mode === 'weekly'
                    ? `/transaction/weeklysum${queryString}`
                    : `/transaction/dailysum${queryString}`;

            const response = await api.get(endpoint);

            const chartData = response.data;

            console.log(chartData);

            const xArray = chartData.map(item => item.period);
            const valueArray = chartData.map(item => item.value);
            const volumeArray = chartData.map(item => item.volume);

            const omzetTrace = {
                x: xArray,
                y: valueArray,
                name: 'Omset',
                type: 'scatter',
                mode: 'lines+markers',
                 line: {
                    shape: 'spline',
                     smoothing: 1.3
                }
            };

            const volumeTrace = {
                x: xArray,
                y: volumeArray,
                 name: 'Volume',
                 type: 'bar',
                 yaxis: 'y2'
                };

             const layout = {
                  title:
                     mode === 'weekly'
                         ? 'Trend Penjualan Mingguan'
                          : 'Trend Penjualan Harian',

                  xaxis: {
                      title:
                          mode === 'weekly'
                             ? 'Minggu'
                             : 'Tanggal'
                 },

                  yaxis: {
                       title: 'Omset (Rp)'
                },

                yaxis2: {
                    title: 'Jumlah Transaksi',
                    overlaying: 'y',
                    side: 'right'
                },

                legend: {
                    orientation: 'h'
                },

                margin: {
                    t: 50
                }
             };

            Plotly.newPlot(
                'myPlot',
                [omzetTrace],
                layout,
                { responsive: true }
            );

        } catch(error) {

            console.error(error);

            document.getElementById('myPlot').innerHTML =
            '<p class="text-center">Gagal memuat grafik.</p>';
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

    function getTodayRevenue(transactions) {
    const today = new Date().toISOString().split('T')[0];

    return transactions
        .filter(transaction => transaction.date === today)
        .reduce((sum, transaction) => sum + Number(transaction.total), 0);
    }

    async function loadTodayRevenue() {
        try {
            const today = new Date().toISOString().split('T')[0];
            const url = `/transaction/dailysum?start=${today}&end=${today}`

            const response = await api.get(url);
            
            const chartData = response.data;

            const todayData = chartData.find(item => item.period === today);
            const todayRevenue = todayData ? todayData.value : 0;
            const todayTransaction = todayData ? todayData.volume :0;

            document.getElementById('statTodayRevenue').innerText = formatRupiah(todayRevenue);
            document.getElementById('statTodayTransaction').innerText = todayTransaction;

        } catch (error) {
            console.error('Gagal memuat pendapatan hari ini:', error);
            document.getElementById('statTodayRevenue').innerText = formatRupiah(0);
        }
    }

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
