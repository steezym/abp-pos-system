// SwiftPOS Configuration
const CONFIG = {
    API_BASE_URL: 'http://127.0.0.1:8000/api',
    TOKEN_KEY: 'pos_token',
    USER_KEY: 'pos_user',
};

// API Helper
const api = {
    getToken() {
        return localStorage.getItem(CONFIG.TOKEN_KEY);
    },

    setToken(token) {
        localStorage.setItem(CONFIG.TOKEN_KEY, token);
    },

    setUser(user) {
        localStorage.setItem(CONFIG.USER_KEY, JSON.stringify(user));
    },

    getUser() {
        const user = localStorage.getItem(CONFIG.USER_KEY);
        return user ? JSON.parse(user) : null;
    },

    clearAuth() {
        localStorage.removeItem(CONFIG.TOKEN_KEY);
        localStorage.removeItem(CONFIG.USER_KEY);
    },

    async request(endpoint, options = {}) {
        const url = `${CONFIG.API_BASE_URL}${endpoint}`;
        const token = this.getToken();

        const defaultHeaders = {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
        };

        if (token) {
            defaultHeaders['Authorization'] = `Bearer ${token}`;
        }

        const config = {
            ...options,
            headers: {
                ...defaultHeaders,
                ...options.headers,
            },
        };

        try {
            const response = await fetch(url, config);
            const data = await response.json();

            if (response.status === 401) {
                this.clearAuth();
                window.location.href = 'login.html';
                return;
            }

            if (!response.ok) {
                throw { response, data };
            }

            return data;
        } catch (error) {
            if (error.data) throw error;
            console.error('API Error:', error);
            throw { data: { message: 'Gagal terhubung ke server. Pastikan backend berjalan.' } };
        }
    },

    get(endpoint) {
        return this.request(endpoint, { method: 'GET' });
    },

    post(endpoint, body) {
        return this.request(endpoint, {
            method: 'POST',
            body: JSON.stringify(body),
        });
    },

    put(endpoint, body) {
        return this.request(endpoint, {
            method: 'PUT',
            body: JSON.stringify(body),
        });
    },

    delete(endpoint) {
        return this.request(endpoint, { method: 'DELETE' });
    },
};
