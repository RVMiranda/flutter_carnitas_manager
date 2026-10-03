import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exquisssita_manager/app/theme/app_theme.dart';
import 'package:exquisssita_manager/app/theme/exquisssita_tokens.dart';
import 'package:exquisssita_manager/shared/widgets/design_gallery.dart';
import 'package:exquisssita_manager/shared/widgets/exquisssita_components.dart';

double contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return ((x > y ? x : y) + .05) / ((x > y ? y : x) + .05);
}

Widget host(
  Widget child, {
  ThemeData? theme,
  double scale = 1,
  bool reduced = false,
}) => MaterialApp(
  theme: theme ?? AppTheme.lightTheme,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(scale),
      disableAnimations: reduced,
    ),
    child: child!,
  ),
  home: Scaffold(body: child),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    for (final family in ['Outfit', 'Fraunces']) {
      final loader = FontLoader(family);
      for (final weight in ['Regular', 'SemiBold', 'Bold']) {
        loader.addFont(rootBundle.load('assets/fonts/$family-$weight.ttf'));
      }
      await loader.load();
    }
  });

  test('identity and AA pairs in light, dark and high contrast', () {
    for (final theme in [
      AppTheme.lightTheme,
      AppTheme.darkTheme,
      AppTheme.highContrastLightTheme,
      AppTheme.highContrastDarkTheme,
    ]) {
      final t = theme.extension<ExquisssitaTokens>()!;
      expect(t.heading.fontFamily, 'Fraunces');
      expect(t.body.fontFamily, 'Outfit');
      expect(t.accent, const Color(0xFFF5A623));
      for (final surface in [t.background, t.card, t.secondary, t.muted]) {
        expect(contrast(t.foreground, surface), greaterThanOrEqualTo(4.5));
        expect(contrast(t.focus, surface), greaterThanOrEqualTo(3));
      }
      expect(contrast(t.onAccent, t.accent), greaterThanOrEqualTo(4.5));
      expect(
        contrast(t.actionForeground, t.actionBackground),
        greaterThanOrEqualTo(3),
      );
      expect(t.button.fontSize, greaterThanOrEqualTo(20));
      expect(t.button.fontWeight, FontWeight.bold);
      expect(theme.splashFactory, NoSplash.splashFactory);
    }
    final light = AppTheme.lightTheme.extension<ExquisssitaTokens>()!;
    final dark = AppTheme.darkTheme.extension<ExquisssitaTokens>()!;
    expect(light.background, const Color(0xFFFDF5EF));
    expect(light.primary, const Color(0xFFD94F3D));
    expect(light.foreground, const Color(0xFF1A2744));
    expect(dark.background, const Color(0xFF0F1523));
    expect(dark.primary, const Color(0xFFE8715A));
    expect(
      contrast(dark.actionForeground, dark.actionBackground),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      light.lerp(dark, .5).primary,
      Color.lerp(light.primary, dark.primary, .5),
    );
  });

  testWidgets(
    'press down is immediate, cancellation and disabled never activate',
    (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        host(
          ExquisssitaIconAction(
            label: 'Ajustes',
            icon: Icons.settings_outlined,
            onPressed: () => taps++,
          ),
        ),
      );
      final target = find.byType(ExquisssitaPressable);
      expect(tester.getSize(target).shortestSide, greaterThanOrEqualTo(48));
      final gesture = await tester.startGesture(tester.getCenter(target));
      await tester.pump();
      expect(
        tester.widget<Opacity>(find.byType(Opacity).first).opacity,
        lessThan(1),
      );
      expect(taps, 0);
      await gesture.cancel();
      await tester.pumpAndSettle();
      expect(taps, 0);
      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(taps, 1);
      await tester.pumpWidget(
        host(
          const ExquisssitaIconAction(
            label: 'Ajustes',
            icon: Icons.settings_outlined,
            onPressed: null,
          ),
        ),
      );
      await tester.tap(target);
      expect(taps, 1);
    },
  );

  testWidgets(
    'Tab focus is visible, Enter and Space activate once, semantics has one label',
    (tester) async {
      final semantics = tester.ensureSemantics();
      var taps = 0;
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        host(
          ExquisssitaPressable(
            label: 'Guardar',
            focusNode: focus,
            onPressed: () => taps++,
            child: const Text('Guardar'),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(focus.hasFocus, isTrue);
      final borders = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((w) => w.decoration)
          .whereType<BoxDecoration>();
      expect(
        borders.any(
          (b) =>
              b.border is Border &&
              (b.border! as Border).top.color == const Color(0xFF1A2744),
        ),
        isTrue,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(taps, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(taps, 2);
      final node = tester.getSemantics(find.byType(ExquisssitaPressable));
      expect(
        node,
        matchesSemantics(
          label: 'Guardar',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          isFocused: true,
          hasTapAction: true,
        ),
      );
      expect(find.bySemanticsLabel('Guardar'), findsOneWidget);
      semantics.dispose();
    },
  );

  for (final feature in ['Android', 'iOS', 'assistive navigation']) {
    testWidgets('$feature reduced motion keeps press feedback without scale', (
      tester,
    ) async {
      tester.binding.platformDispatcher.accessibilityFeaturesTestValue =
          FakeAccessibilityFeatures(
            reduceMotion: feature == 'iOS',
            accessibleNavigation: feature == 'assistive navigation',
          );
      addTearDown(
        tester.binding.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pumpWidget(
        host(
          ExquisssitaAction(label: 'Guardar', onPressed: () {}),
          reduced: feature == 'Android',
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ExquisssitaPressable)),
      );
      await tester.pump();
      final scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
      expect(scale.scale, 1);
      expect(scale.duration, Duration.zero);
      expect(
        tester.widget<Opacity>(find.byType(Opacity).first).opacity,
        lessThan(1),
      );
      await gesture.up();
      await tester.pumpAndSettle();
    });
  }

  for (final dark in [false, true]) {
    testWidgets(
      'gallery ${dark ? 'dark' : 'light'} meets contrast, targets and labels',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final semantics = tester.ensureSemantics();
        final capture = GlobalKey();
        await tester.pumpWidget(
          host(
            Builder(
              builder: (context) => RepaintBoundary(
                key: capture,
                child: ColoredBox(
                  color: context.exq.background,
                  child: const ExquisssitaGallery(),
                ),
              ),
            ),
            theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
          ),
        );
        await tester.pumpAndSettle();
        for (var page = 0; page < 4; page++) {
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          if (page == 0 && const bool.fromEnvironment('CAPTURE_DESIGN')) {
            await tester.runAsync(() async {
              final boundary =
                  capture.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary;
              final image = await boundary.toImage();
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final directory = Directory('docs/visual');
              await directory.create(recursive: true);
              await File(
                '${directory.path}/gallery-${dark ? 'dark' : 'light'}.png',
              ).writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
          await tester.drag(find.byType(ListView), const Offset(0, -400));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
        semantics.dispose();
      },
    );
  }

  for (final scale in [2.0, 3.0]) {
    testWidgets(
      'gallery at 320 px and ${scale}x text remains scrollable and usable',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(host(const ExquisssitaGallery(), scale: scale));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('Abrir modal'),
          300,
          scrollable: find.byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Abrir modal'));
        await tester.pumpAndSettle();
        expect(find.text('Revisar operación'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Cerrar modal'));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('Abrir hoja'),
          300,
          scrollable: find.byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          ),
        );
        await tester.tap(find.text('Abrir hoja'));
        await tester.pumpAndSettle();
        expect(find.text('Opciones del ejemplo'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
