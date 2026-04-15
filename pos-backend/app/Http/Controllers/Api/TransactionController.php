<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Cart;
use App\Models\Product;
use App\Models\Transaction;
use Carbon\Carbon;

class TransactionController extends Controller
{
    public function get(Request $request) {
        $tr = Transaction::get();
        $tr_total = Transaction::count();
        $tr_revenue = Transaction::sum('total');
        $tr_max = Transaction::max('total');
        $tr_min = Transaction::min('total');

        if ($request->has('search') && $request->search) {
            $search = $request->search;
            $tr = Transaction::where('id',$search)->get(); 
        }

        if(($request->has('start') && $request->start) && ($request->has('end') && $request->end)) {
            $start = $request->start;
            $end = $request->end;
            $tr = Transaction::whereBetween('date',[$start,$end])->get();
        }

        return response()->json([
            "status"=>"success",
            "data"=>[
                "transactions"=>$tr,
                "stats"=>[
                    "total"=>$tr_total,
                    "revenue"=>$tr_revenue,
                    "max"=>$tr_max,
                    "min"=>$tr_min,
                ]
            ]
        ]);
    }

    public function insert(Request $request) {
        $cart = Cart::with('products')->where('user_id', $request->user_id)->get();
        $products = Product::select('id','stock')->whereIn('id',$cart->pluck('product_id'))->pluck('stock','id');
        foreach($cart as $cart_product) {
            if(!isset($products[$cart_product->product_id]) || $products[$cart_product->product_id] < $cart_product->quantity) {
                return response()->json([
                    "status"=>'error',
                    "message"=>"Stock not enough for your needed quantity!"
                ]);
            }
        }
        
        $date = Carbon::now();

        $tr = Transaction::create([
            "date"=>$date->format('Y-m-d'),
            "time"=>$date->toTimeString(),
            "quantity"=>0,
            "total"=>0,
            "payment_method"=>$request->payment_method
        ]);

        foreach ($cart as $cart_product) {
            $tr->products()->attach($cart_product->product_id,[
                "quantity"=>$cart_product->quantity,
                "price"=>$cart_product->products->price
            ]);

            $tr->increment('quantity', $cart_product->quantity);
            $tr->increment('total',$cart_product->products->price * $cart_product->quantity);
            Product::find($cart_product->product_id)->decrement('stock',$cart_product->quantity);
        }

        Cart::where('user_id', $request->user_id)->delete();

        return response()->json([
            'status'=>'success',
            'message'=>'Transaction successfully created!'
        ], 200);
    }

    public function show($id) {
        $tr = Transaction::with('products:id,name,price')->where('id',$id)->get();
        return response()->json([
            "status"=>"success",
            "data"=>$tr
        ]);
    }
}
