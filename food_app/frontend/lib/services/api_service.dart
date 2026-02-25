import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:4000/api';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Map<String, String> _headers({String? token}) {
    final h = {'Content-Type': 'application/json'};
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  // ─── AUTH ──────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers(),
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getMe() async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: _headers(token: token),
    );
    return jsonDecode(res.body);
  }

  // ─── CATEGORIES ──────────────────────────────────────────────────
  static Future<List<dynamic>> getCategories() async {
    final res = await http.get(Uri.parse('$baseUrl/categories'));
    final body = jsonDecode(res.body);
    return body['data'] ?? [];
  }

  // ─── RESTAURANTS ─────────────────────────────────────────────────
  static Future<List<dynamic>> getRestaurants({bool? featured, int? categoryId, String? search}) async {
    final params = <String, String>{};
    if (featured == true) params['featured'] = 'true';
    if (categoryId != null) params['category'] = categoryId.toString();
    if (search != null && search.isNotEmpty) params['search'] = search;

    final uri = Uri.parse('$baseUrl/restaurants').replace(queryParameters: params.isNotEmpty ? params : null);
    final res = await http.get(uri);
    final body = jsonDecode(res.body);
    return body['data'] ?? [];
  }

  static Future<Map<String, dynamic>> getRestaurantById(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/restaurants/$id'));
    final body = jsonDecode(res.body);
    return body['data'] ?? {};
  }

  // ─── MENU ────────────────────────────────────────────────────────
  static Future<List<dynamic>> getMenuItems(int restaurantId) async {
    final res = await http.get(Uri.parse('$baseUrl/menu/$restaurantId'));
    final body = jsonDecode(res.body);
    return body['data'] ?? [];
  }

  // ─── CART ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getCart() async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse('$baseUrl/cart'),
      headers: _headers(token: token),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> addToCart(int menuItemId, {int quantity = 1}) async {
    final token = await _getToken();
    final res = await http.post(
      Uri.parse('$baseUrl/cart'),
      headers: _headers(token: token),
      body: jsonEncode({'menuItemId': menuItemId, 'quantity': quantity}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateCartItem(int cartItemId, int quantity) async {
    final token = await _getToken();
    final res = await http.put(
      Uri.parse('$baseUrl/cart/$cartItemId'),
      headers: _headers(token: token),
      body: jsonEncode({'quantity': quantity}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> removeCartItem(int cartItemId) async {
    final token = await _getToken();
    final res = await http.delete(
      Uri.parse('$baseUrl/cart/$cartItemId'),
      headers: _headers(token: token),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> clearCart() async {
    final token = await _getToken();
    final res = await http.delete(
      Uri.parse('$baseUrl/cart/clear'),
      headers: _headers(token: token),
    );
    return jsonDecode(res.body);
  }

  // ─── ORDERS ──────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> placeOrder({String deliveryAddress = ''}) async {
    final token = await _getToken();
    final res = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: _headers(token: token),
      body: jsonEncode({'deliveryAddress': deliveryAddress}),
    );
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getOrders() async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse('$baseUrl/orders'),
      headers: _headers(token: token),
    );
    final body = jsonDecode(res.body);
    return body['data'] ?? [];
  }
}
