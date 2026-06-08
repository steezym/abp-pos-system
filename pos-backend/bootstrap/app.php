<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->api(prepend: [
            \App\Http\Middleware\CorsMiddleware::class,
        ]);

        $middleware->alias([
            'admin'      => \App\Http\Middleware\AdminMiddleware::class,      // Admin + Manager
            'admin_only' => \App\Http\Middleware\AdminOnlyMiddleware::class,  // Admin saja
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        //
    })->create();
