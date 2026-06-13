import 'package:pos_mobile/models/Product.dart';

class DetailTransaction {
  final int id;
  final int quantity ;
  final int total;
  final String date;
  final String time;
  final String payment_method;
  final List<Product> products;

  const DetailTransaction({
    required this.id,
    required this.quantity,
    required this.total,
    required this.date,
    required this.time,
    required this.payment_method,
    required this.products
  });

  factory DetailTransaction.fromJson(Map<String, dynamic> json){
    var parsed = json["products"].cast<Map<String, dynamic>>();
    return DetailTransaction(
        id: json['id'],
        quantity: json['quantity'],
        total: json['total'],
        date: json['date'],
        time: json['time'],
        payment_method: json['payment_method'],
        products: parsed.map<Product>((item)=>Product.fromJson(item)).toList()
    );
  }
}