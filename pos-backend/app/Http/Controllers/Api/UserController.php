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

        // Search by name or email
        if ($request->has('search') && $request->search) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%");
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
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:6',
            'role' => 'required|in:admin,manager,kasir',
            'status' => 'required|in:aktif,nonaktif',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => $request->password,
            'role' => $request->role,
            'status' => $request->status,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pengguna berhasil ditambahkan',
            'data' => $user,
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
            'name' => 'required|string|max:255',
            'email' => [
                'required',
                'email',
                Rule::unique('users')->ignore($user->id),
            ],
            'password' => 'nullable|string|min:6',
            'role' => 'required|in:admin,manager,kasir',
            'status' => 'required|in:aktif,nonaktif',
        ]);

        $data = [
            'name' => $request->name,
            'email' => $request->email,
            'role' => $request->role,
            'status' => $request->status,
        ];

        if ($request->filled('password')) {
            $data['password'] = $request->password;
        }

        $user->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Pengguna berhasil diperbarui',
            'data' => $user->fresh(),
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

        $user->tokens()->delete();
        $user->delete();

        return response()->json([
            'success' => true,
            'message' => 'Pengguna berhasil dihapus',
        ]);
    }

    /**
     * Reset user password to a new random password
     */
    public function resetPassword(Request $request, User $user)
    {
        // Generate a new random password
        $newPassword = Str::random(8);

        $user->update([
            'password' => $newPassword,
        ]);

        // Revoke all tokens so user must login again
        $user->tokens()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Password berhasil direset',
            'data' => [
                'new_password' => $newPassword,
            ]
        ]);
    }
}
