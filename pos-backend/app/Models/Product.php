<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

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

    public $timestamps = false;

    public function cart(): HasMany
    {
        return $this->hasMany(Cart::class);
    }

    public function transactions(): BelongsToMany {
        return $this->belongsToMany(Transaction::class);
    }

}
