import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CartProvider with ChangeNotifier {
  List<dynamic> _items = [];
  double _total = 0;
  bool _isLoading = false;

  List<dynamic> get items => _items;
  double get total => _total;
  bool get isLoading => _isLoading;
  int get itemCount => _items.length;

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.getCart();
      if (res['success'] == true) {
        _items = res['data']['items'] ?? [];
        _total = (res['data']['total'] ?? 0).toDouble();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading cart: $e');
    }
  }

  Future<void> addItem(int menuItemId, {int quantity = 1}) async {
    try {
      await ApiService.addToCart(menuItemId, quantity: quantity);
      await loadCart();
    } catch (e) {
      debugPrint('Error adding to cart: $e');
    }
  }

  Future<void> updateItemQuantity(int cartItemId, int quantity) async {
    try {
      if (quantity <= 0) {
        await removeItem(cartItemId);
        return;
      }
      await ApiService.updateCartItem(cartItemId, quantity);
      await loadCart();
    } catch (e) {
      debugPrint('Error updating cart item: $e');
    }
  }

  Future<void> removeItem(int cartItemId) async {
    try {
      await ApiService.removeCartItem(cartItemId);
      await loadCart();
    } catch (e) {
      debugPrint('Error removing cart item: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      await ApiService.clearCart();
      _items = [];
      _total = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
    }
  }
}
