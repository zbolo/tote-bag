import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/logger.dart';
import '../pantry/pantry_list_screen.dart';
import 'home_screen.dart';

/// Bottom navigation index provider.
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class MainShellScreen extends ConsumerWidget {
  const MainShellScreen({super.key});

  static const _screens = [
    HomeScreen(),
    PantryListScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final currentUser = ref.watch(currentUserProvider);

    // Don't render if not authenticated
    if (currentUser.value == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          Log.debug('MainShell', 'Tab switched → ${index == 0 ? 'Lists' : 'Pantry'}');
          ref.read(bottomNavIndexProvider.notifier).state = index;
        },
        backgroundColor: AppTheme.surfaceColor,
        indicatorColor: AppTheme.primaryColor.withValues(alpha: 0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag, color: AppTheme.primaryColor),
            label: 'Lists',
          ),
          NavigationDestination(
            icon: Icon(Icons.kitchen_outlined),
            selectedIcon: Icon(Icons.kitchen, color: AppTheme.primaryColor),
            label: 'Pantry',
          ),
        ],
      ),
    );
  }
}
