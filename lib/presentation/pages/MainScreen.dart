import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopease/cart/cart_cubit.dart';
import 'package:shopease/presentation/pages/CartPage.dart';
import 'package:shopease/presentation/pages/Productspage.dart';
import 'package:shopease/presentation/pages/SettingsPage.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [Productspage(), const CartPage(), const SettingsPage()];

  final List<IconData> _navIcons = [
    Icons.home_rounded,
    Icons.shopping_cart_rounded,
    Icons.settings_rounded,
  ];

  final List<String> _navLabels = ['Home', 'Cart', 'Settings'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _buildFloatingBottomNav(),
    );
  }

  Widget _buildFloatingBottomNav() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(60, 0, 60, 16),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.surfaceContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(35),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: isDark ? 0.4 : 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                _navIcons.length,
                (index) => _buildNavItem(index, _navIcons[index]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final bool isSelected = _selectedIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show badge on cart icon
            if (index == 1)
              BlocBuilder<CartCubit, CartState>(
                builder: (context, cartState) {
                  return Badge(
                    isLabelVisible: cartState.totalItems > 0,
                    label: Text(
                      '${cartState.totalItems}',
                      style: TextStyle(
                        color: colorScheme.onError,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.error,
                    child: Icon(
                      icon,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  );
                },
              )
            else
              Icon(
                icon,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                size: 24,
              ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                _navLabels[index],
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
