import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopease/core/global.dart';
import 'package:shopease/features/cart/cubit/cart_cubit.dart';
import 'package:shopease/features/cart/pages/cart_page.dart';
import 'package:shopease/features/product/bloc/product_bloc.dart';
import 'package:shopease/features/product/pages/product_detail_screen.dart';

class Productspage extends StatefulWidget {
  const Productspage({super.key});

  @override
  State<Productspage> createState() => _ProductspageState();
}

class _ProductspageState extends State<Productspage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterProducts(
    List<Map<String, dynamic>> products,
  ) {
    if (_searchQuery.isEmpty) return products;
    final query = _searchQuery.toLowerCase();
    return products.where((product) {
      final title = (product['title']?.toString() ?? '').toLowerCase();
      final category = (product['category']?.toString() ?? '').toLowerCase();
      return title.contains(query) || category.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'ShopEase',
            style: customisedStyle(
              colorScheme.onSurface,
              FontWeight.bold,
              20.0,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocBuilder<CartCubit, CartState>(
                builder: (context, cartState) {
                  return IconButton(
                    icon: Badge(
                      isLabelVisible: cartState.totalItems > 0,
                      label: Text(
                        '${cartState.totalItems}',
                        style: customisedStyle(
                          colorScheme.onError,
                          FontWeight.bold,
                          10.0,
                        ),
                      ),
                      backgroundColor: colorScheme.error,
                      child: const Icon(Icons.shopping_cart_outlined),
                    ),
                    tooltip: 'Cart',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartPage()),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: SizedBox(
                  width: screenSize.width * 1.0,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (query) {
                      setState(() {
                        _searchQuery = query;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search products...',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      prefixIcon: const Icon(Icons.search, size: 24),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                                FocusScope.of(context).unfocus();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<ProductBloc, ProductBlocState>(
                  builder: (context, state) {
                    if (state is ProductBlocLoadingTrue) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ProductBlocLoadingFalse) {
                      if (state.products.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No products found',
                                style: customisedStyle(
                                  colorScheme.onSurfaceVariant,
                                  FontWeight.w600,
                                  16.0,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final filteredProducts = _filterProducts(state.products);

                      if (filteredProducts.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 64,
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No results for "$_searchQuery"',
                                style: customisedStyle(
                                  colorScheme.onSurfaceVariant,
                                  FontWeight.w600,
                                  16.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try a different search term',
                                style: customisedStyle(
                                  colorScheme.onSurfaceVariant,
                                  FontWeight.w600,
                                  13.0,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        color: colorScheme.primary,
                        onRefresh: () async {
                          context.read<ProductBloc>().add(fetchProductEvent());
                          await context.read<ProductBloc>().stream.firstWhere(
                            (state) => state is! ProductBlocLoadingTrue,
                          );
                        },
                        child: GridView.builder(
                          itemCount: filteredProducts.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 8.0,
                                crossAxisSpacing: 8.0,
                                childAspectRatio: 0.8,
                              ),
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            final image = product['image']?.toString() ?? '';
                            final title =
                                product['title']?.toString() ?? 'No title';
                            final price = product['price']?.toString() ?? '-';
                            final rating =
                                product['rating']['rate']?.toString() ?? '-';

                            return GestureDetector(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                context.read<ProductBloc>().add(
                                  fetchProductbyidEvent(
                                    id: int.parse(product['id'].toString()),
                                  ),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<ProductBloc>(),
                                      child: Productdetailedscreen(
                                        productname: title,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        color: colorScheme.surfaceContainerLow,
                                        padding: const EdgeInsets.all(16),
                                        child: image.isEmpty
                                            ? Icon(
                                                Icons
                                                    .image_not_supported_outlined,
                                                size: 40,
                                                color: colorScheme
                                                    .onSurfaceVariant
                                                    .withValues(alpha: 0.4),
                                              )
                                            : Image.network(
                                                image,
                                                fit: BoxFit.contain,
                                                errorBuilder: (_, _, _) => Icon(
                                                  Icons.broken_image_outlined,
                                                  size: 40,
                                                  color: colorScheme
                                                      .onSurfaceVariant
                                                      .withValues(alpha: 0.4),
                                                ),
                                              ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        12,
                                        10,
                                        12,
                                        4,
                                      ),
                                      child: Text(
                                        title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: customisedStyle(
                                          colorScheme.onSurface,
                                          FontWeight.w500,
                                          12.0,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        12,
                                        0,
                                        12,
                                        10,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            '\$$price',
                                            style: customisedStyle(
                                              colorScheme.primary,
                                              FontWeight.bold,
                                              14.0,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '\$$rating',
                                            style: customisedStyle(
                                              Colors.red,
                                              FontWeight.w600,
                                              12.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    } else if (state is ProductBlocError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 64,
                              color: colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.msg,
                              style: TextStyle(color: colorScheme.error),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                context.read<ProductBloc>().add(
                                  fetchProductEvent(),
                                );
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
