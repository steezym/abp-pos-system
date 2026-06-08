<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminOnlyMiddleware
{
    /**
     * Hanya Admin yang boleh akses — Manager tidak diizinkan.
     */
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->user()->role !== 'admin') {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak. Hanya Admin yang dapat melakukan aksi ini.',
            ], 403);
        }

        return $next($request);
    }
}
