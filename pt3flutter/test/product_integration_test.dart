import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pt2flutter/data/models/product.dart';
import 'package:pt2flutter/presentation/screens/product_list_view.dart';
import 'package:pt2flutter/presentation/screens/creation_product_view.dart';
import 'package:pt2flutter/presentation/login_vm.dart';
import 'package:provider/provider.dart';
import 'test_helpers.dart';

void main() {
  late MockProductService mockProductService;
  late MockAuthenticationService mockAuthService;

  setUpAll(() {
    registerFallbackValue(testProduct);
  });

  setUp(() {
    mockProductService = MockProductService();
    mockAuthService = MockAuthenticationService();
  });

  group('Product Management Integration Tests', () {
    testWidgets('Product List displays mocked products (Unívoca)', (
      tester,
    ) async {
      // Setup mock to return a specific list
      final products = [
        testProduct,
        testProduct.copyWith(id: 2, title: 'Another Product'),
      ];
      when(
        () => mockProductService.getProducts(any()),
      ).thenAnswer((_) async => products);

      // Pump app with a logged in user in the VM
      await tester.pumpApp(
        child: const ProductListView(),
        productService: mockProductService,
        authService: mockAuthService,
      );

      // We need to simulate being logged in so fetchProducts works
      final loginVm = tester
          .element(find.byType(ProductListView))
          .read<LoginViewModel>();
      // Use a hacky way to set the user or just mock the repository and log in
      when(
        () => mockAuthService.validateLogin(any(), any()),
      ).thenAnswer((_) async => testUser);
      await loginVm.login();

      // Trigger fetch (it's called in initState but needs token)
      await tester.pumpAndSettle();

      // Verify Product 1 and 2 common description
      expect(find.textContaining('Test Description'), findsNWidgets(2));
      expect(find.textContaining('\$99.99'), findsNWidgets(2));

      // Verify Unívoca titles
      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('Another Product'), findsOneWidget);
    });

    testWidgets('Create Product sends data and shows success message', (
      tester,
    ) async {
      when(
        () => mockProductService.createProduct(any(), any()),
      ).thenAnswer((_) async => testProduct);

      await tester.pumpApp(
        child: const CreationProductView(),
        productService: mockProductService,
        authService: mockAuthService,
      );

      // Set logged in user
      final loginVm = tester
          .element(find.byType(CreationProductView))
          .read<LoginViewModel>();
      when(
        () => mockAuthService.validateLogin(any(), any()),
      ).thenAnswer((_) async => testUser);
      await loginVm.login();
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Product Title'),
        'New Gadget',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Price'),
        '49.99',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Description'),
        'Cool gadget description',
      );

      // Submit
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Product'));
      await tester.pumpAndSettle();

      // Verify Success Message (Unívoca)
      expect(find.text('Product created successfully!'), findsOneWidget);

      // Verify Service call (Integration check)
      verify(
        () => mockProductService.createProduct(
          any(
            that: isA<Product>()
                .having((p) => p.title, 'title', 'New Gadget')
                .having((p) => p.price, 'price', 49.99),
          ),
          any(),
        ),
      ).called(1);
    });
    testWidgets('Product List error shows message (Unívoca)', (tester) async {
      when(
        () => mockProductService.getProducts(any()),
      ).thenThrow(Exception('Error loading products'));

      await tester.pumpApp(
        child: const ProductListView(),
        productService: mockProductService,
        authService: mockAuthService,
      );

      final loginVm = tester
          .element(find.byType(ProductListView))
          .read<LoginViewModel>();
      when(
        () => mockAuthService.validateLogin(any(), any()),
      ).thenAnswer((_) async => testUser);
      await loginVm.login();
      await tester.pumpAndSettle();

      expect(find.text('Error loading products'), findsOneWidget);
    });

    testWidgets('Create Product failure shows error message', (tester) async {
      when(
        () => mockProductService.createProduct(any(), any()),
      ).thenThrow(Exception('Error creating product'));

      await tester.pumpApp(
        child: const CreationProductView(),
        productService: mockProductService,
        authService: mockAuthService,
      );

      final loginVm = tester
          .element(find.byType(CreationProductView))
          .read<LoginViewModel>();
      when(
        () => mockAuthService.validateLogin(any(), any()),
      ).thenAnswer((_) async => testUser);
      await loginVm.login();
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Failed Product',
      );
      await tester.enterText(find.byType(TextFormField).at(1), '10');
      await tester.enterText(find.byType(TextFormField).at(2), 'Desc');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Product'));
      await tester.pumpAndSettle();

      expect(find.text('Error creating product'), findsOneWidget);
    });
  });
}

extension on Product {
  Product copyWith({int? id, String? title}) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price,
      description: description,
      userId: userId,
    );
  }
}
