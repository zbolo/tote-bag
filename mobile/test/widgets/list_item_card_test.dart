import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tote_bag/widgets/list_item_card.dart';
import 'package:tote_bag/models/shopping_list_item.dart';
import 'package:tote_bag/models/product.dart';
import 'package:tote_bag/providers/providers.dart';
import 'package:tote_bag/services/shopping_list_service.dart';
import 'package:tote_bag/services/favorite_service.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([ShoppingListService, FavoriteService])
import 'list_item_card_test.mocks.dart';

void main() {
  late MockShoppingListService mockShoppingListService;
  late MockFavoriteService mockFavoriteService;

  setUp(() {
    mockShoppingListService = MockShoppingListService();
    mockFavoriteService = MockFavoriteService();
  });

  Widget createTestWidget({
    required ShoppingListItem item,
    required String listId,
  }) {
    return ProviderScope(
      overrides: [
        shoppingListServiceProvider.overrideWithValue(mockShoppingListService),
        favoriteServiceProvider.overrideWithValue(mockFavoriteService),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: ListItemCard(
            item: item,
            listId: listId,
            onRefresh: () {},
          ),
        ),
      ),
    );
  }

  group('ListItemCard - Favorite functionality', () {
    testWidgets('should display star icon when product is favorited',
        (WidgetTester tester) async {
      final product = Product(
        id: '1',
        barcode: '123456',
        name: 'Test Product',
        source: 'openfoodfacts',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: true,
      );

      final item = ShoppingListItem(
        id: '1',
        name: 'Test Item',
        quantity: 1,
        unit: 'pcs',
        isChecked: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        product: product,
      );

      await tester.pumpWidget(createTestWidget(item: item, listId: 'list1'));

      // Should show filled star icon
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsNothing);
    });

    testWidgets('should display star border icon when product is not favorited',
        (WidgetTester tester) async {
      final product = Product(
        id: '1',
        barcode: '123456',
        name: 'Test Product',
        source: 'openfoodfacts',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: false,
      );

      final item = ShoppingListItem(
        id: '1',
        name: 'Test Item',
        quantity: 1,
        unit: 'pcs',
        isChecked: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        product: product,
      );

      await tester.pumpWidget(createTestWidget(item: item, listId: 'list1'));

      // Should show outlined star icon
      expect(find.byIcon(Icons.star_border), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNothing);
    });

    testWidgets('should not display star icon when item has no product',
        (WidgetTester tester) async {
      final item = ShoppingListItem(
        id: '1',
        name: 'Test Item',
        quantity: 1,
        unit: 'pcs',
        isChecked: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        product: null,
      );

      await tester.pumpWidget(createTestWidget(item: item, listId: 'list1'));

      // Should not show any star icon
      expect(find.byIcon(Icons.star), findsNothing);
      expect(find.byIcon(Icons.star_border), findsNothing);
    });

    testWidgets('should not display product image in list view',
        (WidgetTester tester) async {
      final product = Product(
        id: '1',
        barcode: '123456',
        name: 'Test Product',
        imageUrl: 'https://example.com/image.jpg',
        source: 'openfoodfacts',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: false,
      );

      final item = ShoppingListItem(
        id: '1',
        name: 'Test Item',
        quantity: 1,
        unit: 'pcs',
        isChecked: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        product: product,
      );

      await tester.pumpWidget(createTestWidget(item: item, listId: 'list1'));

      // Product images are only shown in grid view, not in list view
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('should show item details correctly',
        (WidgetTester tester) async {
      final product = Product(
        id: '1',
        barcode: '123456',
        name: 'Test Product',
        brand: 'Test Brand',
        category: 'Food',
        source: 'openfoodfacts',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: false,
      );

      final item = ShoppingListItem(
        id: '1',
        name: 'Test Item',
        quantity: 2,
        unit: 'pcs',
        category: 'Food',
        notes: 'Test notes',
        isChecked: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        product: product,
      );

      await tester.pumpWidget(createTestWidget(item: item, listId: 'list1'));

      // Should display item name
      expect(find.text('Test Item'), findsOneWidget);

      // Should display quantity
      expect(find.text('2 pcs'), findsOneWidget);

      // Should display category
      expect(find.text('Food'), findsOneWidget);

      // Should display notes
      expect(find.text('Test notes'), findsOneWidget);
    });

    testWidgets('should show checkbox', (WidgetTester tester) async {
      final item = ShoppingListItem(
        id: '1',
        name: 'Test Item',
        quantity: 1,
        unit: 'pcs',
        isChecked: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(item: item, listId: 'list1'));

      // Should show checkbox
      expect(find.byType(Checkbox), findsOneWidget);
    });
  });
}
