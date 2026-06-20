import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopease/core/global.dart';
import 'package:shopease/features/cart/cubit/cart_cubit.dart';
import 'package:shopease/features/product/bloc/product_bloc.dart';

class Productdetailedscreen extends StatelessWidget {
  final String productname;
  const Productdetailedscreen({super.key, required this.productname});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<ProductBloc>().add(fetchProductEvent());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            productname,
            style: customisedStyle(
              colorScheme.onSurface,
              FontWeight.w600,
              12.0,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.read<ProductBloc>().add(fetchProductEvent());
              Navigator.pop(context);
            },
          ),
        ),
        body: BlocBuilder<ProductBloc, ProductBlocState>(
          builder: (context, state) {
            if (state is ProductBlocLoadingTrue) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProductBlocError) {
              return Center(child: Text(state.msg));
            } else if (state is ProductBlocByid) {
              final product = state.productsbyid.first;
              print("product $product");

              final image = product['image']?.toString() ?? '';
              final title = product['title']?.toString() ?? 'No title';
              final price = product['price']?.toString() ?? '-';
              final category = product['category']?.toString() ?? '-';
              final rating = product['rating']['rate']?.toString() ?? '-';
              final description =
                  product['description']?.toString() ?? 'No description';

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: image.isEmpty
                                ? const Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 100,
                                  )
                                : Image.network(
                                    image,
                                    height: 200,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.broken_image_outlined,
                                      size: 100,
                                    ),
                                  ),
                          ),
                          SizedBox(height: screenSize.height * 0.02),
                          Text(
                            title,
                            style: customisedStyle(
                              colorScheme.onSurface,
                              FontWeight.bold,
                              20.0,
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '\$$price',
                                    style: customisedStyle(
                                      colorScheme.primary,
                                      FontWeight.w600,
                                      18.0,
                                    ),
                                  ),
                                  SizedBox(width: screenSize.width * 0.02),
                                  Text(
                                    '\$$rating',
                                    style: customisedStyle(
                                      Colors.red,
                                      FontWeight.w600,
                                      16.0,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                category,
                                style: customisedStyle(
                                  Colors.grey.shade400,
                                  FontWeight.w500,
                                  14.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            description,
                            style: customisedStyle(
                              colorScheme.primary,
                              FontWeight.w600,
                              12.0,
                            ),
                          ),
                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            child: BlocBuilder<CartCubit, CartState>(
                              builder: (context, cartState) {
                                final isInCart = cartState.containsProduct(
                                  int.parse(product['id'].toString()),
                                );
                                return FilledButton.icon(
                                  onPressed: () {
                                    context.read<CartCubit>().addToCart(
                                      product,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isInCart
                                              ? 'Added one more to cart'
                                              : '$title added to cart',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    isInCart
                                        ? Icons.add_shopping_cart_rounded
                                        : Icons.shopping_cart_outlined,
                                  ),
                                  label: Text(
                                    isInCart ? 'Add One More' : 'Add to Cart',
                                    style: customisedStyle(
                                      colorScheme.onPrimary,
                                      FontWeight.w600,
                                      16.0,
                                    ),
                                  ),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
