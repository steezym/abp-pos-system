<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Transaction extends Model
{
    protected $table = 'transactions';
    protected $fillable = [
       'id','quantity','total','payment_method', 'date','time'
    ];
    public $timestamps = false;
    
    public function products() : belongsToMany {
        return $this->belongsToMany(Product::class)->withPivot('quantity','price')->as('details');
    }
}
