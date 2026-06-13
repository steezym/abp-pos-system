import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class PaymentScreen extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final int total;
  final VoidCallback onFinish;

  const PaymentScreen({
    super.key,
    required this.products,
    required this.total,
    required this.onFinish,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String paymentMethod = 'cash';

  List<Map<String, dynamic>> get selectedProducts {
  return widget.products
      .where((e) => e['qty'] > 0)
      .toList();
}

  String rupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: selectedProducts.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = selectedProducts[index];

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: AppTheme.bgPage,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(10),
                          child: Image.network(
                            item['image'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[100],
                                child: Icon(Icons.image_not_supported, size: 20, color: Colors.grey[400]),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item['qty']} x ${rupiah(item['price'])}',
                                style: const TextStyle(
                                  color:
                                      AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          rupiah(
                            item['qty'] *
                                item['price'],
                          ),
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.border,
                ),
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          color:
                              AppTheme.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        rupiah(widget.total),
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: paymentMethod == 'cash'
          ? AppTheme.primary
          : AppTheme.bgPage,
      foregroundColor: paymentMethod == 'cash'
          ? Colors.white
          : AppTheme.textPrimary,
      elevation: 0,
      padding: const EdgeInsets.symmetric(
        vertical: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    onPressed: () {
      setState(() {
        paymentMethod = 'cash';
      });
    },
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.payments_outlined, size: 18),
        SizedBox(width: 6),
        Text('Cash'),
      ],
    ),
  ),
),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                paymentMethod ==
                                        'qris'
                                    ? AppTheme
                                        .primary
                                    : AppTheme
                                        .bgPage,
                            foregroundColor:
                                paymentMethod ==
                                        'qris'
                                    ? Colors.white
                                    : AppTheme
                                        .textPrimary,
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 14,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              paymentMethod =
                                  'qris';
                            });
                          },
                          child:
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.qr_code_2, size: 18),
                                  SizedBox(width: 6),
                                  Text('QRIS'),
                                ],
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (paymentMethod ==
                      'cash') {
                    showCashDialog();
                  } else {
                    showQrisDialog();
                  }
                },
                child: const Text('Proses Pembayaran'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showCashDialog() {
    final cashCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title:
            const Text('Pembayaran Cash'),
        content: TextField(
          controller: cashCtrl,
          keyboardType:
              TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Masukkan uang',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final cash =
                  int.tryParse(
                        cashCtrl.text,
                      ) ??
                      0;

              final change =
                  cash - widget.total;
              
              if (cash < widget.total) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Uang pembayaran kurang',
      ),
      backgroundColor: Colors.red,
    ),
  );
  return;
}

              Navigator.pop(context);

              showDialog(
                context: context,
                builder: (_) =>
                    AlertDialog(
                  title: const Text(
                    'Pembayaran Berhasil',
                  ),
                  content: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        'Total : ${rupiah(widget.total)}',
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Bayar : ${rupiah(cash)}',
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Kembalian : ${rupiah(change < 0 ? 0 : change)}',
                      ),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () async {
                        await ApiService.checkout(
                          selectedProducts.map((e) {
                            return {
                              'product_id': e['id'],
                              'quantity': e['qty'],
                            };
                          }).toList(),
                          'Cash',
                        );

                        widget.onFinish();

                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child:
                          const Text(
                        'Selesai',
                      ),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Bayar'),
          ),
        ],
      ),
    );
  }

  void showQrisDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title:
            const Text('QRIS Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.qr_code_2,
              size: 180,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Scan QR untuk pembayaran',
            ),
            const SizedBox(height: 8),
            Text(
              rupiah(widget.total),
              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await ApiService.checkout(
                selectedProducts.map((e) {
                  return {
                    'product_id': e['id'],
                    'quantity': e['qty'],
                  };
                }).toList(),
                'QRIS',
              );

              widget.onFinish();

              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }
}