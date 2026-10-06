import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exquisssita_manager/app/theme/app_theme.dart';
import 'package:exquisssita_manager/features/orders/data/orders_providers.dart';
import 'package:exquisssita_manager/features/orders/domain/order_models.dart';
import 'package:exquisssita_manager/features/orders/presentation/orders_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final family in ['Outfit', 'Fraunces']) {
      final loader = FontLoader(family)
        ..addFont(rootBundle.load('assets/fonts/$family-Regular.ttf'))
        ..addFont(rootBundle.load('assets/fonts/$family-SemiBold.ttf'));
      await loader.load();
    }
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  for (final variant in ['light', 'dark', 'large-text']) {
    testWidgets('mesas $variant: render, targets y semántica de ocupadas', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      final semantics = tester.ensureSemantics();
      final capture = GlobalKey();
      try {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              tablesProvider.overrideWith(
                (ref) => Stream.value(
                  List.generate(
                    10,
                    (i) => TableSummary(
                      id: 'table-${i + 1}',
                      number: '${i + 1}',
                      status: i == 0 || i == 6 ? 'Ocupada' : 'Libre',
                      pendingSync: i == 0,
                      syncFailed: i == 6,
                    ),
                  ),
                ),
              ),
            ],
            child: MaterialApp(
              theme: variant == 'dark'
                  ? AppTheme.darkTheme
                  : AppTheme.lightTheme,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(
                    variant == 'large-text' ? 2 : 1,
                  ),
                ),
                child: child!,
              ),
              home: RepaintBoundary(
                key: capture,
                child: const Scaffold(body: OrdersView()),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final button = find.byKey(const Key('table-table-1'));
        expect(tester.getSemantics(button).label, contains('Continuar orden'));
        expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
        expect(tester.getSize(button).width, greaterThanOrEqualTo(48));
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final boundary =
              capture.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          final rendered = await boundary.toImage(pixelRatio: 2);
          try {
            final png = await rendered.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final file = File('build/verification/tables-$variant.png');
            await file.parent.create(recursive: true);
            await file.writeAsBytes(png!.buffer.asUint8List());
          } finally {
            rendered.dispose();
          }
        });
        await tester.pumpWidget(const SizedBox.shrink());
      } finally {
        semantics.dispose();
        await tester.binding.setSurfaceSize(null);
      }
    });
  }
}
