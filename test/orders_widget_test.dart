import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exquisssita_manager/app/theme/app_theme.dart';
import 'package:exquisssita_manager/features/orders/data/orders_providers.dart';
import 'package:exquisssita_manager/features/orders/domain/order_models.dart';
import 'package:exquisssita_manager/features/orders/presentation/orders_view.dart';

void main() {
  testWidgets('muestra grid de mesas y pedido para llevar', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tablesProvider.overrideWith(
            (ref) => Stream.value(const [
              TableSummary(id: '1', number: '1', status: 'Libre'),
            ]),
          ),
        ],
        child: MaterialApp(theme: AppTheme.lightTheme, home: const OrdersView()),
      ),
    );
    await tester.pump();
    expect(find.text('Mesa 1'), findsOneWidget);
    expect(find.text('Para llevar'), findsOneWidget);
  });
}
