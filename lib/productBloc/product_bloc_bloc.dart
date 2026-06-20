import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:shopease/core/global.dart';

part 'product_bloc_event.dart';
part 'product_bloc_state.dart';

class ProductBloc extends Bloc<ProductBlocEvent, ProductBlocState> {
  ProductBloc() : super(ProductBlocInitial()) {
    on<fetchProductEvent>(fetchProductList);
    on<fetchProductbyidEvent>(fetchProductById);
  }

  Future<void> fetchProductList(
    fetchProductEvent event,
    Emitter<ProductBlocState> emit,
  ) async {
    try {
      emit(ProductBlocLoadingTrue());
      const String url = '$baseUrl/products';
      pr("products url $url");
      final response = await http.get(Uri.parse(url));
      pr("products response ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final List<Map<String, dynamic>> products = jsonData
            .map((item) => item as Map<String, dynamic>)
            .toList();
        emit(ProductBlocLoadingFalse(products: products));
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      emit(ProductBlocError(msg: e.toString()));
    }
  }

  Future<void> fetchProductById(
    fetchProductbyidEvent event,
    Emitter<ProductBlocState> emit,
  ) async {
    try {
      emit(ProductBlocLoadingTrue());
      final String url = '$baseUrl/products/${event.id}';
      pr("product by id url $url");
      final response = await http.get(Uri.parse(url));
      pr("product by id response ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<Map<String, dynamic>> productsbyid = [jsonData];
        emit(ProductBlocByid(productsbyid: productsbyid));
      } else {
        throw Exception('Failed to load product');
      }
    } catch (e) {
      emit(ProductBlocError(msg: e.toString()));
    }
  }
}
