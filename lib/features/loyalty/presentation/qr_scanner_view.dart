import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../app/theme/exquisssita_tokens.dart';
import '../../../shared/widgets/exquisssita_components.dart';
import 'qr_scan_view_model.dart';

class QrScannerView extends ConsumerStatefulWidget {
  const QrScannerView({super.key});

  @override
  ConsumerState<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends ConsumerState<QrScannerView>
    with WidgetsBindingObserver {
  MobileScannerController? _scanner;
  bool _detecting = false;
  bool _resumed = true;
  bool get _supported =>
      kIsWeb ||
      {
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      }.contains(defaultTargetPlatform);

  @override
  void initState() {
    super.initState();
    if (_supported) {
      _scanner = MobileScannerController();
      WidgetsBinding.instance.addObserver(this);
    }
  }

  Future<void> _camera(bool start) async {
    try {
      if (start) {
        await _scanner?.start();
      } else {
        await _scanner?.stop();
      }
    } on MobileScannerException {
      // The scanner renders a safe error state; never expose native details.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _resumed = state == AppLifecycleState.resumed;
    if (_scanner?.value.hasCameraPermission != true) return;
    unawaited(_camera(_resumed && !_detecting));
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    final vm = ref.read(qrScanViewModelProvider.notifier);
    if (_detecting || ref.read(qrScanViewModelProvider).processing) return;
    final raw = capture.barcodes.isEmpty
        ? null
        : capture.barcodes.first.rawValue;
    if (raw == null) return;
    _detecting = true;
    try {
      await _camera(false);
      final result = await vm.scan(raw);
      if (!mounted || result == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.alreadyRegistered
                ? 'La visita de hoy ya estaba registrada.'
                : 'Visita registrada. +${result.pointsAwarded} puntos.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No fue posible registrar la visita. Verifica el QR y tu conexión.',
          ),
        ),
      );
    } finally {
      _detecting = false;
      if (mounted && _resumed) {
        await _camera(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.exq;
    final m = t.metrics;
    if (!_supported) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const ExquisssitaPageHeader(
                title: 'Lealtad QR',
                subtitle: 'Cámara QR no disponible en Windows',
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(m.spaceXxl),
                    child: const Text(
                      'Registra la visita desde la aplicación Android. El lector QR de cámara no está disponible en esta plataforma.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: Column(
        children: [
          const ExquisssitaPageHeader(
            title: 'Lealtad QR',
            subtitle: 'Enfoca el código QR del cliente',
          ),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Semantics(
                  label: 'Cámara para leer códigos QR',
                  image: true,
                  child: MobileScanner(
                    controller: _scanner,
                    onDetect: _handleBarcode,
                    errorBuilder: (context, error) => Center(
                      child: ExquisssitaErrorState(
                        message:
                            error.errorCode ==
                                MobileScannerErrorCode.permissionDenied
                            ? 'Permite el acceso a la cámara en los ajustes de Android para leer QR.'
                            : 'No se pudo iniciar la cámara. Cierra y vuelve a abrir el lector.',
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(m.spaceXxl),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: m.scannerMax,
                        maxHeight: m.scannerMax,
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: t.accent,
                              width: m.focusWidth,
                            ),
                            borderRadius: BorderRadius.circular(m.radiusCard),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_scanner != null) unawaited(_scanner!.dispose());
    super.dispose();
  }
}
