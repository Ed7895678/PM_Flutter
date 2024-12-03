// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto/main.dart';
import 'package:projeto/screens/auth/login_screen.dart';
import 'package:projeto/screens/auth/register_screen.dart';
import 'package:projeto/screens/home/home_screen.dart';
import 'package:projeto/screens/product/product_list_screen.dart';

void main() {
  testWidgets('App should start at login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Criar conta'), findsOneWidget);
  });

  testWidgets('Can navigate to register screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.widgetWithText(TextButton, 'Criar conta'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('Registro'), findsOneWidget);
  });

  testWidgets('Products screen shows correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ProductListScreen()));
    expect(find.text('Produtos'), findsOneWidget);
  });
}