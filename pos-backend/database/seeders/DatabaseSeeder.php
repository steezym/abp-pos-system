<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Product;
use App\Models\Transaction;
use App\Models\ProductTransaction;
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

        Transaction::create([
            'quantity'=>'4',
            'total'=>'47000',
            'date'=>'2026-04-12',
            'time'=>'09:51:42',
            'payment_method'=>'QRIS',
        ]);

        Transaction::create([
            'quantity'=>'1',
            'total'=>'20000',
            'date'=>'2026-04-13',
            'time'=>'10:57:42',
            'payment_method'=>'QRIS',
        ]);

        Transaction::create([
            'quantity'=>'3',
            'total'=>'43500',
            'date'=>'2026-04-13',
            'time'=>'11:00:36',
            'payment_method'=>'QRIS',
        ]);

        Transaction::create([
            'quantity'=>'2',
            'total'=>'23500',
            'date'=>'2026-04-14',
            'time'=>'11:01:20',
            'payment_method'=>'Cash',
        ]);

        Transaction::create([
            'quantity'=>'4',
            'total'=>'80000',
            'date'=>'2026-04-15',
            'time'=>'11:05:41',
            'payment_method'=>'QRIS',
        ]);

        ProductTransaction::create([
            'transaction_id'=>1,
            'product_id'=>3,
            'quantity'=>2,
            'price'=>20000,
        ]);

        ProductTransaction::create([
            'transaction_id'=>1,
            'product_id'=>2,
            'quantity'=>2,
            'price'=>3500,
        ]);

        ProductTransaction::create([
            'transaction_id'=>2,
            'product_id'=>3,
            'quantity'=>1,
            'price'=>20000,
        ]);

        ProductTransaction::create([
            'transaction_id'=>3,
            'product_id'=>3,
            'quantity'=>2,
            'price'=>20000,
        ]);

        ProductTransaction::create([
            'transaction_id'=>3,
            'product_id'=>2,
            'quantity'=>1,
            'price'=>3500,
        ]);

        ProductTransaction::create([
            'transaction_id'=>4,
            'product_id'=>3,
            'quantity'=>1,
            'price'=>20000,
        ]);

        ProductTransaction::create([
            'transaction_id'=>4,
            'product_id'=>2,
            'quantity'=>1,
            'price'=>3500,
        ]);

        ProductTransaction::create([
            'transaction_id'=>5,
            'product_id'=>3,
            'quantity'=>4,
            'price'=>20000,
        ]);

    }
}
