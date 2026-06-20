part of 'product_bloc.dart';

sealed class ProductBlocEvent extends Equatable {
  const ProductBlocEvent();

  @override
  List<Object> get props => [];
}

final class fetchProductEvent extends ProductBlocEvent {
  @override
  List<Object> get props => [];
}

final class fetchProductbyidEvent extends ProductBlocEvent {
  final int id;

  const fetchProductbyidEvent({required this.id});
  @override
  List<Object> get props => [id];
}
