document.addEventListener('DOMContentLoaded', async function () {
    initAppShell();

    const tableBody = document.getElementById('productsTableBody');
    const form = document.getElementById('productForm');
    const res = await api.get('/products');
    renderProducts(res);
    updateStats(res);
    let allProducts = [];
    loadProducts();

    // PREVIEW IMAGE
    document.getElementById('inputImage').addEventListener('change', function () {
        const file = this.files[0];
        const preview = document.getElementById('previewImage');

        if (file) {
            preview.src = URL.createObjectURL(file);
            preview.style.display = 'block';
        }
    });

    async function loadProducts() {
        try {
            const res = await api.get('/products');
            allProducts = res;
            applyFilter();
        } catch (err) {
            tableBody.innerHTML = `<tr><td colspan="7">Gagal load data</td></tr>`;
        }
    }

    function getStatus(stock, min) {
        if (stock == 0) return `<span class="text-danger">Out of Stock</span>`;
        if (stock <= min) return `<span class="text-warning">Low Stock</span>`;
        return `<span class="text-success">In Stock</span>`;
    }

    function updateStats(products) {
        const total = products.length;
        const totalStock = products.reduce((sum, p) => sum + p.stock, 0);
        const lowStock = products.filter(p => p.stock <= p.min_stock && p.stock > 0).length;
        const outStock = products.filter(p => p.stock == 0).length;

        document.getElementById('statTotalProduct').innerText = total;
        document.getElementById('statTotalStock').innerText = totalStock;
        document.getElementById('statLowStock').innerText = lowStock;
        document.getElementById('statOutStock').innerText = outStock;
    }

    function renderProducts(products) {
        tableBody.innerHTML = products.map(p => `
        <tr>
            <td class="text-center">
                <img src="http://127.0.0.1:8000/storage/${p.image}" 
                style="width:40px;height:40px;object-fit:cover;border-radius:6px;">
            </td>
            <td class="text-center">${p.name}</td>
            <td class="text-center">${p.category}</td>
            <td class="text-center">
            <div>${p.stock}</div>
                <small class="text-muted">min: ${p.min_stock}</small>
            </td>
            <td class="text-center">Rp ${formatRupiah(p.price)}</td>
            <td class="text-center">
                ${getStatus(p.stock, p.min_stock)}
            </td>
            <td class="text-center">
                <button class="btn-action btn-edit" onclick="editProduct(${p.id})">
                    <i class="bi bi-pencil"></i>
                </button>
                <button class="btn-action btn-delete" onclick="openDeleteModal(${p.id}, '${p.name}')">
                    <i class="bi bi-trash"></i>
                </button>
            </td>
        </tr>
        `).join('');
    }

    function applyFilter() {
        const keyword = document.getElementById('searchInput').value.toLowerCase();
        const status = document.getElementById('filterStatus').value;

        let filtered = allProducts;

        // SEARCH
        if (keyword) {
            filtered = filtered.filter(p =>
                p.name.toLowerCase().includes(keyword)
            );
        }

        // FILTER STATUS
        if (status) {
            filtered = filtered.filter(p => {
                if (status === "Out") return p.stock == 0;
                if (status === "Low") return p.stock <= p.min_stock && p.stock > 0;
                if (status === "In") return p.stock > p.min_stock;
            });
        }

        renderProducts(filtered);
        updateStats(filtered);
    }

    function formatRupiah(number) {
        return new Intl.NumberFormat('id-ID').format(number);
    }

    form.addEventListener('submit', async function (e) {
        e.preventDefault();

        const id = document.getElementById('productId').value;

        const formData = new FormData();

        formData.append('name', document.getElementById('inputName').value);
        formData.append('category', document.getElementById('inputCategory').value);
        formData.append('stock', document.getElementById('inputStock').value);
        formData.append('min_stock', document.getElementById('inputMinStock').value);
        formData.append('price', document.getElementById('inputPrice').value);

        const image = document.getElementById('inputImage').files[0];
        if (image) formData.append('image', image);

        if (id) {
            formData.append('_method', 'PUT');

            await fetch(`${CONFIG.API_BASE_URL}/products/${id}`, {
                method: "POST",
                headers: {
                    Authorization: `Bearer ${api.getToken()}`
                },
                body: formData
            });
        } else {
            await fetch(`${CONFIG.API_BASE_URL}/products`, {
                method: "POST",
                headers: {
                    Authorization: `Bearer ${api.getToken()}`
                },
                body: formData
            });
        }

        location.reload();
    });

    window.editProduct = async function (id) {
        const p = await api.get(`/products/${id}`);

        document.getElementById('productId').value = p.id;
        document.getElementById('inputName').value = p.name;
        document.getElementById('inputCategory').value = p.category;
        document.getElementById('inputStock').value = p.stock;
        document.getElementById('inputMinStock').value = p.min_stock;
        document.getElementById('inputPrice').value = p.price;

        if (p.image) {
            const preview = document.getElementById('previewImage');
            preview.src = `http://127.0.0.1:8000/storage/${p.image}`;
            preview.style.display = 'block';
        }

        new bootstrap.Modal(document.getElementById('productModal')).show();
    };

    window.openDeleteModal = function (id, name) {
        document.getElementById("deleteProductId").value = id;
        document.getElementById("deleteProductName").innerText =
            `Apakah Anda yakin ingin menghapus "${name}"?`;

        const modal = new bootstrap.Modal(document.getElementById('deleteModal'));
        modal.show();
    }

    document.getElementById('searchInput').addEventListener('input', applyFilter);
    document.getElementById('filterStatus').addEventListener('change', applyFilter);

    document.getElementById("btnConfirmDelete").addEventListener("click", async () => {
        const id = document.getElementById("deleteProductId").value;

        try {
            await api.delete(`/products/${id}`);

            bootstrap.Modal.getInstance(document.getElementById('deleteModal')).hide();

            loadProducts();

        } catch (error) {
        console.error("Gagal hapus:", error);
        }
    });
});