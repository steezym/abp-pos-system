<?php

namespace App\Models;
use App\Models\Product;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Cart extends Model
{
    protected $table = 'cart';
    protected $fillable = [
       'id','product_id','quantity','user_id' 
    ];

    public $timestamps = false;

    public function products(): BelongsTo
    {
        return $this->belongsTo(Product::class,'product_id');
    }

    public function user(): BelongsTo 
    {
        return $this->belongsTo(User::class);
    }
}
