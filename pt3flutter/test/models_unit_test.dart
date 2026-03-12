import 'package:flutter_test/flutter_test.dart';
import 'package:pt2flutter/data/models/product.dart';
import 'package:pt2flutter/data/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('User.fromJson creates correct instance', () {
      final json = {
        'user': {'id': '123', 'email': 'test@test.com'},
        'access_token': 'abc-123',
      };

      final user = User.fromJson(json);

      expect(user.id, '123');
      expect(user.email, 'test@test.com');
      expect(user.username, 'test@test.com');
      expect(user.accessToken, 'abc-123');
      expect(user.authenticated, true);
    });
  });

  group('Product Model Tests', () {
    test('Product.fromJson creates correct instance', () {
      final json = {
        'id': 1,
        'title': 'Test Product',
        'price': 19.99,
        'description': 'Description here',
        'user_id': 'user-1',
        'created_at': '2024-01-01',
      };

      final product = Product.fromJson(json);

      expect(product.id, 1);
      expect(product.title, 'Test Product');
      expect(product.price, 19.99);
      expect(product.description, 'Description here');
      expect(product.userId, 'user-1');
      expect(product.createdAt, '2024-01-01');
    });

    test('Product.toJson returns correct map', () {
      final product = Product(
        id: 1,
        title: 'Test Product',
        price: 19.99,
        description: 'Description here',
        userId: 'user-1',
      );

      final json = product.toJson();

      expect(json['title'], 'Test Product');
      expect(json['price'], 19.99);
      expect(json['description'], 'Description here');
      expect(json['user_id'], 'user-1');
    });

    test('Product.toJson omits userId if null', () {
      final product = Product(
        title: 'Test Product',
        price: 19.99,
        description: 'Description',
      );

      final json = product.toJson();

      expect(json.containsKey('user_id'), false);
    });
  });
}
