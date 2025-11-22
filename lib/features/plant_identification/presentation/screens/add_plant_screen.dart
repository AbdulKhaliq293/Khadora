import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plant_care_app/core/theme/colors.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    // Set status bar to transparent for immersive experience
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera View Placeholder
          _buildCameraView(),

          // 2. Scanning Overlay
          _buildScannerOverlay(),

          // 3. UI Controls
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                const Spacer(),
                _buildPlantInfoCard(context),
                const SizedBox(height: 20),
                _buildModeSelector(),
                const SizedBox(height: 30),
                _buildBottomControls(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1F16), Color(0xFF0D110E)],
        ),
      ),
      child: Center(
        child: Opacity(
          opacity: 0.8,
          child: Image.network(
            'https://images.unsplash.com/photo-1596522354195-e8448ea1639e?q=80&w=1000&auto=format&fit=crop',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: Icon(
                  Icons.local_florist,
                  size: 150,
                  color: primaryColor,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.local_florist,
                  size: 150,
                  color: primaryColor,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return AnimatedBuilder(
      animation: _scanAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ScannerOverlayPainter(scanY: _scanAnimation.value),
          child: Container(),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
          IconButton(
            icon: const Icon(Icons.flash_off, color: Colors.white, size: 28),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildPlantInfoCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: darkGrey.withOpacity(0.6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1596522354195-e8448ea1639e?q=80&w=200&auto=format&fit=crop',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.local_florist,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Small Potted Plant',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Small plants, like succulents and air plants, are perfect...',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, color: white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: darkGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              'Identify',
              style: TextStyle(color: white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          const Padding(
            padding: EdgeInsets.only(right: 24.0),
            child: Text(
              'Multiple',
              style: TextStyle(color: white, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildControlButton(Icons.photo_library_outlined, 'Gallery'),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withOpacity(0.2),
            ),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor,
              ),
              child: const Icon(
                Icons.center_focus_strong,
                size: 32,
                color: white,
              ),
            ),
          ),
          _buildControlButton(Icons.info_outline, 'Photo Tips'),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: white.withOpacity(0.1),
          ),
          child: Icon(icon, color: white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: white, fontSize: 12)),
      ],
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final double scanY;

  ScannerOverlayPainter({required this.scanY});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final double cornerSize = 40.0;
    final double margin = 40.0;
    final Rect scanRect = Rect.fromLTWH(
      margin,
      size.height * 0.2, // Start 20% down
      size.width - (margin * 2),
      size.height * 0.4, // 40% height
    );

    // Draw Corners
    // Top Left
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.left, scanRect.top + cornerSize)
        ..lineTo(scanRect.left, scanRect.top)
        ..lineTo(scanRect.left + cornerSize, scanRect.top),
      paint,
    );
    // Top Right
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.right - cornerSize, scanRect.top)
        ..lineTo(scanRect.right, scanRect.top)
        ..lineTo(scanRect.right, scanRect.top + cornerSize),
      paint,
    );
    // Bottom Left
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.left, scanRect.bottom - cornerSize)
        ..lineTo(scanRect.left, scanRect.bottom)
        ..lineTo(scanRect.left + cornerSize, scanRect.bottom),
      paint,
    );
    // Bottom Right
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.right - cornerSize, scanRect.bottom)
        ..lineTo(scanRect.right, scanRect.bottom)
        ..lineTo(scanRect.right, scanRect.bottom - cornerSize),
      paint,
    );

    // Draw Scan Line
    final double scanLineY = scanRect.top + (scanRect.height * scanY);

    // Gradient for scan line
    final Paint linePaint = Paint()
      ..shader =
          LinearGradient(
            colors: [
              primaryColor.withOpacity(0.0),
              primaryColor.withOpacity(0.8),
              primaryColor.withOpacity(0.0),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(
            Rect.fromLTWH(scanRect.left, scanLineY, scanRect.width, 4),
          );

    canvas.drawRect(
      Rect.fromLTWH(scanRect.left, scanLineY, scanRect.width, 4),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanY != scanY;
  }
}
