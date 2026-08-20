import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/image_utils.dart';
import '../../../data/mock/mock_data.dart';

/// The "Capture" tab — a media TRAY. The buyer shoots (or picks from gallery)
/// first and attaches to a lot later. Real images now: capture, preview, zoom.
class CameraBody extends StatefulWidget {
  const CameraBody({super.key, required this.tenderId});
  final String tenderId;

  @override
  State<CameraBody> createState() => _CameraBodyState();
}

class _CameraBodyState extends State<CameraBody> {
  List<dynamic> get _tray => MockData.trayImages;

  Future<void> _add() async {
    final bytes = await pickImageBytes(context);
    if (bytes == null) return;
    setState(() => MockData.trayImages.add(bytes));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSpacing.page,
      children: [
        // Capture area — tap to take/pick a photo.
        GestureDetector(
          onTap: _add,
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF08080A),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: const Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.photo_camera_outlined,
                      color: Colors.white54, size: 44),
                  SizedBox(height: AppSpacing.sm),
                  Text('Tap to capture or upload',
                      style: TextStyle(color: Colors.white54)),
                ]),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _add,
              icon: const Icon(Icons.add_a_photo_outlined, size: 18),
              label: const Text('Camera / Gallery'),
            ),
          ),
        ]),
        const SizedBox(height: AppSpacing.lg),
        Row(children: [
          Text('Unattached tray', style: AppTypography.h2),
          const SizedBox(width: AppSpacing.sm),
          Text('${_tray.length} item${_tray.length == 1 ? '' : 's'}',
              style: AppTypography.caption),
        ]),
        const SizedBox(height: AppSpacing.md),
        if (_tray.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            alignment: Alignment.center,
            child: Text('No photos yet — tap above to add.',
                style: AppTypography.bodyMuted),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
            ),
            itemCount: MockData.trayImages.length,
            itemBuilder: (_, i) => ImageThumb(
              images: MockData.trayImages,
              index: i,
              size: 120,
              onDelete: () =>
                  setState(() => MockData.trayImages.removeAt(i)),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        Row(children: [
          const Icon(Icons.info_outline, size: 15, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text('Tap a photo to zoom · attach-to-lot comes with the live build',
                style: AppTypography.caption),
          ),
        ]),
      ],
    );
  }
}
