import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

/// Media helpers shared by the Capture tray and the Lot-entry terminal.
///
/// Images are held as raw bytes ([Uint8List]) — that keeps everything working on
/// BOTH mobile and web (no `dart:io`), and is fine for the session-only mock.

final ImagePicker _picker = ImagePicker();

/// Show a Camera / Gallery chooser, then return the picked image bytes (or null).
Future<Uint8List?> pickImageBytes(BuildContext context) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: context.scheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: AppSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add photo', style: AppTypography.h2),
            const SizedBox(height: AppSpacing.md),
            _SourceTile(
              icon: Icons.photo_camera_outlined,
              label: 'Take a photo',
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            const SizedBox(height: AppSpacing.sm),
            _SourceTile(
              icon: Icons.photo_library_outlined,
              label: 'Choose from gallery',
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    ),
  );
  if (source == null) return null;
  try {
    final x = await _picker.pickImage(
      source: source,
      maxWidth: 1800,
      imageQuality: 85,
    );
    if (x == null) return null;
    return await x.readAsBytes();
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not get image: $e')),
      );
    }
    return null;
  }
}

/// Take a single photo with the device camera → bytes (or null).
Future<Uint8List?> captureFromCamera(BuildContext context) async {
  try {
    final x = await _picker.pickImage(
        source: ImageSource.camera, maxWidth: 1800, imageQuality: 85);
    return x == null ? null : await x.readAsBytes();
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Camera error: $e')));
    }
    return null;
  }
}

/// Pick MULTIPLE images from the gallery at once → list of bytes (empty if none).
Future<List<Uint8List>> pickMultiFromGallery(BuildContext context) async {
  try {
    final xs = await _picker.pickMultiImage(maxWidth: 1800, imageQuality: 85);
    final out = <Uint8List>[];
    for (final x in xs) {
      out.add(await x.readAsBytes());
    }
    return out;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gallery error: $e')));
    }
    return const [];
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: context.scheme.outlineVariant),
        ),
        child: Row(children: [
          Icon(icon, color: context.scheme.primary),
          const SizedBox(width: AppSpacing.md),
          Text(label, style: AppTypography.title),
        ]),
      ),
    );
  }
}

/// A rounded image thumbnail that opens the full-screen zoom viewer on tap.
class ImageThumb extends StatelessWidget {
  const ImageThumb({
    super.key,
    required this.images,
    required this.index,
    this.size = 92,
    this.onDelete,
  });

  final List<Uint8List> images;
  final int index;
  final double size;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final tag = 'img_${identityHashCode(images)}_$index';
    return Stack(
      children: [
        GestureDetector(
          onTap: () => showImageViewer(context, images, index, heroTag: tag),
          child: Hero(
            tag: tag,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: Image.memory(
                images[index],
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        // Small, subtle delete inside the top-right corner — doesn't cover the photo.
        if (onDelete != null)
          Positioned(
            top: 3,
            right: 3,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 11, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

/// Open a full-screen, swipeable, pinch-to-zoom image viewer.
void showImageViewer(BuildContext context, List<Uint8List> images, int index,
    {String? heroTag}) {
  Navigator.of(context).push(PageRouteBuilder(
    opaque: false,
    barrierColor: Colors.black,
    pageBuilder: (_, __, ___) =>
        _ImageViewer(images: images, initialIndex: index, heroTag: heroTag),
    transitionsBuilder: (_, anim, __, child) =>
        FadeTransition(opacity: anim, child: child),
  ));
}

class _ImageViewer extends StatefulWidget {
  const _ImageViewer(
      {required this.images, required this.initialIndex, this.heroTag});
  final List<Uint8List> images;
  final int initialIndex;
  final String? heroTag;

  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer> {
  late final PageController _page = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;
  final _tc = TransformationController();
  TapDownDetails? _doubleTapPos;
  final Map<int, int> _turns = {}; // quarter-turns per image

  @override
  void dispose() {
    _page.dispose();
    _tc.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    if (_tc.value != Matrix4.identity()) {
      _tc.value = Matrix4.identity(); // zoom out
    } else {
      final p = _doubleTapPos?.localPosition ?? Offset.zero;
      _tc.value = Matrix4.identity()
        ..translate(-p.dx * 1.5, -p.dy * 1.5)
        ..scale(2.5); // zoom in at the tapped point
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _page,
            onPageChanged: (i) => setState(() => _index = i),
            itemCount: widget.images.length,
            itemBuilder: (_, i) {
              final img = RotatedBox(
                quarterTurns: _turns[i] ?? 0,
                child: Image.memory(widget.images[i], fit: BoxFit.contain),
              );
              return GestureDetector(
                onDoubleTapDown: (d) => _doubleTapPos = d,
                onDoubleTap: _handleDoubleTap,
                child: InteractiveViewer(
                  transformationController: i == _index ? _tc : null,
                  minScale: 1,
                  maxScale: 5,
                  child: Center(
                    child: i == widget.initialIndex && widget.heroTag != null
                        ? Hero(tag: widget.heroTag!, child: img)
                        : img,
                  ),
                ),
              );
            },
          ),
          // Top bar: counter + close
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            right: 8,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                if (widget.images.length > 1)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                    child: Text('${_index + 1} / ${widget.images.length}',
                        style: const TextStyle(color: Colors.white)),
                  ),
                const Spacer(),
                IconButton(
                  tooltip: 'Rotate',
                  icon: const Icon(Icons.rotate_90_degrees_cw, color: Colors.white),
                  onPressed: () => setState(() =>
                      _turns[_index] = ((_turns[_index] ?? 0) + 1) % 4),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 0,
            right: 0,
            child: const Center(
              child: Text('Pinch or double-tap to zoom · tap ⟳ to rotate',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
