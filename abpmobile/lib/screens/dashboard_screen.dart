import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cashier_screen.dart';
import 'transaction_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _user;
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadProfileImage();
  }

  void _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('profile_image');
    });
  }

  Future<void> _pickProfileImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      
      if (pickedFile != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image', pickedFile.path);
        setState(() {
          _profileImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      print('Failed to pick image: $e');
    }
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
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Konfirmasi Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final String name = _user!['name'] ?? 'Kasir';

    List<Widget> screens = [
      CashierScreen(),
      TransactionScreen(),
    ];
    
    List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'Kasir'),
      const BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Riwayat'),
    ];

    final titles = ['Kasir', 'Riwayat Transaksi'];

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
                GestureDetector(
                  onTap: _pickProfileImage,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primary.withOpacity(0.15),
                    backgroundImage: _profileImagePath != null 
                        ? FileImage(File(_profileImagePath!)) 
                        : null,
                    child: _profileImagePath == null 
                        ? Icon(Icons.camera_alt, size: 16, color: AppTheme.primary)
                        : null,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  name,
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary,
        items: navItems,
      ),
    );
  }
}
