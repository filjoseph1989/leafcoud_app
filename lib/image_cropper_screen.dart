import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';

class ImageCropperScreen extends StatefulWidget {
  const ImageCropperScreen({super.key});

  @override
  State<ImageCropperScreen> createState() => _ImageCropperScreenState();
}

class _ImageCropperScreenState extends State<ImageCropperScreen> {
  Map<String, dynamic>? _currentImage;
  bool _isLoading = true;
  String? _errorMessage;
  Offset _cropCenter = const Offset(100, 100);
  final GlobalKey _imageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fetchNextImage();
  }

  Future<void> _fetchNextImage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = context.read<ApiService>();
      final data = await apiService.getNextImageToCrop();
      setState(() {
        _currentImage = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveCrop() async {
    if (_currentImage == null) return;

    final RenderBox renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox;
    final size = renderBox.size;

    try {
      final apiService = context.read<ApiService>();
      await apiService.submitCrop(
        relPath: _currentImage!['rel_path'],
        centerX: _cropCenter.dx,
        centerY: _cropCenter.dy,
        displayWidth: size.width,
        displayHeight: size.height,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Crop saved successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save crop: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _skipImage() async {
    if (_currentImage == null) return;

    try {
      final apiService = context.read<ApiService>();
      await apiService.skipImage(_currentImage!['rel_path']);
      _fetchNextImage();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to skip image: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _markDone() async {
    if (_currentImage == null) return;

    try {
      final apiService = context.read<ApiService>();
      await apiService.markImageDone(_currentImage!['rel_path']);
      _fetchNextImage();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark image as done: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Image Cropper', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNextImage,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!, style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _fetchNextImage, child: const Text('Retry')),
                    ],
                  ),
                )
              : _currentImage == null
                  ? const Center(child: Text('No images available', style: TextStyle(color: Colors.white)))
                  : Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onPanUpdate: (details) {
                                    final RenderBox box = _imageKey.currentContext?.findRenderObject() as RenderBox;
                                    final localPos = box.globalToLocal(details.globalPosition);
                                    if (localPos.dx >= 0 && localPos.dx <= box.size.width &&
                                        localPos.dy >= 0 && localPos.dy <= box.size.height) {
                                      setState(() {
                                        _cropCenter = localPos;
                                      });
                                    }
                                  },
                                  onTapDown: (details) {
                                    setState(() {
                                      _cropCenter = details.localPosition;
                                    });
                                  },
                                  child: Image.network(
                                    _currentImage!['image_url'],
                                    key: _imageKey,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                // Custom Paint for the crop box
                                IgnorePointer(
                                  child: CustomPaint(
                                    painter: CropOverlayPainter(
                                      center: _cropCenter,
                                      // Scale the 224x224 box based on common screen sizes or just use a fixed visual size
                                      cropSize: 100.0, 
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _buildControls(theme),
                      ],
                    ),
    );
  }

  Widget _buildControls(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[900],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Center: (${_cropCenter.dx.toStringAsFixed(1)}, ${_cropCenter.dy.toStringAsFixed(1)})',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                onPressed: _skipImage,
                icon: Icons.skip_next,
                label: 'Skip',
                color: Colors.orange,
              ),
              _buildActionButton(
                onPressed: _saveCrop,
                icon: Icons.save,
                label: 'Save Crop',
                color: theme.colorScheme.primary,
              ),
              _buildActionButton(
                onPressed: _markDone,
                icon: Icons.check_circle,
                label: 'Done',
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        IconButton.filled(
          onPressed: onPressed,
          icon: Icon(icon),
          style: IconButton.styleFrom(backgroundColor: color),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}

class CropOverlayPainter extends CustomPainter {
  final Offset center;
  final double cropSize;

  CropOverlayPainter({required this.center, required this.cropSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final rect = Rect.fromCenter(
      center: center,
      width: cropSize,
      height: cropSize,
    );

    canvas.drawRect(rect, paint);
    
    // Draw crosshair
    canvas.drawLine(Offset(center.dx - 10, center.dy), Offset(center.dx + 10, center.dy), paint);
    canvas.drawLine(Offset(center.dx, center.dy - 10), Offset(center.dx, center.dy + 10), paint);
  }

  @override
  bool shouldRepaint(covariant CropOverlayPainter oldDelegate) {
    return oldDelegate.center != center || oldDelegate.cropSize != cropSize;
  }
}
