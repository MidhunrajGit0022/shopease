import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopease/productBloc/product_bloc_bloc.dart';

class Productdetailedscreen extends StatelessWidget {
  final String productname;
  const Productdetailedscreen({super.key, required this.productname});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<ProductBloc>().add(fetchProductEvent());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(productname, style: TextStyle(fontSize: 12.0)),
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
                          const SizedBox(height: 16),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$$price',
                            style: TextStyle(
                              fontSize: 18,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(description),
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // addtocart();
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                        Colors.amber,
                      ),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 120,
                      ),
                      child: Text(
                        "Add to Cart",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: MediaQuery.of(context).size.width * 0.050,
                        ),
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
