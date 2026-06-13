class Details {
  final int transaction_id;
  final int product_id;
  final int quantity;
  final int price;

  const Details({
    required this.transaction_id,
    required this.product_id,
    required this.quantity,
    required this.price
  });

    factory Details.fromJson(Map<String, dynamic> json){
      return Details(
          transaction_id: json["transaction_id"],
          product_id: json["product_id"],
          quantity: json["quantity"],
          price: json["price"]
      );
    }
}
