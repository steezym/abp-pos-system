<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cart;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;


class CartController extends Controller
{
    public function get() {
        $cart = DB::table('cart')
           ->join('products', 'cart.product_id', '=', 'products.id')
           ->join('users', 'cart.user_id', '=', 'users.id')
           ->select('cart.id','cart.quantity','products.name AS product', 'users.name AS user')
           ->get();

        return response()->json([
            'status'=>'success',
            'data'=>$cart
        ], 200);
    }

    public function insert(Request $request) {
        $cart_data = $request->validate([
            'product_id'=>'required',
            'quantity'=>'required',
            'user_id'=>'required',
        ]);

        $cart = Cart::create($cart_data);
        return response()->json([
            'status'=>'success',
            'data'=>$cart
        ], 201);
    }

    public function update(Request $request, $id) {
        $cart = Cart::findOrFail($id);
        $cart->quantity = $request->quantity ? $request->quantity : $cart->quantity;
        $cart->save();

         return response()->json([
            'status'=>'success',
            'data'=>$cart
        ], 201);
    }

    public function delete($id) {
        $cart = Cart::findOrFail($id);
        $cart->delete();

        return response()->json([
            'status'=>'success',
            'data'=>$cart
        ], 200);
    }
}
