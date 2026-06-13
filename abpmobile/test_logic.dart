import 'dart:convert';

void main() {
  final aiInsights = [
    {
      "bundle": "Aqua & Banana Pudding",
      "count": 3,
      "percentage": 42.9,
      "message": "Promo Bundling..."
    }
  ];

  final products = [
    {'name': 'Aqua', 'qty': 0, 'stock': 10},
    {'name': 'Banana Pudding', 'qty': 0, 'stock': 10},
    {'name': 'Teh Botol', 'qty': 0, 'stock': 10},
  ];

  for (int i = 0; i < products.length; i++) {
    final productName = products[i]['name'].toString().trim();
    print('\nTesting click on: $productName');

    bool found = false;
    for (var insight in aiInsights) {
      final bundle = insight['bundle']?.toString() ?? '';
      print('  Checking bundle: "$bundle" contains "$productName" => ${bundle.toLowerCase().contains(productName.toLowerCase())}');
      
      if (bundle.toLowerCase().contains(productName.toLowerCase())) {
        final parts = bundle.split('&');
        String otherProduct = '';
        for (var part in parts) {
          if (part.trim().toLowerCase() != productName.toLowerCase()) {
            otherProduct = part.trim();
            break;
          }
        }
        
        if (otherProduct.isNotEmpty) {
          print('  >>> MATCH FOUND! Suggesting: $otherProduct');
          found = true;
          break;
        }
      }
    }
    
    if (!found) {
      print('  No suggestion for $productName');
    }
  }
}
