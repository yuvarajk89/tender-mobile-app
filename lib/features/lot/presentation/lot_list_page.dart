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
import '../../evaluation/domain/entities/enums.dart';
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
                var filtered =
                    willBidOnly ? lots.where((l) => l.willBid).toList() : lots;
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
                  itemBuilder: (_, i) => _LotTile(lot: filtered[i]),
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
  const _LotTile({required this.lot});
  final Lot lot;

  (Color, String) get _status {
    // Saved stones make a lot "done" and drive the count shown.
    final n = MockData.stoneCount(lot.id);
    if (n > 0) return (AppColors.statusDone, '$n stone${n > 1 ? 's' : ''}');
    return switch (lot.workStatus) {
      LotWorkStatus.done => (AppColors.statusDone, 'Done'),
      LotWorkStatus.inProgress => (AppColors.warning, 'In progress'),
      LotWorkStatus.notStarted => (AppColors.statusPending, 'Not started'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusLabel) = _status;
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      onTap: () => context.go('/tender/${lot.tenderId}/lot/${lot.id}'),
      child: SectionCard(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            _thumb(context, statusColor),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(lot.lotRef,
                          style: AppTypography.title,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (lot.willBid) const PillTag(text: 'WILL BID'),
                  ]),
                  const SizedBox(height: 2),
                  Text('${lot.lotName} · ${lot.sizeRange}',
                      style: AppTypography.caption,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(Fmt.carats(lot.workingCarats), style: AppTypography.numeric),
                Text('${lot.publishedPieces} pc · $statusLabel',
                    style: AppTypography.caption),
              ],
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: context.scheme.outline),
          ],
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
