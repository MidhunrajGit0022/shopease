part of 'product_bloc.dart';

sealed class ProductBlocState extends Equatable {
  const ProductBlocState();

  @override
  List<Object> get props => [];
}

final class ProductBlocInitial extends ProductBlocState {}

final class ProductBlocLoadingTrue extends ProductBlocState {}

final class ProductBlocLoadingFalse extends ProductBlocState {
  final List<Map<String, dynamic>> products;
  const ProductBlocLoadingFalse({required this.products});

  @override
  List<Object> get props => [products];
}

final class ProductBlocError extends ProductBlocState {
  final String msg;
  const ProductBlocError({this.msg = 'Something went wrong'});

  @override
  List<Object> get props => [msg];
}

final class ProductBlocByid extends ProductBlocState {
  final List<Map<String, dynamic>> productsbyid;
  const ProductBlocByid({required this.productsbyid});

  @override
  List<Object> get props => [productsbyid];
}
