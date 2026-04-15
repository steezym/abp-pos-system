<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ProductTransaction extends Model
{
    protected $table = 'product_transaction';
    protected $fillable = [
       'id','transaction_id', 'product_id', 'quantity', 'price'
    ];

    public $timestamps = false;

}
