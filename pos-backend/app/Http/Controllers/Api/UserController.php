<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    /**
     * Display a listing of users
     */
    public function index(Request $request)
    {
        $query = User::query();

        // Search by name or username
        if ($request->has('search') && $request->search) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('username', 'like', "%{$search}%");
            });
        }

        // Filter by role
        if ($request->has('role') && $request->role && $request->role !== 'semua') {
            $query->where('role', $request->role);
        }

        // Filter by status
        if ($request->has('status') && $request->status && $request->status !== 'semua') {
            $query->where('status', $request->status);
        }

        $users = $query->orderBy('created_at', 'desc')->get();

        // Get statistics
        $stats = [
            'total' => User::count(),
            'admin' => User::where('role', 'admin')->count(),
            'manager' => User::where('role', 'manager')->count(),
            'kasir' => User::where('role', 'kasir')->count(),
        ];

        return response()->json([
            'success' => true,
            'data' => [
                'users' => $users,
                'stats' => $stats,
            ]
        ]);
    }

    /**
     * Store a newly created user
     */
    public function store(Request $request)
    {
        $request->validate([
            'name'     => 'required|string|max:255',
            'username' => 'required|string|unique:users,username',
            'password' => 'required|string|min:6',
            'role'     => 'required|in:admin,manager,kasir',
            'status'   => 'required|in:aktif,nonaktif',
        ]);

        // Manager hanya boleh membuat user dengan role kasir
        if ($request->user()->role === 'manager' && in_array($request->role, ['admin', 'manager'])) {
            return response()->json([
                'success' => false,
                'message' => 'Manager hanya dapat membuat akun Kasir.',
            ], 403);
        }

        $user = User::create([
            'name'     => $request->name,
            'username' => $request->username,
            'password' => $request->password,
            'role'     => $request->role,
            'status'   => $request->status,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pengguna berhasil ditambahkan',
            'data'    => $user,
        ], 201);
    }

    /**
     * Display the specified user
     */
    public function show(User $user)
    {
        return response()->json([
            'success' => true,
            'data' => $user,
        ]);
    }

    /**
     * Update the specified user
     */
    public function update(Request $request, User $user)
    {
        $request->validate([
            'name'     => 'required|string|max:255',
            'username' => [
                'required',
                'string',
                Rule::unique('users')->ignore($user->id),
            ],
            'role'     => 'required|in:admin,manager,kasir',
            'status'   => 'required|in:aktif,nonaktif',
        ]);

        // Manager hanya boleh menetapkan role kasir
        if ($request->user()->role === 'manager' && in_array($request->role, ['admin', 'manager'])) {
            return response()->json([
                'success' => false,
                'message' => 'Manager hanya dapat menetapkan role Kasir.',
            ], 403);
        }

        // Manager tidak boleh mengedit user yang rolenya admin atau manager
        if ($request->user()->role === 'manager' && in_array($user->role, ['admin', 'manager'])) {
            return response()->json([
                'success' => false,
                'message' => 'Manager tidak dapat mengedit akun Admin atau sesama Manager.',
            ], 403);
        }

        $data = [
            'name'     => $request->name,
            'username' => $request->username,
            'role'     => $request->role,
            'status'   => $request->status,
        ];

        // Jika status diubah menjadi nonaktif, hapus semua token aktifnya agar ter-logout paksa
        if ($user->status === 'aktif' && $request->status === 'nonaktif') {
            $user->tokens()->delete();
        }

        $user->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Pengguna berhasil diperbarui',
            'data'    => $user->fresh(),
        ]);
    }

    /**
     * Remove the specified user
     */
    public function destroy(Request $request, User $user)
    {
        // Prevent deleting yourself
        if ($request->user()->id === $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Tidak dapat menghapus akun sendiri',
            ], 403);
        }

        // Manager tidak boleh menghapus user yang rolenya admin atau manager
        if ($request->user()->role === 'manager' && in_array($user->role, ['admin', 'manager'])) {
            return response()->json([
                'success' => false,
                'message' => 'Manager tidak dapat menghapus akun Admin atau sesama Manager.',
            ], 403);
        }

        $user->tokens()->delete();
        $user->delete();

        return response()->json([
            'success' => true,
            'message' => 'Pengguna berhasil dihapus',
        ]);
    }

    /**
     * Reset user password to a new password provided by Admin
     */
    public function resetPassword(Request $request, User $user)
    {
        $request->validate([
            'password' => 'required|string|min:6',
        ]);

        $user->update([
            'password' => $request->password,
        ]);

        // Revoke all tokens so user must login again
        $user->tokens()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Password berhasil direset',
        ]);
    }
}
