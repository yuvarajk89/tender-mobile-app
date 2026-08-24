import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/persistence/local_store.dart';
import '../domain/lot.dart';
import 'lot_providers.dart';

/// Lots in a tender — the "Lots" tab body (hosted by TenderShellPage, so no
/// Scaffold/AppBar of its own). Built for the table: **jump to any lot number**
/// (never sequential, TE-030) + a Will-Bid filter.
class LotListBody extends ConsumerStatefulWidget {
  const LotListBody({super.key, required this.tenderId});
  final String tenderId;

  @override
  ConsumerState<LotListBody> createState() => _LotListBodyState();
}

class _LotListBodyState extends ConsumerState<LotListBody> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Toggle a lot's Will-Bid + show a confirmation with UNDO.
  void _toggleWillBid(Lot lot) {
    MockData.toggleWillBid(lot);
    LocalStore.I.persistWillBid();
    setState(() {});
    final on = MockData.willBid(lot);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(on
            ? '${lot.lotRef} marked Will Bid'
            : '${lot.lotRef} removed from Will Bid'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            MockData.toggleWillBid(lot);
            LocalStore.I.persistWillBid();
            setState(() {});
          },
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final lotsAsync = ref.watch(lotsProvider(widget.tenderId));
    final willBidOnly = ref.watch(willBidFilterProvider);
    final query = _search.text.trim().toUpperCase();

    return ResponsiveContent(
      child: Column(
        children: [
          // Filter bar — jump-to-lot + Will-Bid.
          Padding(
            padding: AppSpacing.page,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Jump to lot no…',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                FilterChip(
                  label: const Text('Will bid'),
                  selected: willBidOnly,
                  onSelected: (v) =>
                      ref.read(willBidFilterProvider.notifier).state = v,
                  selectedColor: context.scheme.primaryContainer,
                  checkmarkColor: context.scheme.onPrimaryContainer,
                ),
              ],
            ),
          ),
          Expanded(
            child: lotsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState(
                  icon: Icons.error_outline,
                  title: 'Could not load lots',
                  message: '$e'),
              data: (lots) {
                var filtered = willBidOnly
                    ? lots.where((l) => MockData.willBid(l)).toList()
                    : lots;
                if (query.isNotEmpty) {
                  filtered = filtered
                      .where((l) =>
                          l.lotRef.toUpperCase().contains(query) ||
                          l.lotName.toUpperCase().contains(query))
                      .toList();
                }
                if (filtered.isEmpty) {
                  return const EmptyState(
                      icon: Icons.grid_view_outlined,
                      title: 'No lots match',
                      message: 'Clear the filter or search, or add a lot.');
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, 0, AppSpacing.lg, 96),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, i) => _LotTile(
                    lot: filtered[i],
                    onToggleWillBid: () => _toggleWillBid(filtered[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LotTile extends StatelessWidget {
  const _LotTile({required this.lot, required this.onToggleWillBid});
  final Lot lot;
  final VoidCallback onToggleWillBid;

  (Color, String) get _status {
    final st = MockData.captureStatus(lot.id);
    if (st != 'todo' && !MockData.isReconciled(lot)) {
      return (AppColors.warning, '⚠ not reconciled');
    }
    return switch (st) {
      'estimated' => (AppColors.success, 'Estimated'),
      'captured' => (AppColors.info, 'In estimate'),
      _ => (AppColors.statusPending, 'To capture'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusLabel) = _status;
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      onTap: () => context.go('/tender/${lot.tenderId}/lot/${lot.id}'),
      onLongPress: () => _showMenu(context),
      child: SectionCard(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            _thumb(context, statusColor),
            const SizedBox(width: AppSpacing.md),
            // lot ref + name get the FULL width now (no inline chip).
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lot.lotRef,
                      style: AppTypography.title,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${lot.lotName} · ${lot.sizeRange}',
                      style: AppTypography.caption,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Row(children: [
                    Text(Fmt.carats(lot.workingCarats),
                        style: AppTypography.caption
                            .copyWith(fontWeight: FontWeight.w700)),
                    Text('  ·  ${lot.publishedPieces} pc  ·  $statusLabel',
                        style: AppTypography.caption),
                  ]),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _willBidStar(context),
          ],
        ),
      ),
    );
  }

  /// Long-press menu: quick actions without opening the lot.
  void _showMenu(BuildContext context) {
    final on = MockData.willBid(lot);
    showModalBottomSheet(
      context: context,
      backgroundColor: context.scheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: AppSpacing.page,
            child: Row(children: [
              Expanded(
                child: Text('${lot.lotRef} · ${lot.lotName}',
                    style: AppTypography.title, overflow: TextOverflow.ellipsis),
              ),
            ]),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(on ? Icons.star_rounded : Icons.star_outline_rounded,
                color: on ? AppColors.accent : context.scheme.outline),
            title: Text(on ? 'Remove from Will Bid' : 'Mark as Will Bid'),
            onTap: () {
              onToggleWillBid();
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            leading: Icon(Icons.camera_alt_outlined, color: context.scheme.primary),
            title: const Text('Open & capture'),
            onTap: () {
              Navigator.pop(ctx);
              context.go('/tender/${lot.tenderId}/lot/${lot.id}');
            },
          ),
          const SizedBox(height: AppSpacing.sm),
        ]),
      ),
    );
  }

  /// Will-Bid shortlist toggle — a star on the far right. Gold filled = will bid,
  /// grey outline = not. Doesn't steal width from the lot name.
  Widget _willBidStar(BuildContext context) {
    final on = MockData.willBid(lot);
    return GestureDetector(
      onTap: onToggleWillBid,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? context.scheme.primaryContainer : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          on ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 26,
          color: on ? AppColors.accent : context.scheme.outline,
        ),
      ),
    );
  }

  /// Leading thumbnail: the first captured photo, else a diamond placeholder,
  /// with a status dot and a photo-count badge.
  Widget _thumb(BuildContext context, Color statusColor) {
    final photo = MockData.firstPhoto(lot.id);
    final photos = MockData.photoCount(lot.id);
    return SizedBox(
      width: 46,
      height: 46,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: photo != null
                ? Image.memory(photo, width: 46, height: 46, fit: BoxFit.cover)
                : Container(
                    width: 46,
                    height: 46,
                    color: context.surfaceAlt,
                    child: Icon(Icons.diamond_outlined,
                        size: 22, color: context.scheme.outline),
                  ),
          ),
          // status dot
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  color: context.scheme.surface, shape: BoxShape.circle),
              child: Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: statusColor, shape: BoxShape.circle),
              ),
            ),
          ),
          // photo count badge
          if (photos > 0)
            Positioned(
              left: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                    color: AppColors.info,
                    borderRadius: BorderRadius.circular(8)),
                child: Text('$photos',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }
}
