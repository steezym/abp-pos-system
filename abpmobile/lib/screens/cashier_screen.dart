import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'payment_screen.dart';
import '../services/api_service.dart';

class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key});

  @override
  State<CashierScreen> createState() => CashierScreenState();
}

class CashierScreenState extends State<CashierScreen> {
  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  final TextEditingController searchCtrl = TextEditingController();
  String searchQuery = '';

  int selectedCategory = 0;

  final List<String> categories = ['All', 'Makanan', 'Minuman'];

  Future<void> loadProducts() async {
    try {
      print('LOAD PRODUCTS');

      final data = await ApiService.getProducts();

      print(data);

      setState(() {
        products = data.map<Map<String, dynamic>>((e) {
          return {
            'id': e['id'],
            'name': e['name'],
            'price': e['price'],
            'image': e['image_url'],
            'qty': 0,
            'stock': e['stock'],
            'category': e['category'],
          };
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      print('ERROR LOAD PRODUCT');
      print(e);

      setState(() {
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> products = [];
  bool isLoading = true;

  List<Map<String, dynamic>> get filteredProducts {
    return products.where((product) {
      final name = product['name'].toString().toLowerCase();

      final category = product['category'].toString();

      final matchSearch = name.contains(searchQuery.toLowerCase());

      final matchCategory =
          selectedCategory == 0 || category == categories[selectedCategory];

      return matchSearch && matchCategory;
    }).toList();
  }

  void increaseQty(int index) {
    final stock = int.tryParse(products[index]['stock'].toString()) ?? 0;
    if (products[index]['qty'] >= stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stok tidak mencukupi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      products[index]['qty']++;
    });
  }

  void decreaseQty(int index) {
    if (products[index]['qty'] > 0) {
      setState(() {
        products[index]['qty']--;
      });
    }
  }

  void resetCart() {
    setState(() {
      for (var item in products) {
        item['qty'] = 0;
      }
    });
  }

  int get total {
    int result = 0;
    for (var item in products) {
      final price = int.tryParse(item['price'].toString()) ?? 0;
      final qty = int.tryParse(item['qty'].toString()) ?? 0;
      result += price * qty;
    }
    return result;
  }

  String rupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Beranda',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),

                    SizedBox(height: 16),

                    TextField(
                      controller: searchCtrl,
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari produk',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),

                    SizedBox(height: 16),

                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final selected = selectedCategory == index;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCategory = index;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 18),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppTheme.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTheme.border),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                categories[index],
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? Colors.white
                                      : AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 20),

                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : GridView.builder(
                              itemCount: filteredProducts.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    childAspectRatio: 0.62,
                                  ),
                              itemBuilder: (context, index) {
                                final item = filteredProducts[index];

                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppTheme.border),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(16),
                                          ),
                                          child: Image.network(
                                            item['image'],
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    color: Colors.grey[100],
                                                    child: Icon(
                                                      Icons.image_not_supported,
                                                      color: Colors.grey[400],
                                                    ),
                                                  );
                                                },
                                          ),
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['name'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color:
                                                    (int.tryParse(
                                                              item['stock']
                                                                  .toString(),
                                                            ) ??
                                                            0) ==
                                                        0
                                                    ? AppTheme.textMuted
                                                    : AppTheme.textPrimary,
                                              ),
                                            ),

                                            SizedBox(height: 4),

                                            Text(
                                              rupiah(item['price']),
                                              style: TextStyle(
                                                color:
                                                    (int.tryParse(
                                                              item['stock']
                                                                  .toString(),
                                                            ) ??
                                                            0) ==
                                                        0
                                                    ? AppTheme.textMuted
                                                    : Colors.red,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),

                                            SizedBox(height: 2),

                                            Text(
                                              (int.tryParse(
                                                            item['stock']
                                                                .toString(),
                                                          ) ??
                                                          0) ==
                                                      0
                                                  ? 'Stok Habis'
                                                  : 'Stok: ${item['stock']}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    (int.tryParse(
                                                              item['stock']
                                                                  .toString(),
                                                            ) ??
                                                            0) ==
                                                        0
                                                    ? AppTheme.danger
                                                    : AppTheme.success,
                                              ),
                                            ),

                                            SizedBox(height: 6),

                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    final originalIndex =
                                                        products.indexOf(item);

                                                    decreaseQty(originalIndex);
                                                  },
                                                  child: _qtyButton(
                                                    Icons.remove,
                                                  ),
                                                ),

                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                                  child: Text(
                                                    item['qty'].toString(),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),

                                                GestureDetector(
                                                  onTap: () {
                                                    final originalIndex =
                                                        products.indexOf(item);

                                                    increaseQty(originalIndex);
                                                  },
                                                  child: _qtyButton(Icons.add),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.primary),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        SizedBox(height: 4),
                        Text(
                          rupiah(total),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primary,
                    ),
                    onPressed: total == 0
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentScreen(
                                  products: products,
                                  total: total,
                                  onFinish: resetCart,
                                ),
                              ),
                            ).then((_) {
                              loadProducts();
                            });
                          },
                    child: Row(
                      children: [
                        Text('Bayar Sekarang'),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_ios, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyButton(IconData icon) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppTheme.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 14, color: Colors.white),
    );
  }
}
