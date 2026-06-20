import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final int id;
  final String title;
  final String image;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'image': image,
        'price': price,
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'] as int,
        title: json['title'] as String,
        image: json['image'] as String,
        price: (json['price'] as num).toDouble(),
        quantity: json['quantity'] as int? ?? 1,
      );

  CartItem copyWith({int? quantity}) => CartItem(
        id: id,
        title: title,
        image: image,
        price: price,
        quantity: quantity ?? this.quantity,
      );
}

class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  double get totalPrice =>
      items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  int get totalItems =>
      items.fold(0, (sum, item) => sum + item.quantity);

  bool containsProduct(int productId) =>
      items.any((item) => item.id == productId);

  CartState copyWith({List<CartItem>? items}) =>
      CartState(items: items ?? this.items);
}

class CartCubit extends Cubit<CartState> {
  static const _cartKey = 'cart_items';

  CartCubit() : super(const CartState()) {
    _loadCart();
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);
    if (cartJson != null) {
      final List<dynamic> decoded = jsonDecode(cartJson);
      final items = decoded
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList();
      emit(CartState(items: items));
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = jsonEncode(state.items.map((e) => e.toJson()).toList());
    await prefs.setString(_cartKey, cartJson);
  }

  void addToCart(Map<String, dynamic> product) {
    final id = int.parse(product['id'].toString());
    final existingIndex = state.items.indexWhere((item) => item.id == id);

    final updatedItems = List<CartItem>.from(state.items);

    if (existingIndex >= 0) {
      // Increase quantity if already in cart
      final existing = updatedItems[existingIndex];
      updatedItems[existingIndex] =
          existing.copyWith(quantity: existing.quantity + 1);
    } else {
      updatedItems.add(CartItem(
        id: id,
        title: product['title']?.toString() ?? 'No title',
        image: product['image']?.toString() ?? '',
        price: double.tryParse(product['price'].toString()) ?? 0,
      ));
    }

    emit(state.copyWith(items: updatedItems));
    _saveCart();
  }

  void removeFromCart(int productId) {
    final updatedItems =
        state.items.where((item) => item.id != productId).toList();
    emit(state.copyWith(items: updatedItems));
    _saveCart();
  }

  void incrementQuantity(int productId) {
    final updatedItems = state.items.map((item) {
      if (item.id == productId) {
        return item.copyWith(quantity: item.quantity + 1);
      }
      return item;
    }).toList();
    emit(state.copyWith(items: updatedItems));
    _saveCart();
  }

  void decrementQuantity(int productId) {
    final updatedItems = <CartItem>[];
    for (final item in state.items) {
      if (item.id == productId) {
        if (item.quantity > 1) {
          updatedItems.add(item.copyWith(quantity: item.quantity - 1));
        }
        // If quantity is 1, skip it (remove from cart)
      } else {
        updatedItems.add(item);
      }
    }
    emit(state.copyWith(items: updatedItems));
    _saveCart();
  }

  void clearCart() {
    emit(const CartState());
    _saveCart();
  }
}
