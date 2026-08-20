import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/persistence/local_store.dart';
import '../../evaluation/domain/entities/enums.dart';
import '../domain/lot.dart';
import 'lot_providers.dart';

/// Add a lot that isn't on the published list (TE-034). In this mock it is a
/// REAL create: the lot is added to the session store and appears in the Lots
/// tab immediately, then you drop straight into evaluating it.
class AddLotPage extends ConsumerStatefulWidget {
  const AddLotPage({super.key, required this.tenderId});
  final String tenderId;

  @override
  ConsumerState<AddLotPage> createState() => _AddLotPageState();
}

class _AddLotPageState extends ConsumerState<AddLotPage> {
  final _ref = TextEditingController();
  final _name = TextEditingController();
  final _pcs = TextEditingController(text: '1');
  final _carats = TextEditingController();

  @override
  void dispose() {
    for (final c in [_ref, _name, _pcs, _carats]) {
      c.dispose();
    }
    super.dispose();
  }

  void _add() {
    final ref = _ref.text.trim();
    if (ref.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a lot ref')),
      );
      return;
    }
    final id = 'new-${const Uuid().v4().substring(0, 8)}';
    final lot = Lot(
      id: id,
      tenderId: widget.tenderId,
      lotRef: ref.toUpperCase(),
      sizeRange: 'off-list',
      lotName: _name.text.trim().isEmpty ? 'New lot' : _name.text.trim(),
      publishedPieces: int.tryParse(_pcs.text.trim()) ?? 1,
      publishedCarats: double.tryParse(_carats.text.trim()) ?? 0,
      weighedCarats: double.tryParse(_carats.text.trim()),
      willBid: true,
      workStatus: LotWorkStatus.inProgress,
    );
    MockData.addLot(lot);
    LocalStore.I.persistLots(); // survives restart
    // The Lots tab reads this provider — refresh so the new lot appears.
    this.ref.invalidate(lotsProvider(widget.tenderId));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lot ${lot.lotRef} created')),
    );
    // Go straight into evaluating the new lot.
    context.go('/tender/${widget.tenderId}/lot/$id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/tender/${widget.tenderId}'),
        ),
        title: const Text('Add lot (not on list)'),
      ),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          Text('Off-list lot', style: AppTypography.label),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _ref,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(labelText: 'Lot ref *'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _name,
            decoration:
                const InputDecoration(labelText: 'Lot name / description'),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _pcs,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Pieces'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextField(
                controller: _carats,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Carats'),
              ),
            ),
          ]),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: _add,
            icon: const Icon(Icons.add),
            label: const Text('Add lot & start evaluating'),
          ),
        ],
      ),
    );
  }
}
