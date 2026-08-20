import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';

/// A tap-to-pick field: shows the current value, opens a bottom-sheet of chips
/// from a managed list. This is the "picker fallback" the POC settled — never a
/// blocker, always available (BRD PART J). Also allows a free typed value so a
/// buyer can add a missing code mid-evaluation (TE-021).
class GradePickerField extends StatelessWidget {
  const GradePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  Future<void> _open(BuildContext context) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (ctx) => _PickerSheet(label: label, options: options),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      onTap: () => _open(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          suffixIcon: const Icon(Icons.expand_more, size: 20),
        ),
        child: Text(
          value.isEmpty ? '—' : value,
          style: value.isEmpty
              ? AppTypography.bodyMuted
              : AppTypography.body.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _PickerSheet extends StatefulWidget {
  const _PickerSheet({required this.label, required this.options});
  final String label;
  final List<String> options;

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  final _custom = TextEditingController();

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: AppSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select ${widget.label}', style: AppTypography.h2),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final o in widget.options)
                  ActionChip(
                    label: Text(o),
                    backgroundColor: context.surfaceAlt,
                    onPressed: () => Navigator.pop(context, o),
                  ),
              ],
            ),
            const Divider(height: AppSpacing.xl),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _custom,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    hintText: 'Type a new code…',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton(
                onPressed: () {
                  final v = _custom.text.trim().toUpperCase();
                  if (v.isNotEmpty) Navigator.pop(context, v);
                },
                style: FilledButton.styleFrom(
                    minimumSize: const Size(64, 44)),
                child: const Text('Add'),
              ),
            ]),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
