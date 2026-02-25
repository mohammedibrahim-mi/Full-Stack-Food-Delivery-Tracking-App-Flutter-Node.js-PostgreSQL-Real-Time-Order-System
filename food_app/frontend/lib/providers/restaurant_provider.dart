import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RestaurantProvider with ChangeNotifier {
  List<dynamic> _categories = [];
  List<dynamic> _restaurants = [];
  List<dynamic> _featuredRestaurants = [];
  List<dynamic> _menuItems = [];
  Map<String, dynamic>? _selectedRestaurant;
  bool _isLoading = false;
  String _searchQuery = '';

  List<dynamic> get categories => _categories;
  List<dynamic> get restaurants => _restaurants;
  List<dynamic> get featuredRestaurants => _featuredRestaurants;
  List<dynamic> get menuItems => _menuItems;
  Map<String, dynamic>? get selectedRestaurant => _selectedRestaurant;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<dynamic> get filteredRestaurants {
    if (_searchQuery.isEmpty) return _restaurants;
    return _restaurants.where((r) {
      final name = (r['name'] ?? '').toString().toLowerCase();
      final cuisine = (r['cuisine'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase()) ||
          cuisine.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    try {
      _categories = await ApiService.getCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> loadRestaurants({int? categoryId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _restaurants = await ApiService.getRestaurants(categoryId: categoryId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading restaurants: $e');
    }
  }

  Future<void> loadFeaturedRestaurants() async {
    try {
      _featuredRestaurants = await ApiService.getRestaurants(featured: true);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading featured: $e');
    }
  }

  Future<void> loadRestaurantDetail(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      _selectedRestaurant = await ApiService.getRestaurantById(id);
      _menuItems = await ApiService.getMenuItems(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading restaurant: $e');
    }
  }

  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        ApiService.getCategories(),
        ApiService.getRestaurants(),
        ApiService.getRestaurants(featured: true),
      ]);
      _categories = results[0];
      _restaurants = results[1];
      _featuredRestaurants = results[2];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading data: $e');
    }
  }
}
