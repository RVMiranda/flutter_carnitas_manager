import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:exquisssita_manager/app/theme/app_theme.dart';
import 'package:exquisssita_manager/features/loyalty/presentation/qr_scanner_view.dart';

void main() {
  testWidgets(
    'Windows no crea controlador nativo de cámara y explica alternativa',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      try {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const QrScannerView(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(MobileScanner), findsNothing);
        expect(find.textContaining('Registra la visita desde'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );
}
