<?php
try {
    $db = new PDO('mysql:host=127.0.0.1;port=3306;dbname=abp_pos_system', 'root', '', [PDO::ATTR_TIMEOUT => 3]);

    $db->exec('SET FOREIGN_KEY_CHECKS=0');
    $db->exec('TRUNCATE TABLE users');
    $db->exec('TRUNCATE TABLE products');
    $db->exec('SET FOREIGN_KEY_CHECKS=1');

    $users = [
        ['Budi Santoso', 'admin', password_hash('password', PASSWORD_BCRYPT), 'admin', 'aktif'],
        ['Ahmad Rizki', 'ahmad', password_hash('password', PASSWORD_BCRYPT), 'manager', 'aktif'],
        ['Rina Kusuma', 'rina', password_hash('password', PASSWORD_BCRYPT), 'manager', 'aktif'],
        ['Siti Aminah', 'siti', password_hash('password', PASSWORD_BCRYPT), 'kasir', 'aktif'],
        ['Dewi Lestari', 'dewi', password_hash('password', PASSWORD_BCRYPT), 'kasir', 'aktif'],
        ['Andi Wijaya', 'andi', password_hash('password', PASSWORD_BCRYPT), 'kasir', 'nonaktif'],
        ['Faisal Rahman', 'faisal', password_hash('password', PASSWORD_BCRYPT), 'kasir', 'aktif'],
        ['Lisa Anggraini', 'lisa', password_hash('password', PASSWORD_BCRYPT), 'kasir', 'aktif'],
    ];
    $stmt = $db->prepare('INSERT INTO users (name, username, password, role, status) VALUES (?, ?, ?, ?, ?)');
    foreach ($users as $u) {
        $stmt->execute($u);
    }

    $products = [
        ['Teh Botol', 'Minuman', 100, 50, 2900, 'products/1776013197_teh_botol.jpg', 1],
        ['Aqua', 'Minuman', 40, 100, 3500, 'products/1776013144_aqua.jpg', 1],
        ['Banana Pudding', 'Makanan', 0, 10, 20000, 'products/1776013226_banana_pudding.jpg', 1],
    ];
    $stmt = $db->prepare('INSERT INTO products (name, category, stock, min_stock, price, image, is_active) VALUES (?, ?, ?, ?, ?, ?, ?)');
    foreach ($products as $p) {
        $stmt->execute($p);
    }

    echo "Seeded directly!\n";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
