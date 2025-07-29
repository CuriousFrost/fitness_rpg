// lib/widgets/sprite_display_widget.dart
import 'dart:ui' as ui; // Import for ui.Image
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle

class SpriteDisplay extends StatefulWidget {
  final String imagePath; // Path to your full sprite sheet
  final Rect spriteRect; // The rectangle (source) of the sprite on the sheet
  final double width;    // Desired display width of the sprite
  final double height;   // Desired display height of the sprite
  final double spriteScale;

  const SpriteDisplay({
    super.key,
    required this.imagePath,
    required this.spriteRect,
    required this.width,
    required this.height,
    this.spriteScale = 1.0,
  });

  @override
  State<SpriteDisplay> createState() => _SpriteDisplayState();
}

class _SpriteDisplayState extends State<SpriteDisplay> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(SpriteDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imagePath != oldWidget.imagePath) {
      _loadImage(); // Reload if image path changes
    }
    // Note: If spriteRect can change, you might need to call setState here
    // or ensure CustomPainter redraws. For static rects, it's fine.
  }

  Future<void> _loadImage() async {
    final ByteData data = await rootBundle.load(widget.imagePath);
    final ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final ui.FrameInfo fi = await codec.getNextFrame();
    if (mounted) {
      setState(() {
        _image = fi.image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_image == null) {
      // Return a placeholder or SizedBox while the image is loading
      return SizedBox(width: widget.width, height: widget.height);
    }
    return CustomPaint(
      size: Size(widget.width, widget.height),
      painter: _SpritePainter(
        image: _image!,
        spriteRect: widget.spriteRect,
        scale: widget.spriteScale,
      ),
    );
  }
}

class _SpritePainter extends CustomPainter {
  final ui.Image image;
  final Rect spriteRect;
  final double scale;

  _SpritePainter({
    required this.image,
    required this.spriteRect,
    this.scale = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scaledWidth = size.width * scale;
    final double scaledHeight = size.height * scale;

    // Calculate top-left position to center the scaled sprite
    final double offsetX = (size.width - scaledWidth) / 2;
    final double offsetY = (size.height - scaledHeight) / 2;

    // *** USE offsetX and offsetY HERE ***
    final Rect destRect = Rect.fromLTWH(offsetX, offsetY, scaledWidth, scaledHeight);

    // Draw the specified part of the image onto the canvas
    canvas.drawImageRect(image, spriteRect, destRect, Paint());
  }

  @override
  bool shouldRepaint(_SpritePainter oldDelegate) {
    return image != oldDelegate.image ||
        spriteRect != oldDelegate.spriteRect ||
        scale != oldDelegate.scale;
  }
}
