import 'package:pos_mobile/models/Product.dart';

class Transaction {
  final int id;
  final int quantity ;
  final int total ;
  final String date;
  final String time;
  final String payment_method;

  const Transaction({
    required this.id,
    required this.quantity,
    required this.total,
    required this.date,
    required this.time,
    required this.payment_method
  });

  factory Transaction.fromJson(Map<String, dynamic> json){
    return Transaction(
        id: json['id'],
        quantity: json['quantity'],
        total: json['total'],
        date: json['date'],
        time: json['time'],
        payment_method: json['payment_method'],
    );
  }
}