<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\Cart;
use App\Models\Product;
use App\Models\Transaction;
use App\Models\Notification;
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

    public function dailysum(Request $request) {
        $validated = $request->validate([
            'start' => 'required|date',
            'end'   => 'required|date|after_or_equal:start',
        ]);

        $dailySummary = Transaction::select(
                DB::raw('DATE(date) as period'),
                DB::raw('COUNT(*) as volume'),
                DB::raw('SUM(total) as value')
            )
            ->whereBetween(
                DB::raw('DATE(date)'),
                [$validated['start'], $validated['end']]
            )
            ->groupBy('period')
            ->orderBy('period')
            ->get()
            ->keyBy('period');

        // generate all dates in range and fill missing with 0
        $start = Carbon::parse($validated['start']);
        $end = Carbon::parse($validated['end']);
        $allDates = [];

        for ($date = $start; $date->lte($end); $date->addDay()) {
            $period = $date->toDateString();
            $allDates[] = [
                'period' => $period,
                'volume' => $dailySummary[$period]->volume ?? 0,
                'value'  => $dailySummary[$period]->value ?? 0,
            ];
        }

        return response()->json([
            'status' => 'success',
            'data' => $allDates
        ]);
    }

    public function weeklysum(Request $request) {
        $validated = $request->validate([
            'start' => 'required|date',
            'end'   => 'required|date|after_or_equal:start',
        ]);

        // strftime() digunakan agar kompatibel dengan SQLite
        $data = Transaction::select(
                DB::raw("YEAR(date) as year"),
                DB::raw("WEEK(date) as week"),
                DB::raw('COUNT(*) as volume'),
                DB::raw('SUM(total) as value')
            )
            ->whereBetween(DB::raw('DATE(date)'), [$validated['start'], $validated['end']])
            ->groupBy('year', 'week')
            ->orderBy('year')
            ->orderBy('week')
            ->get()
            ->keyBy(function ($item) {
                return $item->year . '-' . $item->week;
            });

        $start = Carbon::parse($validated['start']);
        $end = Carbon::parse($validated['end']);
        $allWeeks = [];

        $current = $start->copy()->startOfWeek();

        while ($current->lte($end)) {
            $year = $current->format('Y');
            $week = $current->format('W');
            $key  = $year . '-' . $week;

            $allWeeks[] = [
                'period' => 'Week ' . $week . ' ' . $year,
                'volume' => $data[$key]->volume ?? 0,
                'value'  => $data[$key]->value  ?? 0,
            ];

            $current->addWeek();
        }

        return response()->json([
            'status' => 'success',
            'data'   => $allWeeks
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
            
            $product = Product::find($cart_product->product_id);
            $product->decrement('stock',$cart_product->quantity);
            $product->refresh();

            if ($product->stock <= $product->min_stock) {
                Notification::create([
                    'type'       => 'low_stock',
                    'title'      => 'Stok Menipis',
                    'message'    => $product->name . ' tersisa ' . $product->stock,
                    'product_id' => $product->id
                ]);
            }
        }

        Cart::where('user_id', $request->user_id)->delete();

        return response()->json([
            'status'=>'success',
            'message'=>'Transaction successfully created!'
        ], 200);
    }

    public function mobileCheckout(Request $request){
        $date = Carbon::now();

        $transaction = Transaction::create([
            "date" => $date->format('Y-m-d'),
            "time" => $date->toTimeString(),
            "quantity" => 0,
            "total" => 0,
            "payment_method" => $request->payment_method
        ]);

        foreach ($request->items as $item) {

            $product = Product::find($item['product_id']);

            if (!$product) {
                continue;
            }

            if ($product->stock < $item['quantity']) {
                return response()->json([
                    "status" => "error",
                    "message" => "Stock not enough"
            ], 400);
        }

            $transaction->products()->attach(
            $product->id,
            [
                "quantity" => $item['quantity'],
                "price" => $product->price
            ]
        );

        $transaction->increment(
            'quantity',
            $item['quantity']
        );

        $transaction->increment(
            'total',
            $product->price * $item['quantity']
        );

        $product->decrement(
            'stock',
            $item['quantity']
        );

        $product->refresh();

        if ($product->stock <= $product->min_stock) {

    Notification::create([
        'type'       => 'low_stock',
        'title'      => 'Stok Menipis',
        'message'    => $product->name . ' tersisa ' . $product->stock,
        'product_id' => $product->id
    ]);
}
    }

    Notification::create([
    'type'    => 'transaction',
    'title'   => 'Transaksi Baru',
    'message' => 'Transaksi berhasil sebesar Rp ' .
        number_format($transaction->total, 0, ',', '.')
    ]);

    return response()->json([
        "status" => "success",
        "message" => "Transaction successfully created!"
    ], 200);
}

    public function show($id) {
        $tr = Transaction::with('products:id,name,price')->where('id',$id)->get();
        return response()->json([
            "status"=>"success",
            "data"=>$tr
        ]);
    }

    public function bundlingInsights() {
        $transactions = Transaction::with('products')->get();
        $pairs = [];
        
        foreach($transactions as $transaction) {
            $products = $transaction->products->pluck('name', 'id')->toArray();
            $product_ids = array_keys($products);
            
            for ($i = 0; $i < count($product_ids); $i++) {
                for ($j = $i + 1; $j < count($product_ids); $j++) {
                    $p1 = $product_ids[$i];
                    $p2 = $product_ids[$j];
                    
                    $pair_key = $p1 < $p2 ? $p1.'_'.$p2 : $p2.'_'.$p1;
                    $pair_name = $p1 < $p2 ? $products[$p1].' & '.$products[$p2] : $products[$p2].' & '.$products[$p1];
                    
                    if (!isset($pairs[$pair_key])) {
                        $pairs[$pair_key] = [
                            'names' => $pair_name,
                            'count' => 0
                        ];
                    }
                    $pairs[$pair_key]['count']++;
                }
            }
        }
        
        usort($pairs, function($a, $b) {
            return $b['count'] <=> $a['count'];
        });
        
        $top_pairs = array_slice($pairs, 0, 3);
        $total_transactions = $transactions->count();
        
        $insights = array_map(function($pair) use ($total_transactions) {
            $percentage = $total_transactions > 0 ? round(($pair['count'] / $total_transactions) * 100, 1) : 0;
            return [
                'bundle' => $pair['names'],
                'count' => $pair['count'],
                'percentage' => $percentage,
                'message' => "Promo Bundling: " . $pair['names'] . " sangat potensial karena sering dibeli secara bersamaan."
            ];
        }, $top_pairs);
        
        return response()->json([
            'status' => 'success',
            'data' => $insights
        ]);
    }
}
