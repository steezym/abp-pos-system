<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function index()
    {
        return response()->json(Product::all());
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
        Product::destroy($id);
        return response()->json(['message' => 'Deleted']);
    }
}
