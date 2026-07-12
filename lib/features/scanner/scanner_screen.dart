import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../bloc/scanner/scanner.dart';
import '../../models/product/product.dart';
import '../../router/router.dart';
import '../../ui/theme/app_colors.dart';

@RoutePage()
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();

  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;

    if (barcodes.isEmpty) return;

    final barcode = barcodes.first.rawValue;

    if (barcode == null || barcode.trim().isEmpty) return;

    setState(() => _isProcessing = true);

    _controller.stop();

    context.read<ScannerBloc>().add(
      ScannerBarcodeDetected(barcode: barcode.trim()),
    );
  }

  void _resetScanner() {
    if (!mounted) return;

    context.read<ScannerBloc>().add(const ScannerResetRequested());

    setState(() => _isProcessing = false);

    _controller.start();
  }

  Future<void> _openAddScannedProduct(ProductModel product) async {
    await context.router.push(AddScannedProductRoute(product: product));

    if (!mounted) return;

    _resetScanner();
  }

  Future<void> _openAddManualProduct(String barcode) async {
    await context.router.push(AddManualProductRoute(prefilledBarcode: barcode));

    if (!mounted) return;

    _resetScanner();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScannerBloc, ScannerState>(
      listener: (context, state) {
        if (state is ScannerProductFound) {
          _showProductFoundSheet(product: state.product);
        }

        if (state is ScannerProductNotFound) {
          _showProductNotFoundSheet(barcode: state.barcode);
        }

        if (state is ScannerFailure) {
          _showMessage(state.message);
          _resetScanner();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            MobileScanner(controller: _controller, onDetect: _onDetect),
            Container(color: Colors.black.withValues(alpha: 0.18)),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  children: [
                    _ScannerHeader(
                      onBack: () {
                        _controller.stop();
                        context.router.maybePop();
                      },
                      onTorch: _controller.toggleTorch,
                    ),
                    const Spacer(),
                    const _ScannerFrame(),
                    const SizedBox(height: 24),
                    BlocBuilder<ScannerBloc, ScannerState>(
                      builder: (context, state) {
                        if (state is ScannerLoading) {
                          return const _ScannerStatus(
                            text: 'Searching product...',
                            isLoading: true,
                          );
                        }

                        return const _ScannerStatus(
                          text: 'Place the barcode inside the frame',
                          isLoading: false,
                        );
                      },
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showProductFoundSheet({required ProductModel product}) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return _ScannerResultSheet(
          title: 'Product found',
          subtitle: product.name,
          barcode: product.barcode ?? 'No barcode',
          primaryButtonText: 'Continue',
          secondaryButtonText: 'Scan again',
          onPrimaryTap: () {
            Navigator.of(context).pop();

            _openAddScannedProduct(product);
          },
          onSecondaryTap: () {
            Navigator.of(context).pop();
            _resetScanner();
          },
        );
      },
    );
  }

  Future<void> _showProductNotFoundSheet({required String barcode}) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return _ScannerResultSheet(
          title: 'Product not found',
          subtitle: 'You can add this product manually.',
          barcode: barcode,
          primaryButtonText: 'Add manually',
          secondaryButtonText: 'Scan again',
          onPrimaryTap: () {
            Navigator.of(context).pop();

            _openAddManualProduct(barcode);
          },
          onSecondaryTap: () {
            Navigator.of(context).pop();
            _resetScanner();
          },
        );
      },
    );
  }
}

class _ScannerHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onTorch;

  const _ScannerHeader({required this.onBack, required this.onTorch});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ScannerHeaderButton(icon: Icons.chevron_left, onTap: onBack),
        const Expanded(
          child: Text(
            'Scan Barcode',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        _ScannerHeaderButton(icon: Icons.flash_on_outlined, onTap: onTorch),
      ],
    );
  }
}

class _ScannerHeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ScannerHeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.36),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Icon(icon, color: colors.primary, size: 26),
      ),
    );
  }
}

class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: 260,
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.88),
          width: 3,
        ),
      ),
      child: Stack(
        children: [
          const _Corner(alignment: Alignment.topLeft),
          const _Corner(alignment: Alignment.topRight),
          const _Corner(alignment: Alignment.bottomLeft),
          const _Corner(alignment: Alignment.bottomRight),
          Center(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final Alignment alignment;

  const _Corner({required this.alignment});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final borderSide = BorderSide(color: colors.primary, width: 5);

    return Align(
      alignment: alignment,
      child: Container(
        width: 34,
        height: 34,
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border(
            top:
                alignment == Alignment.topLeft ||
                    alignment == Alignment.topRight
                ? borderSide
                : BorderSide.none,
            bottom:
                alignment == Alignment.bottomLeft ||
                    alignment == Alignment.bottomRight
                ? borderSide
                : BorderSide.none,
            left:
                alignment == Alignment.topLeft ||
                    alignment == Alignment.bottomLeft
                ? borderSide
                : BorderSide.none,
            right:
                alignment == Alignment.topRight ||
                    alignment == Alignment.bottomRight
                ? borderSide
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _ScannerStatus extends StatelessWidget {
  final String text;
  final bool isLoading;

  const _ScannerStatus({required this.text, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading) ...[
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerResultSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final String barcode;
  final String primaryButtonText;
  final String secondaryButtonText;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;

  const _ScannerResultSheet({
    required this.title,
    required this.subtitle,
    required this.barcode,
    required this.primaryButtonText,
    required this.secondaryButtonText,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_scanner, size: 42, color: colors.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surfaceSoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border),
              ),
              child: Text(
                barcode,
                style: TextStyle(
                  color: colors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onPrimaryTap,
                child: Text(primaryButtonText),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onSecondaryTap,
              child: Text(secondaryButtonText),
            ),
          ],
        ),
      ),
    );
  }
}
