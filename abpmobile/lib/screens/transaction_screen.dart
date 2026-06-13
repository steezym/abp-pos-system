import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  List<dynamic> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getTransactions();
      setState(() => _transactions = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String rupiah(dynamic value) {
    final intVal = int.tryParse(value.toString()) ?? 0;
    return 'Rp ${intVal.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: AppTheme.textMuted),
            SizedBox(height: 16),
            Text('Belum ada transaksi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            SizedBox(height: 4),
            Text('Transaksi akan muncul setelah checkout',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: _transactions.length,
        separatorBuilder: (_, __) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          final t = _transactions[index];
          final date = t['date'] ?? '';
          final time = t['time'] ?? '';
          final total = t['total'] ?? 0;
          final qty = t['quantity'] ?? 0;
          final method = t['payment_method'] ?? 'Cash';
          final isQris = method.toString().toLowerCase() == 'qris';

          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isQris ? Color(0xFFEEF2FF) : Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isQris ? Icons.qr_code_2 : Icons.payments_outlined,
                    color: isQris ? Color(0xFF6366F1) : Color(0xFF22C55E),
                    size: 24,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Transaksi #${t['id']}',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isQris ? Color(0xFFEEF2FF) : Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              method,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isQris ? Color(0xFF6366F1) : Color(0xFF22C55E),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        '$date • $time',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '$qty item',
                        style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                Text(
                  rupiah(total),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
