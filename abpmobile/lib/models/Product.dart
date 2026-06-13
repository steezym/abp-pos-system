import 'package:pos_mobile/models/Details.dart';

class Product {
  final int id;
  final String name;
  final int price;
  final Details details;


  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.details
  });

  factory Product.fromJson(Map<String, dynamic> json){
    return Product(
        id: json["id"],
        name: json["name"],
        price: json["price"],
        details: Details.fromJson(json["details"])
    );
  }
}