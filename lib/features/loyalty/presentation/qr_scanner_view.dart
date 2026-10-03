import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../data/loyalty_providers.dart';
import 'qr_scan_coordinator.dart';

class QrScannerView extends ConsumerStatefulWidget {
  const QrScannerView({super.key});

  @override
  ConsumerState<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends ConsumerState<QrScannerView> {
  late final MobileScannerController _scanner;
  late final QrScanCoordinator _coordinator;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _scanner = MobileScannerController();
    _coordinator = QrScanCoordinator(ref.read(loyaltyRepositoryProvider));
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_busy) return;
    final raw = capture.barcodes.isEmpty
        ? null
        : capture.barcodes.first.rawValue;
    if (raw == null) return;
    _busy = true;
    await _scanner.stop();
    try {
      final result = await _coordinator.handle(raw);
      if (!mounted) return;
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
        SnackBar(content: Text('No se pudo registrar el QR: $error')),
      );
    } finally {
      if (mounted) {
        _busy = false;
        await _scanner.start();
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Lealtad QR')),
    body: Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(controller: _scanner, onDetect: _handleBarcode),
        Center(
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const Positioned(
          left: 24,
          right: 24,
          bottom: 32,
          child: Text(
            'Enfoca el código QR del cliente',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    ),
  );

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }
}
