<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Product;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Admin user
        User::create([
            'name' => 'Budi Santoso',
            'email' => 'admin@toko.com',
            'password' => bcrypt('password'),
            'role' => 'admin',
            'status' => 'aktif',
        ]);

        // Manager users
        User::create([
            'name' => 'Ahmad Rizki',
            'email' => 'ahmad.rizki@toko.com',
            'password' => bcrypt('password'),
            'role' => 'manager',
            'status' => 'aktif',
        ]);

        User::create([
            'name' => 'Rina Kusuma',
            'email' => 'rina.kusuma@toko.com',
            'password' => bcrypt('password'),
            'role' => 'manager',
            'status' => 'aktif',
        ]);

        // Kasir users
        User::create([
            'name' => 'Siti Aminah',
            'email' => 'siti.aminah@toko.com',
            'password' => bcrypt('password'),
            'role' => 'kasir',
            'status' => 'aktif',
        ]);

        User::create([
            'name' => 'Dewi Lestari',
            'email' => 'dewi.lestari@toko.com',
            'password' => bcrypt('password'),
            'role' => 'kasir',
            'status' => 'aktif',
        ]);

        User::create([
            'name' => 'Andi Wijaya',
            'email' => 'andi.wijaya@toko.com',
            'password' => bcrypt('password'),
            'role' => 'kasir',
            'status' => 'nonaktif',
        ]);

        User::create([
            'name' => 'Faisal Rahman',
            'email' => 'faisal.rahman@toko.com',
            'password' => bcrypt('password'),
            'role' => 'kasir',
            'status' => 'aktif',
        ]);

        User::create([
            'name' => 'Lisa Anggraini',
            'email' => 'lisa.anggraini@toko.com',
            'password' => bcrypt('password'),
            'role' => 'kasir',
            'status' => 'aktif',
        ]);

        // Sample products
        Product::create([
            'name' => 'Teh Botol',
            'category' => 'Minuman',
            'stock' => 100,
            'min_stock' => 50,
            'price' => 2900,
            'image' => 'products/1776013197_teh_botol.jpg'
        ]);

        Product::create([
            'name' => 'Aqua',
            'category' => 'Minuman',
            'stock' => 40,
            'min_stock' => 100,
            'price' => 3500,
            'image' => 'products/1776013144_aqua.jpg'
        ]);

        Product::create([
            'name' => 'Banana Pudding',
            'category' => 'Makanan',
            'stock' => 0,
            'min_stock' => 10,
            'price' => 20000,
            'image' => 'products/1776013226_banana_pudding.jpg'
        ]);
    }
}
