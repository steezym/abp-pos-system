import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class StockScreen extends StatefulWidget {
  final VoidCallback? onRestockDone;

  const StockScreen({super.key, this.onRestockDone});

  @override
  State<StockScreen> createState() => StockScreenState();
}

class StockScreenState extends State<StockScreen> {
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

  /// Opens a bottom sheet where the user inputs a restock quantity,
  /// then calls the API and refreshes the product list on success.
  void showRestockSheet(Map<String, dynamic> item) {
    final TextEditingController qtyCtrl = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Restock Produk',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['name'],
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Stok saat ini: ${item['stock']}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.success,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Qty input
                  TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Jumlah restock',
                      hintText: 'Masukkan jumlah',
                      prefixIcon: const Icon(Icons.add_box_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final qty = int.tryParse(qtyCtrl.text.trim());
                              if (qty == null || qty <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Masukkan jumlah yang valid'),
                                  ),
                                );
                                return;
                              }

                              setSheetState(() => isSubmitting = true);

                              try {
                                await ApiService.restock(item['id'], qty);

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Restock ${item['name']} berhasil (+$qty)',
                                      ),
                                      backgroundColor: AppTheme.success,
                                    ),
                                  );
                                  loadProducts();
                                  widget.onRestockDone?.call();
                                }
                              } catch (e) {
                                setSheetState(() => isSubmitting = false);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Gagal restock: $e'),
                                      backgroundColor: AppTheme.danger,
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Simpan Restock',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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

                    const SizedBox(height: 16),

                    TextField(
                      controller: searchCtrl,
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Cari produk',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final selected = selectedCategory == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCategory = index;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
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

                    const SizedBox(height: 20),

                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : GridView.builder(
                              itemCount: filteredProducts.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    childAspectRatio: 1.8,
                                  ),
                              itemBuilder: (context, index) {
                                final item = filteredProducts[index];
                                final stock =
                                    int.tryParse(item['stock'].toString()) ?? 0;
                                final outOfStock = stock == 0;

                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppTheme.border),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Product image
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
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

                                      // Product info
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
                                                color: outOfStock
                                                    ? AppTheme.textMuted
                                                    : AppTheme.textPrimary,
                                              ),
                                            ),

                                            const SizedBox(height: 4),

                                            Text(
                                              rupiah(item['price']),
                                              style: TextStyle(
                                                color: outOfStock
                                                    ? AppTheme.textMuted
                                                    : Colors.red,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),

                                            const SizedBox(height: 2),

                                            Text(
                                              outOfStock
                                                  ? 'Stok Habis'
                                                  : 'Stok: ${item['stock']}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: outOfStock
                                                    ? AppTheme.danger
                                                    : AppTheme.success,
                                              ),
                                            ),

                                            const SizedBox(height: 6),

                                            Row(
                                              children: [
                                                // Restock button
                                                GestureDetector(
                                                  onTap: () =>
                                                      showRestockSheet(item),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: AppTheme.primary
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      border: Border.all(
                                                        color: AppTheme.primary
                                                            .withOpacity(0.3),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .inventory_2_outlined,
                                                          size: 12,
                                                          color:
                                                              AppTheme.primary,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          'Restock',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: AppTheme
                                                                .primary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(width: 8),
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
          ],
        ),
      ),
    );
  }
}
