import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopease/cart/cart_cubit.dart';
import 'package:shopease/presentation/pages/CartPage.dart';
import 'package:shopease/presentation/pages/productDetailedScreen.dart';
import 'package:shopease/productBloc/product_bloc_bloc.dart';
import 'package:shopease/theme/theme_cubit.dart';

class Productspage extends StatelessWidget {
  Productspage({super.key});
  late TextEditingController _searchController;
  List<dynamic> items = [];
  List<dynamic> filteredItems = [];

  //   void searchItems(String query) {
  //   if (query == "") {
  //     fetchData();
  //   } else {
  //     setState(() {
  //       items = items
  //           .where((item) =>
  //               item["title"].toLowerCase().contains(query.toLowerCase()))
  //           .toList();
  //     });
  //   }
  // }

  // @override
  // void dispose() {
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('ShopEase'),
            GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SizedBox(
                width: screenSize.width * 1.0,
                child: TextField(
                  // controller: _searchController,
                  // onChanged: searchItems,
                  decoration: InputDecoration(
                    labelText: 'Search products...',
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    prefixIcon: Icon(
                      Icons.search,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, cartState) {
              return IconButton(
                icon: Badge(
                  isLabelVisible: cartState.totalItems > 0,
                  label: Text(
                    '${cartState.totalItems}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: colorScheme.error,
                  child: Icon(Icons.shopping_cart_outlined),
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
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              final isDark = themeMode == ThemeMode.dark;
              return IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return RotationTransition(
                      turns: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    key: ValueKey<bool>(isDark),
                  ),
                ),
                tooltip: isDark
                    ? 'Switch to Light Mode'
                    : 'Switch to Dark Mode',
                onPressed: () {
                  context.read<ThemeCubit>().toggleTheme();
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductBlocState>(
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
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No products found',
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurfaceVariant,
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
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
                itemCount: state.products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.68,
                ),
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  final image = product['image']?.toString() ?? '';
                  final title = product['title']?.toString() ?? 'No title';
                  final price = product['price']?.toString() ?? '-';

                  return GestureDetector(
                    onTap: () {
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
                            child: Productdetailedscreen(productname: title),
                          ),
                        ),
                      );
                    },
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Container(
                              color: colorScheme.surfaceContainerLow,
                              padding: const EdgeInsets.all(16),
                              child: image.isEmpty
                                  ? Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 40,
                                      color: colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.4),
                                    )
                                  : Image.network(
                                      image,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, _, _) => Icon(
                                        Icons.broken_image_outlined,
                                        size: 40,
                                        color: colorScheme.onSurfaceVariant
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                            child: Text(
                              '\$$price',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
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
                      context.read<ProductBloc>().add(fetchProductEvent());
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
    );
  }
}
