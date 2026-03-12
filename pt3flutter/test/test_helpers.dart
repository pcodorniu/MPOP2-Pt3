import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:pt2flutter/data/repositories/login_repository.dart';
import 'package:pt2flutter/data/repositories/product_repository.dart';
import 'package:pt2flutter/presentation/login_vm.dart';
import 'package:pt2flutter/presentation/creation_product_vm.dart';
import 'package:pt2flutter/presentation/product_list_vm.dart';
import 'package:pt2flutter/data/models/product.dart';
import 'package:pt2flutter/data/models/user.dart';

import 'package:pt2flutter/data/services/authentication_services.dart';
import 'package:pt2flutter/data/services/product_services.dart';

// Mocks
class MockLoginRepository extends Mock implements ILoginRepository {}

class MockProductRepository extends Mock implements IProductRepository {}

class MockAuthenticationService extends Mock
    implements IAuthenticationService {}

class MockProductService extends Mock implements IProductService {}

/// Helper to pump the app with mocked providers or real repositories with mock services
extension PumpApp on WidgetTester {
  Future<void> pumpApp({
    required Widget child,
    ILoginRepository? loginRepository,
    IProductRepository? productRepository,
    IAuthenticationService? authService,
    IProductService? productService,
  }) async {
    // Services
    final mockAuthService = authService ?? MockAuthenticationService();
    final mockProductService = productService ?? MockProductService();

    // Repositories (Use provided ones, or real ones with mock services)
    final actualLoginRepo =
        loginRepository ??
        LoginRepository(authenticationService: mockAuthService);
    final actualProductRepo =
        productRepository ??
        ProductRepository(productService: mockProductService);

    await pumpWidget(
      MultiProvider(
        providers: [
          Provider<ILoginRepository>.value(value: actualLoginRepo),
          Provider<IProductRepository>.value(value: actualProductRepo),
          ChangeNotifierProvider(
            create: (context) =>
                LoginViewModel(loginRepository: actualLoginRepo),
          ),
          ChangeNotifierProvider(
            create: (context) =>
                CreationProductViewModel(productRepository: actualProductRepo),
          ),
          ChangeNotifierProvider(
            create: (context) =>
                ProductListViewModel(productRepository: actualProductRepo),
          ),
        ],
        child: MaterialApp(home: Scaffold(body: child)),
      ),
    );
  }
}

// Default models for tests
final testUser = User(
  username: 'test@example.com',
  authenticated: true,
  id: '1',
  email: 'test@example.com',
  accessToken: 'fake_token',
);

final testProduct = Product(
  id: 1,
  title: 'Test Product',
  price: 99.99,
  description: 'Test Description',
);
