<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\TransactionController;
use App\Http\Controllers\Api\CartController;
use App\Http\Controllers\Api\NotificationController;
use Illuminate\Support\Facades\Route;

// Public routes
Route::post('/login', [AuthController::class, 'login']);

// Public product route (Tugas Week 11 - accessible without auth)
Route::resource('product', ProductController::class);

// Public AI Bundling Insights (for mobile upsell)
Route::get('/transaction/bundling/insights', [TransactionController::class, 'bundlingInsights']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);

    // User Management
    // Admin + Manager: lihat daftar, tambah, edit user
    Route::middleware('admin')->group(function () {
        Route::get('/users', [UserController::class, 'index']);
        Route::post('/users', [UserController::class, 'store']);
        Route::get('/users/{user}', [UserController::class, 'show']);
        Route::put('/users/{user}', [UserController::class, 'update']);
    });

    // Admin saja: hapus user dan reset password
    Route::middleware('admin_only')->group(function () {
        Route::delete('/users/{user}', [UserController::class, 'destroy']);
        Route::post('/users/{user}/reset-password', [UserController::class, 'resetPassword']);
    });

    // Products (protected)
    Route::apiResource('products', ProductController::class);

    // Transaction Management
    Route::get('/cart', [CartController::class, 'get']);
    Route::post('/cart', [CartController::class, 'insert']);
    Route::put('/cart/{id}', [CartController::class, 'update']);
    Route::delete('/cart/{id}', [CartController::class, 'delete']);
    Route::get('/transaction', [TransactionController::class, 'get']);
    Route::get('/transaction/dailysum', [TransactionController::class, 'dailysum']);
    Route::get('/transaction/weeklysum', [TransactionController::class, 'weeklysum']);
    Route::get('/transaction/{id}', [TransactionController::class, 'show']);
    Route::post('/transaction', [TransactionController::class, 'insert']);

    Route::post(
    '/mobile-checkout',
    [TransactionController::class,
     'mobileCheckout']

     
);
Route::get('/notifications', [NotificationController::class, 'index']);
Route::post('/notifications/read/{id}', [NotificationController::class, 'markRead']);

Route::post(
    '/products/{id}/restock',
    [ProductController::class, 'restock']
);
});
