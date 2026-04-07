<?php

namespace Database\Seeders;

use App\Models\User;
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
            'password' => 'password',
            'role' => 'admin',
            'status' => 'aktif',
        ]);

        // Manager users
        User::create([
            'name' => 'Ahmad Rizki',
            'email' => 'ahmad.rizki@toko.com',
            'password' => 'password',
            'role' => 'manager',
            'status' => 'aktif',
        ]);

        User::create([
            'name' => 'Rina Kusuma',
            'email' => 'rina.kusuma@toko.com',
            'password' => 'password',
            'role' => 'manager',
            'status' => 'aktif',
        ]);

        // Kasir users
        User::create([
            'name' => 'Siti Aminah',
            'email' => 'siti.aminah@toko.com',
            'password' => 'password',
            'role' => 'kasir',
            'status' => 'aktif',
        ]);

        User::create([
            'name' => 'Dewi Lestari',
            'email' => 'dewi.lestari@toko.com',
            'password' => 'password',
            'role' => 'kasir',
            'status' => 'aktif',
        ]);

        User::create([
            'name' => 'Andi Wijaya',
            'email' => 'andi.wijaya@toko.com',
            'password' => 'password',
            'role' => 'kasir',
            'status' => 'nonaktif',
        ]);

        User::create([
            'name' => 'Faisal Rahman',
            'email' => 'faisal.rahman@toko.com',
            'password' => 'password',
            'role' => 'kasir',
            'status' => 'aktif',
        ]);

        User::create([
            'name' => 'Lisa Anggraini',
            'email' => 'lisa.anggraini@toko.com',
            'password' => 'password',
            'role' => 'kasir',
            'status' => 'aktif',
        ]);
    }
}
