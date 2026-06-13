import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<dynamic> _users = [];
  bool _isLoading = true;
  String _search = '';
  String _role = 'semua';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await ApiService.getUsers(search: _search, role: _role);
      setState(() => _users = users);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDeleteDialog(int id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus Pengguna', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ApiService.deleteUser(id);
                _loadUsers();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berhasil dihapus')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showUserForm([Map<String, dynamic>? user]) {
    final isEdit = user != null;
    final nameCtrl = TextEditingController(text: user?['name']);
    final usernameCtrl = TextEditingController(text: user?['username']);
    final passCtrl = TextEditingController();
    String role = user?['role'] ?? 'kasir';
    String status = user?['status'] ?? 'aktif';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24, right: 24, top: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(isEdit ? 'Edit Pengguna' : 'Tambah Pengguna', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Nama Lengkap')),
                  SizedBox(height: 12),
                  TextField(controller: usernameCtrl, decoration: InputDecoration(labelText: 'Username')),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: InputDecoration(labelText: 'Role'),
                    items: ['admin', 'manager', 'kasir'].map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase()))).toList(),
                    onChanged: (v) => setModalState(() => role = v!),
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: InputDecoration(labelText: 'Status'),
                    items: ['aktif', 'nonaktif'].map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
                    onChanged: (v) => setModalState(() => status = v!),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: passCtrl, 
                    obscureText: true, 
                    decoration: InputDecoration(
                      labelText: isEdit ? 'Password (kosongkan jika tidak diubah)' : 'Password',
                    )
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final data = {
                          'name': nameCtrl.text,
                          'username': usernameCtrl.text,
                          'role': role,
                          'status': status,
                        };
                        if (passCtrl.text.isNotEmpty) data['password'] = passCtrl.text;
                        
                        if (isEdit) {
                          await ApiService.updateUser(user['id'], data);
                        } else {
                          await ApiService.createUser(data);
                        }
                        Navigator.pop(ctx);
                        _loadUsers();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
                    child: Text('Simpan'),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari nama/username...',
                    prefixIcon: Icon(Icons.search, size: 20),
                  ),
                  onChanged: (v) {
                    _search = v;
                    _loadUsers();
                  },
                ),
              ),
              SizedBox(width: 12),
              Container(
                width: 120,
                child: DropdownButtonFormField<String>(
                  value: _role,
                  decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                  items: ['semua', 'admin', 'manager', 'kasir']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase(), style: TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (v) {
                    setState(() => _role = v!);
                    _loadUsers();
                  },
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: _isLoading 
            ? Center(child: CircularProgressIndicator())
            : ListView.separated(
                itemCount: _users.length,
                separatorBuilder: (c, i) => Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final u = _users[i];
                  final date = DateTime.parse(u['created_at']);
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.bgPage,
                      child: Icon(Icons.person, color: AppTheme.textSecondary),
                    ),
                    title: Row(
                      children: [
                        Expanded(child: Text(u['name'], style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                        _buildRoleBadge(u['role']),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text('@${u['username']}', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                        SizedBox(height: 4),
                        Text(
                          '${u['status'].toString().toUpperCase()} • ${DateFormat('dd MMM yyyy').format(date)}',
                          style: TextStyle(
                            fontSize: 11, 
                            color: u['status'] == 'aktif' ? AppTheme.success : AppTheme.danger
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, size: 20),
                          onPressed: () => _showUserForm(u),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, size: 20, color: Colors.red[300]),
                          onPressed: () => _showDeleteDialog(u['id'], u['name']),
                        ),
                      ],
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }

  Widget _buildRoleBadge(String role) {
    Color bg = Colors.transparent;
    Color text = AppTheme.textSecondary;
    if (role == 'admin') { bg = AppTheme.badgeAdmin; text = AppTheme.badgeAdminText; }
    else if (role == 'manager') { bg = AppTheme.badgeManager; text = AppTheme.badgeManagerText; }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(role.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: text)),
    );
  }
}
