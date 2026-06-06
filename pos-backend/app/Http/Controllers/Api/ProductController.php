<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function index()
{
    $products = Product::where('is_active', true)
        ->get()
        ->map(function ($product) {

            $product->image_url =
                url('storage/' . $product->image);

            return $product;
        });

    return response()->json([
        'list' => $products
    ]);
}

    public function store(Request $request)
    {
        $data = $request->all();

        if ($request->hasFile('image')) {
            $file = $request->file('image');

            $name = pathinfo($file->getClientOriginalName(), PATHINFO_FILENAME);
            $extension = $file->getClientOriginalExtension();

            $cleanName = strtolower(str_replace(' ', '_', $name));

            $filename = time() . '_' . $cleanName . '.' . $extension;

            $path = $file->storeAs('products', $filename, 'public');

            $data['image'] = $path;
        }

        return Product::create($data);
    }

    public function show($id)
    {
        return Product::findOrFail($id);
    }

    public function update(Request $request, $id)
    {
        $product = Product::findOrFail($id);
        $data = $request->all();

        if ($request->hasFile('image')) {
            $file = $request->file('image');

            $name = pathinfo($file->getClientOriginalName(), PATHINFO_FILENAME);
            $extension = $file->getClientOriginalExtension();

            $cleanName = strtolower(str_replace(' ', '_', $name));

            $filename = time() . '_' . $cleanName . '.' . $extension;

            $path = $file->storeAs('products', $filename, 'public');

            $data['image'] = $path;
        }

        $product->update($data);
        return $product;
    }

    public function destroy($id)
{
    try {

        $product = Product::findOrFail($id);

        $product->is_active = false;
        $product->save();

        return response()->json([
            'message' => 'Product deactivated'
        ]);

    } catch (\Exception $e) {

        return response()->json([
            'error' => $e->getMessage()
        ], 500);

    }
}

public function restock(
    Request $request,
    $id
)
{
    $product =
        Product::findOrFail($id);

    $product->stock +=
        (int) $request->qty;

    $product->save();

    return response()->json([
        'message' => 'Restock success'
    ]);
}
}
