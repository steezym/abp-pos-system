<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    protected $fillable = [
    'name',
    'category',
    'stock',
    'min_stock',
    'price',
    'image'
];
}
