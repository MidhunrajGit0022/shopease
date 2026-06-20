import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopease/core/global.dart';
import 'package:shopease/features/cart/cubit/cart_cubit.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Cart',
          style: customisedStyle(colorScheme.onSurface, FontWeight.w600, 18.0),
        ),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state.items.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep_rounded),
                tooltip: 'Clear Cart',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(
                        'Clear Cart',
                        style: customisedStyle(
                          colorScheme.onSurface,
                          FontWeight.w600,
                          14.0,
                        ),
                      ),
                      content: Text(
                        'Are you sure you want to remove all items from your cart?',
                        style: customisedStyle(
                          colorScheme.onSurface,
                          FontWeight.w500,
                          12.0,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            'Cancel',
                            style: customisedStyle(
                              colorScheme.onSurface,
                              FontWeight.w500,
                              12.0,
                            ),
                          ),
                        ),
                        FilledButton(
                          onPressed: () {
                            context.read<CartCubit>().clearCart();
                            Navigator.pop(ctx);
                          },
                          child: Text(
                            'Clear',
                            style: customisedStyle(
                              colorScheme.onSurface,
                              FontWeight.w500,
                              12.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
            return _buildEmptyState(colorScheme);
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return _buildCartItem(context, item, colorScheme);
                  },
                ),
              ),
              _buildOrderSummary(context, state, colorScheme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 56,
              color: colorScheme.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: customisedStyle(
              colorScheme.onSurface,
              FontWeight.w600,
              20.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse products and add items to your cart',
            style: customisedStyle(
              colorScheme.onSurface,
              FontWeight.w600,
              14.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartItem item,
    ColorScheme colorScheme,
  ) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: colorScheme.onError,
          size: 28,
        ),
      ),
      onDismissed: (_) {
        context.read<CartCubit>().removeFromCart(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${item.title} removed from cart',
              style: customisedStyle(
                colorScheme.onPrimary,
                FontWeight.w500,
                12.0,
              ),
            ),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                context.read<CartCubit>().addToCart({
                  'id': item.id,
                  'title': item.title,
                  'image': item.image,
                  'price': item.price,
                });
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: item.image.isEmpty
                    ? Icon(
                        Icons.image_not_supported_outlined,
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.4,
                        ),
                      )
                    : Image.network(
                        item.image,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.broken_image_outlined,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: customisedStyle(
                        colorScheme.onSurface,
                        FontWeight.w500,
                        12.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: customisedStyle(
                        colorScheme.primary,
                        FontWeight.w500,
                        14.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _quantityButton(
                      context,
                      icon: item.quantity > 1
                          ? Icons.remove_rounded
                          : Icons.delete_outline_rounded,
                      onPressed: () {
                        context.read<CartCubit>().decrementQuantity(item.id);
                      },
                      colorScheme: colorScheme,
                      isDestructive: item.quantity <= 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: customisedStyle(
                          colorScheme.onSurface,
                          FontWeight.w600,
                          16.0,
                        ),
                      ),
                    ),
                    _quantityButton(
                      context,
                      icon: Icons.add_rounded,
                      onPressed: () {
                        context.read<CartCubit>().incrementQuantity(item.id);
                      },
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quantityButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required ColorScheme colorScheme,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: isDestructive
                ? colorScheme.error
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(
    BuildContext context,
    CartState state,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _summaryRow(
              'Subtotal (${state.totalItems} items)',
              '\$${state.totalPrice.toStringAsFixed(2)}',
              colorScheme,
            ),
            const SizedBox(height: 8),
            _summaryRow(
              'Shipping',
              state.totalPrice > 50 ? 'Free' : '\$4.99',
              colorScheme,
              valueColor: state.totalPrice > 50 ? Colors.green : null,
            ),
            Divider(
              height: 24,
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            _summaryRow(
              'Total',
              '\$${_calculateTotal(state).toStringAsFixed(2)}',
              colorScheme,
              isBold: true,
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Checkout coming soon!')),
                  );
                },
                icon: const Icon(Icons.lock_outline_rounded, size: 20),
                label: const Text(
                  'Proceed to Checkout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            if (state.totalPrice < 50 && state.totalPrice > 0) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Add \$${(50 - state.totalPrice).toStringAsFixed(2)} more for free shipping!',

                    style: customisedStyle(
                      colorScheme.primary,
                      FontWeight.w500,
                      12.0,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value,
    ColorScheme colorScheme, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,

          style: customisedStyle(
            isBold ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
            isBold ? FontWeight.bold : FontWeight.w400,
            isBold ? 17.0 : 14.0,
          ),
        ),
        Text(
          value,
          style: customisedStyle(
            isBold ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
            isBold ? FontWeight.bold : FontWeight.w400,
            isBold ? 17.0 : 14.0,
          ),
        ),
      ],
    );
  }

  double _calculateTotal(CartState state) {
    final shipping = state.totalPrice > 50 ? 0.0 : 4.99;
    return state.totalPrice + shipping;
  }
}
