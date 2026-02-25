import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OrderProvider with ChangeNotifier {
  List<dynamic> _orders = [];
  bool _isLoading = false;
  Map<String, dynamic>? _lastOrder;

  List<dynamic> get orders => _orders;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get lastOrder => _lastOrder;

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      _orders = await ApiService.getOrders();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading orders: $e');
    }
  }

  Future<bool> placeOrder({String deliveryAddress = ''}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.placeOrder(deliveryAddress: deliveryAddress);
      if (res['success'] == true) {
        _lastOrder = res['data'];
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error placing order: $e');
      return false;
    }
  }
}
