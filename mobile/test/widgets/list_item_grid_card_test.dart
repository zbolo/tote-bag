import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tote_bag/widgets/list_item_grid_card.dart';
import 'package:tote_bag/models/shopping_list_item.dart';
import 'package:tote_bag/models/product.dart';
import 'package:tote_bag/providers/providers.dart';
import 'package:tote_bag/services/shopping_list_service.dart';
import 'package:tote_bag/services/favorite_service.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([ShoppingListService, FavoriteService])
import 'list_item_grid_card_test.mocks.dart';

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
          body: SizedBox(
            width: 150,
            height: 200,
            child: ListItemGridCard(
              item: item,
              listId: listId,
              onRefresh: () {},
            ),
          ),
        ),
      ),
    );
  }

  group('ListItemGridCard', () {
    testWidgets('should display item name', (WidgetTester tester) async {
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

      expect(find.text('Test Item'), findsOneWidget);
    });

    testWidgets('should display quantity', (WidgetTester tester) async {
      final item = ShoppingListItem(
        id: '1',
        name: 'Test Item',
        quantity: 3,
        unit: 'kg',
        isChecked: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(item: item, listId: 'list1'));

      expect(find.text('3 kg'), findsOneWidget);
    });

    testWidgets('should display category badge when available',
        (WidgetTester tester) async {
      final item = ShoppingListItem(
        id: '1',
        name: 'Test Item',
        quantity: 1,
        unit: 'pcs',
        category: 'Dairy',
        isChecked: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(item: item, listId: 'list1'));

      expect(find.text('Dairy'), findsOneWidget);
    });

    testWidgets('should show check overlay when item is checked',
        (WidgetTester tester) async {
      final item = ShoppingListItem(
        id: '1',
        name: 'Test Item',
        quantity: 1,
        unit: 'pcs',
        isChecked: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(item: item, listId: 'list1'));

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should not show check overlay when item is unchecked',
        (WidgetTester tester) async {
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

      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('should show filled star for favorite product',
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

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsNothing);
    });

    testWidgets('should show outlined star for non-favorite product',
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

      expect(find.byIcon(Icons.star_border), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNothing);
    });

    testWidgets('should not show star when no product',
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

      expect(find.byIcon(Icons.star), findsNothing);
      expect(find.byIcon(Icons.star_border), findsNothing);
    });

    testWidgets('should show placeholder when no product image',
        (WidgetTester tester) async {
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

      expect(find.byIcon(Icons.shopping_basket), findsOneWidget);
    });

    testWidgets('should show product image when available',
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

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should apply strikethrough when checked',
        (WidgetTester tester) async {
      final item = ShoppingListItem(
        id: '1',
        name: 'Test Item',
        quantity: 1,
        unit: 'pcs',
        isChecked: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(item: item, listId: 'list1'));

      final textWidget = tester.widget<Text>(find.text('Test Item'));
      expect(textWidget.style?.decoration, TextDecoration.lineThrough);
    });
  });
}
