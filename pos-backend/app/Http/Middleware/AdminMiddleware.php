<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminMiddleware
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (!in_array($request->user()->role, ['admin', 'manager'])) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak. Hanya Admin dan Manager yang dapat mengakses.',
            ], 403);
        }

        return $next($request);
    }
}
