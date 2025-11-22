import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_care_app/core/theme/colors.dart';
import 'package:plant_care_app/features/plant_identification/presentation/providers/plant_identification_provider.dart';
import 'package:plant_care_app/features/plant_identification/presentation/screens/plant_details_screen.dart';

class AddPlantScreen extends ConsumerStatefulWidget {
  const AddPlantScreen({super.key});

  @override
  ConsumerState<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends ConsumerState<AddPlantScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  final ImagePicker _picker = ImagePicker();
  File? _capturedImage;

  @override
  void initState() {
    super.initState();
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

    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureAndIdentify() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile image = await _cameraController!.takePicture();
      final File imageFile = File(image.path);

      if (!mounted) return;

      await _identifyImage(imageFile);
    } catch (e) {
      debugPrint('Error capturing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final File imageFile = File(image.path);
        if (!mounted) return;
        await _identifyImage(imageFile);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _identifyImage(File imageFile) async {
    setState(() {
      _capturedImage = imageFile;
    });
    // Trigger API call
    await ref
        .read(plantIdentificationNotifierProvider.notifier)
        .identifyPlant(imageFile);
  }

  @override
  Widget build(BuildContext context) {
    final plantState = ref.watch(plantIdentificationNotifierProvider);

    // Listen for state changes to navigate
    ref.listen(plantIdentificationNotifierProvider, (previous, next) {
      next.whenOrNull(
        data: (result) {
          if (result != null) {
             // Construct the map for the details screen
             final plantMap = {
               // Using the best match as name
               'name': result.bestMatch, 
               'type': result.results.isNotEmpty ? (result.results.first.familyName ?? 'Unknown Family') : 'Unknown Type',
               'scientificName': result.results.isNotEmpty ? result.results.first.scientificName : '',
               'commonNames': result.results.isNotEmpty ? result.results.first.commonNames : [],
               'confidence': result.results.isNotEmpty ? result.results.first.score : 0.0,
               'origin': 'Unknown', 
               'watering': 'Check plant database',
               'maintenance': 'Check plant database',
               'care_level': 'Moderate',
               'water': 50,
               'light': 50,
               'sunlight': 'Bright indirect light',
               'imageUrl': 'https://images.unsplash.com/photo-1596522354195-e8448ea1639e?q=80&w=1000&auto=format&fit=crop', // Placeholder
               'imageFile': _capturedImage, // Pass the local file
             };

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PlantDetailsScreen(plant: plantMap),
              ),
            );
             // Reset state so we don't navigate again immediately if we pop back
             ref.read(plantIdentificationNotifierProvider.notifier).reset();
          }
        },
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera View
          _buildCameraView(),

          // 2. Scanning Overlay
          if (plantState.isLoading)
            _buildScannerOverlay()
          else
            const SizedBox.shrink(), // Hide scanner when not loading

          // 3. UI Controls
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                const Spacer(),
                // Only show info card if not loading and maybe has a partial result? 
                // For now, let's hide it or show a "Ready to Scan" message.
                 _buildPlantInfoCard(context),
                const SizedBox(height: 20),
                _buildModeSelector(),
                const SizedBox(height: 30),
                _buildBottomControls(context, plantState.isLoading),
                const SizedBox(height: 20),
              ],
            ),
          ),
          
          // Loading Indicator
          if (plantState.isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator(color: primaryColor)),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    return CameraPreview(_cameraController!);
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
            onPressed: () {
                // Toggle flash implementation if needed
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlantInfoCard(BuildContext context) {
    // Static info card for now, could be dynamic later
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
                 Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Scan a Plant',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Point your camera at a plant to identify it.',
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
           Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Text(
              'History', // Changed from Multiple to History as it makes more sense
              style: const TextStyle(color: white, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: isLoading ? null : _pickImage,
            child: _buildControlButton(Icons.photo_library_outlined, 'Gallery'),
          ),
          GestureDetector(
            onTap: isLoading ? null : _captureAndIdentify,
            child: Container(
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
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(
                        Icons.center_focus_strong,
                        size: 32,
                        color: white,
                      ),
              ),
            ),
          ),
          _buildControlButton(Icons.info_outline, 'Tips'),
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
      size.height * 0.2,
      size.width - (margin * 2),
      size.height * 0.4,
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
