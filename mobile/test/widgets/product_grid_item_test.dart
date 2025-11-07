import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tote_bag/widgets/product_grid_item.dart';
import 'package:tote_bag/models/product.dart';

void main() {
  group('ProductGridItem', () {
    testWidgets('should display product name', (WidgetTester tester) async {
      final product = Product(
        id: '1',
        barcode: '123456',
        name: 'Test Product',
        source: 'openfoodfacts',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductGridItem(
              product: product,
              isInList: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Product'), findsOneWidget);
    });

    testWidgets('should display product brand when available',
        (WidgetTester tester) async {
      final product = Product(
        id: '1',
        barcode: '123456',
        name: 'Test Product',
        brand: 'Test Brand',
        source: 'openfoodfacts',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductGridItem(
              product: product,
              isInList: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('Test Brand'), findsOneWidget);
    });

    testWidgets('should display product image when available',
        (WidgetTester tester) async {
      final product = Product(
        id: '1',
        barcode: '123456',
        name: 'Test Product',
        imageUrl: 'https://example.com/image.jpg',
        source: 'openfoodfacts',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductGridItem(
              product: product,
              isInList: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should display placeholder icon when no image',
        (WidgetTester tester) async {
      final product = Product(
        id: '1',
        barcode: '123456',
        name: 'Test Product',
        imageUrl: null,
        source: 'openfoodfacts',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductGridItem(
              product: product,
              isInList: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.shopping_basket), findsOneWidget);
    });

    testWidgets('should show star icon for favorite products',
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

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductGridItem(
              product: product,
              isInList: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('should not show star icon for non-favorite products',
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

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductGridItem(
              product: product,
              isInList: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsNothing);
    });

    testWidgets('should apply strikethrough when product is in list',
        (WidgetTester tester) async {
      final product = Product(
        id: '1',
        barcode: '123456',
        name: 'Test Product',
        source: 'openfoodfacts',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductGridItem(
              product: product,
              isInList: true,
              onTap: () {},
            ),
          ),
        ),
      );

      // Find the Text widget with the product name
      final textWidget = tester.widget<Text>(find.text('Test Product'));
      expect(textWidget.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      final product = Product(
        id: '1',
        barcode: '123456',
        name: 'Test Product',
        source: 'openfoodfacts',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductGridItem(
              product: product,
              isInList: false,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ProductGridItem));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('should have different visual style when in list',
        (WidgetTester tester) async {
      final product = Product(
        id: '1',
        barcode: '123456',
        name: 'Test Product',
        source: 'openfoodfacts',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Test when not in list
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductGridItem(
              product: product,
              isInList: false,
              onTap: () {},
            ),
          ),
        ),
      );

      final cardNotInList = tester.widget<Card>(find.byType(Card));
      expect(cardNotInList.elevation, 2);

      // Test when in list
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductGridItem(
              product: product,
              isInList: true,
              onTap: () {},
            ),
          ),
        ),
      );

      final cardInList = tester.widget<Card>(find.byType(Card));
      expect(cardInList.elevation, 1);
    });
  });
}
