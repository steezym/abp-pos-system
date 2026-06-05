<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notification;

class NotificationController extends Controller
{
    public function index()
    {
        return response()->json([
            'notifications' =>
                Notification::orderBy('id', 'desc')
                    ->take(30)
                    ->get()
        ]);
    }

    public function markRead($id)
    {
        $notif =
            Notification::findOrFail($id);

        $notif->is_read = true;

        $notif->save();

        return response()->json([
            'success' => true
        ]);
    }
}