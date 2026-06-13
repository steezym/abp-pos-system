import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'package:pos_mobile/models/DetailTransaction.dart';
import 'package:pos_mobile/models/Transaction.dart';

class ApiService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr == null) return null;
    return jsonDecode(userStr);
  }

  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  static Map<String, String> _headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // LOGIN
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: _headers(),
      body: jsonEncode({'username': username, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return data;
    throw data['message'] ?? 'Login gagal';
  }

  // LOGOUT
  static Future<void> logout() async {
    final token = await getToken();
    await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: _headers(token: token),
    );
    await clearAuth();
  }

  // GET USERS
  static Future<List<dynamic>> getUsers({String? search, String? role}) async {
    final token = await getToken();
    var url = '$baseUrl/users';
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (role != null && role != 'semua') params['role'] = role;
    if (params.isNotEmpty) {
      url += '?' + params.entries.map((e) => '${e.key}=${e.value}').join('&');
    }
    final res = await http.get(Uri.parse(url), headers: _headers(token: token));

    if (res.statusCode == 401) {
      await clearAuth();
      throw 'Sesi Anda telah berakhir. Silakan login kembali.';
    }

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['data']['users'] ?? [];
    }

    throw 'Gagal memuat pengguna (Error ${res.statusCode})';
  }

  // CREATE USER
  static Future<void> createUser(Map<String, dynamic> userData) async {
    final token = await getToken();
    final res = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: _headers(token: token),
      body: jsonEncode(userData),
    );
    if (res.statusCode == 401) {
      await clearAuth();
      throw 'Sesi Anda telah berakhir. Silakan login kembali.';
    }
    if (res.statusCode != 201) {
      final data = jsonDecode(res.body);
      throw data['message'] ?? 'Gagal membuat pengguna';
    }
  }

  // UPDATE USER
  static Future<void> updateUser(int id, Map<String, dynamic> userData) async {
    final token = await getToken();
    final res = await http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: _headers(token: token),
      body: jsonEncode(userData),
    );
    if (res.statusCode == 401) {
      await clearAuth();
      throw 'Sesi Anda telah berakhir. Silakan login kembali.';
    }
    if (res.statusCode != 200) {
      final data = jsonDecode(res.body);
      throw data['message'] ?? 'Gagal memperbarui pengguna';
    }
  }

  // DELETE USER
  static Future<void> deleteUser(int id) async {
    final token = await getToken();
    final res = await http.delete(
      Uri.parse('$baseUrl/users/$id'),
      headers: _headers(token: token),
    );
    if (res.statusCode == 401) {
      await clearAuth();
      throw 'Sesi Anda telah berakhir. Silakan login kembali.';
    }
    if (res.statusCode != 200) throw 'Gagal menghapus pengguna';
  }

  // GET USER BY ID
  static Future<Map<String, dynamic>> getUserById(int id) async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('$baseUrl/users/$id'),
      headers: _headers(token: token),
    );
    if (res.statusCode == 401) {
      await clearAuth();
      throw 'Sesi Anda telah berakhir. Silakan login kembali.';
    }
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['data'];
    }
    throw 'Gagal memuat data pengguna';
  }

  static Future<List<dynamic>> getProducts() async {
    final token = await getToken();

    final res = await http.get(
      Uri.parse('$baseUrl/product'),
      headers: _headers(token: token),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      return data['list'] ?? [];
    }

    throw 'Gagal memuat produk';
  }

  static Future<void> checkout(List items, String paymentMethod) async {
    final token = await getToken();

    final res = await http.post(
      Uri.parse('$baseUrl/mobile-checkout'),
      headers: _headers(token: token),
      body: jsonEncode({'items': items, 'payment_method': paymentMethod}),
    );

    print('STATUS = ${res.statusCode}');
    print('BODY = ${res.body}');

    if (res.statusCode != 200) {
      throw Exception(res.body);
    }
  }

  // GET TRANSACTIONS
  static Future<List<dynamic>> getTransactions() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('$baseUrl/transaction'),
      headers: _headers(token: token),
    );

    if (res.statusCode == 401) {
      await clearAuth();
      throw 'Sesi Anda telah berakhir. Silakan login kembali.';
    }

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      final data = json['data'];
      
      if (data is Map) {
        return data['transactions'] ?? [];
      } else if (data is List) {
        return data;
      }
      return json['list'] ?? [];
    }

    throw 'Gagal memuat riwayat transaksi';
  }

  // GET AI RECOMMENDATIONS
  static Future<List<dynamic>> getAIRecommendations() async {
    final token = await getToken();
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/transaction/bundling/insights'),
        headers: _headers(token: token),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['data'] ?? [];
      }
    } catch (e) {
      print('AI Recommendation Error: $e');
    }
    return [];
  }

  // TRANSACTION NEW SERVICE
  // GET TRANSASCTIONS
  static Future<List<Transaction>> getTransactions2({String? search, String? start, String? end}) async {
    final token = await getToken();
    var url = '$baseUrl/transaction';
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (start != null && start.isNotEmpty) params['start'] = start;
    if (end != null && end.isNotEmpty) params['end'] = end;
    if (params.isNotEmpty) {
      url += '?' + params.entries.map((e) => '${e.key}=${e.value}').join('&');
    }
    final res = await http.get(Uri.parse(url), headers: _headers(token: token));
    print("hello ${url}");
    if (res.statusCode == 401) {
      await clearAuth();
      throw 'Sesi Anda telah berakhir. Silakan login kembali.';
    }
    print(res.body);

    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      var parsed = data["data"]["transactions"].cast<Map<String, dynamic>>();
      return parsed.map<Transaction>((item)=>Transaction.fromJson(item)).toList();
    }

    throw 'Gagal memuat transaksi (Error ${res.statusCode})';
  }

  // GET TRANSACTION DETAILS
  static Future<DetailTransaction> getTransactionDetails({String? id}) async {
    final token = await getToken();
    var url = '$baseUrl/transaction/${id}';

    final res = await http.get(Uri.parse(url), headers: _headers(token: token));

    if (res.statusCode == 401) {
      await clearAuth();
      throw 'Sesi Anda telah berakhir. Silakan login kembali.';
    }

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return DetailTransaction.fromJson(data["data"][0]);
    }

    throw 'Gagal memuat transaksi (Error ${res.statusCode})';
  }
}
