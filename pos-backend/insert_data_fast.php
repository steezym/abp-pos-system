<?php
try {
    $db = new PDO('mysql:host=127.0.0.1;port=3306;dbname=abp_pos_system', 'root', '', [PDO::ATTR_TIMEOUT => 3]);

    $db->exec('SET FOREIGN_KEY_CHECKS=0');
    $db->exec('TRUNCATE TABLE users');
    $db->exec('TRUNCATE TABLE products');
    $db->exec('SET FOREIGN_KEY_CHECKS=1');

    $hash = '$2y$10$ZlYu73ynUVTPhTmyQVNL0.Vl3Ux5aweprOj5QSryimbUF8PpgyU9m'; // Hash for 'password'

    $users = [
        ['Budi Santoso', 'admin', $hash, 'admin', 'aktif'],
        ['Ahmad Rizki', 'ahmad', $hash, 'manager', 'aktif'],
        ['Rina Kusuma', 'rina', $hash, 'manager', 'aktif'],
        ['Siti Aminah', 'siti', $hash, 'kasir', 'aktif'],
        ['Dewi Lestari', 'dewi', $hash, 'kasir', 'aktif'],
        ['Andi Wijaya', 'andi', $hash, 'kasir', 'nonaktif'],
        ['Faisal Rahman', 'faisal', $hash, 'kasir', 'aktif'],
        ['Lisa Anggraini', 'lisa', $hash, 'kasir', 'aktif'],
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
