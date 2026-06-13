import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

import 'cashier_screen.dart';
import 'transaction_screen.dart';
import 'stock_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _user;

  final GlobalKey<CashierScreenState> _cashierKey =
      GlobalKey<CashierScreenState>();
  final GlobalKey<StockScreenState> _stockKey = GlobalKey<StockScreenState>();

  late final List<Widget> screens; // ← declared here as a field

  @override
  void initState() {
    super.initState();
    _loadUser();

    screens = [
      CashierScreen(key: _cashierKey),
      TransactionScreen(),
      StockScreen(
        key: _stockKey,
        onRestockDone: () {
          _cashierKey.currentState?.loadProducts();
        },
      ),
    ];
  }

  void _loadUser() async {
    final u = await ApiService.getUser();
    if (u == null) {
      _logout();
      return;
    }
    setState(() => _user = u);
  }

  void _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final String name = _user!['name'] ?? 'Kasir';

    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.point_of_sale),
        label: 'Kasir',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.receipt_long),
        label: 'Riwayat',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.add_box),
        label: 'Update Stock',
      ),
    ];

    final titles = ['Kasir', 'Riwayat Transaksi', 'Restock'];

    return Scaffold(
      appBar: AppBar(
        title: _currentIndex == 0
            ? Image.asset('assets/images/logo.png', height: 32)
            : Text(titles[_currentIndex]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppTheme.primary.withOpacity(0.15),
                  child: Icon(Icons.person, size: 16, color: AppTheme.primary),
                ),
                SizedBox(width: 6),
                Text(
                  name,
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(icon: Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          if (i == 2) {
            _stockKey.currentState?.loadProducts(); // reload on tab switch
          }
        },
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary,
        items: navItems,
      ),
    );
  }
}
