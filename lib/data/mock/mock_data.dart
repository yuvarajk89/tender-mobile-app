import 'dart:typed_data';
import '../../features/evaluation/domain/entities/enums.dart';
import '../../features/evaluation/domain/entities/lot_plan.dart';
import '../../features/evaluation/domain/entities/lot_row.dart';
import '../../features/lot/domain/lot.dart';
import '../../features/tender/domain/tender.dart';

/// In-memory sample data for the UI simulation. Numbers are lifted from the
/// BRD's real Feb-2026 Belgium workbook so the client sees a familiar picture.
///
/// This is the ONLY place mock data lives. When the live API is wired, the mock
/// repositories that read this file are swapped for HTTP ones — nothing in the
/// UI or domain changes. See docs/05-DATA-LAYER.md.
class MockData {
  MockData._();

  // Dates are computed relative to "today" so the tenders always look current
  // (upcoming viewings / closures), never a stale February.
  static final DateTime _base = DateTime.now();
  static DateTime _at(int daysFromNow, int hour) {
    final d = _base.add(Duration(days: daysFromNow));
    return DateTime(d.year, d.month, d.day, hour);
  }

  static final List<Tender> tenders = [
    Tender(
      id: 't1',
      saleCode: 'BST-2601-B',
      house: 'BURGUNDY',
      mine: 'Ekati',
      origin: 'Ekati, Canada',
      viewingsStart: _at(0, 9),
      closure: _at(3, 15),
      biddingPlatform: 'rough.bonasbids.com',
      declaredCarats: 4378.96,
      lotCount: 3,
      willBidCount: 3,
      doneCount: 2,
    ),
    Tender(
      id: 't2',
      saleCode: 'BST-2601-A',
      house: 'FE',
      mine: 'Ekati',
      origin: 'Ekati, Canada',
      viewingsStart: _at(0, 9),
      closure: _at(4, 15),
      biddingPlatform: 'rough.bonasbids.com',
      declaredCarats: 308266.84,
      lotCount: 3,
      willBidCount: 2,
      doneCount: 1,
    ),
    Tender(
      id: 't3',
      saleCode: 'BST-2603-A',
      house: 'LUCARA',
      mine: 'Karowe',
      origin: 'Karowe, Botswana',
      viewingsStart: _at(2, 9),
      closure: _at(6, 15),
      biddingPlatform: 'rough.bonasbids.com',
      declaredCarats: 12045.10,
      lotCount: 1,
      willBidCount: 1,
      doneCount: 0,
    ),
  ];

  static final List<Lot> lots = [
    // --- BURGUNDY lot 117: single fancy yellow, cleavage into 2 stones. ---
    Lot(
      id: 'l117',
      tenderId: 't1',
      lotRef: 'BST-2601-B-117',
      sizeRange: '+10.80CT',
      lotName: 'SINGLE COLOURED GEM',
      publishedPieces: 1,
      publishedCarats: 39.39,
      weighedCarats: 39.39,
      willBid: true,
      workStatus: LotWorkStatus.done,
      openingPrice: 2842,
      ourBidPerCt: 3191.75,
      outcome: LotOutcome.pending,
      plans: [
        LotPlan(
          id: 'p117a',
          lotId: 'l117',
          label: 'Cleavage — oval + pear',
          isActive: true,
          rows: [
            const LotRow(
              id: 'r117-1',
              planId: 'p117a',
              parentRowId: null,
              pieces: 1,
              roughCarats: 39.39,
              colour: 'FVOY',
              clarity: 'VS',
              fluor: 'NON',
              shape: 'OVL',
              note: 'header — rough carried here',
            ),
            const LotRow(
              id: 'r117-2',
              planId: 'p117a',
              parentRowId: 'r117-1',
              pieces: 1,
              usesParentRough: true,
              colour: 'FVOY',
              clarity: 'VS',
              fluor: 'NON',
              shape: 'OVL',
              note: '4.73 or 4.30 EM',
              yieldPct: 11,
              pricePerPolishedCt: 28000,
            ),
            const LotRow(
              id: 'r117-3',
              planId: 'p117a',
              parentRowId: 'r117-1',
              pieces: 1,
              usesParentRough: true,
              colour: 'FVY',
              clarity: 'VS',
              fluor: 'NON',
              shape: 'PEAR',
              yieldPct: 5,
              pricePerPolishedCt: 13500,
            ),
          ],
        ),
      ],
    ),

    // --- FE lot 47: the "OR" — two competing cutting plans. ---
    Lot(
      id: 'l47',
      tenderId: 't2',
      lotRef: 'BST-2601-A-047',
      sizeRange: '4-8GR',
      lotName: 'YELLOW MIX',
      publishedPieces: 1,
      publishedCarats: 24.45,
      weighedCarats: 24.45,
      willBid: true,
      workStatus: LotWorkStatus.inProgress,
      plans: [
        LotPlan(
          id: 'p47a',
          lotId: 'l47',
          label: 'Plan A — two stones',
          isActive: true,
          rows: [
            // Header carries the single rough; both stones are cut from it.
            const LotRow(
              id: 'r47a-0',
              planId: 'p47a',
              pieces: 1,
              roughCarats: 24.45,
              note: 'one rough → two stones',
            ),
            const LotRow(
              id: 'r47a-1',
              planId: 'p47a',
              parentRowId: 'r47a-0',
              pieces: 1,
              usesParentRough: true,
              colour: 'FY',
              clarity: 'VS',
              fluor: 'NON',
              shape: 'RAD',
              yieldPct: 32,
              pricePerPolishedCt: 8000,
            ),
            const LotRow(
              id: 'r47a-2',
              planId: 'p47a',
              parentRowId: 'r47a-0',
              pieces: 1,
              usesParentRough: true,
              colour: 'FLY',
              clarity: 'VS',
              fluor: 'NON',
              shape: 'RAD',
              yieldPct: 23.6,
              pricePerPolishedCt: 5500,
            ),
          ],
        ),
        LotPlan(
          id: 'p47b',
          lotId: 'l47',
          label: 'Plan B — one big stone',
          isActive: false,
          rows: [
            const LotRow(
              id: 'r47b-1',
              planId: 'p47b',
              pieces: 1,
              roughCarats: 24.45,
              colour: 'FY+',
              clarity: 'SI1',
              fluor: 'CBLK',
              shape: 'LONG CU',
              yieldPct: 53.4,
              pricePerPolishedCt: 5500,
            ),
          ],
        ),
      ],
    ),

    // --- FE lot 36: sub-lots + a bunch (4 stones as one row). ---
    Lot(
      id: 'l36',
      tenderId: 't2',
      lotRef: 'BST-2601-A-036',
      sizeRange: '4-8GR',
      lotName: 'MIX YELLOW MIX',
      publishedPieces: 8,
      publishedCarats: 16.49,
      weighedCarats: 16.20, // buyer's own weight differs → mismatch warning (TE-033)
      willBid: true,
      workStatus: LotWorkStatus.notStarted,
      plans: [
        LotPlan(
          id: 'p36a',
          lotId: 'l36',
          label: 'Sorted — 4 singles + 1 bunch',
          isActive: true,
          rows: [
            const LotRow(id: 'r36-1', planId: 'p36a', pieces: 1, roughCarats: 4.30, colour: 'FLY', clarity: 'VS', fluor: 'NON', yieldPct: 27, pricePerPolishedCt: 1500),
            const LotRow(id: 'r36-2', planId: 'p36a', pieces: 1, roughCarats: 2.20, colour: 'FLY', clarity: 'VS', fluor: 'NON', shape: 'FLAT', yieldPct: 33, pricePerPolishedCt: 550),
            const LotRow(id: 'r36-3', planId: 'p36a', pieces: 1, roughCarats: 2.21, colour: 'FY', clarity: 'VS', fluor: 'NON', yieldPct: 40, pricePerPolishedCt: 800),
            const LotRow(id: 'r36-4', planId: 'p36a', pieces: 1, roughCarats: 2.81, colour: 'YZ', clarity: 'VS', fluor: 'NON', yieldPct: 35, pricePerPolishedCt: 600),
            const LotRow(id: 'r36-5', planId: 'p36a', pieces: 4, roughCarats: 4.96, colour: 'YZ', clarity: 'SI2', fluor: 'NON', yieldPct: 20, pricePerPolishedCt: 100, note: '4 stones as one bunch'),
          ],
        ),
      ],
    ),

    // --- FE lot 197: pure rough — no polish estimate, bid from judgement. ---
    Lot(
      id: 'l197',
      tenderId: 't2',
      lotRef: 'BST-2601-A-197',
      sizeRange: '+10.80CT',
      lotName: 'ROUGH PARCEL',
      publishedPieces: 1,
      publishedCarats: 86.82,
      weighedCarats: 86.82,
      willBid: false,
      workStatus: LotWorkStatus.notStarted,
      plans: [
        LotPlan(
          id: 'p197a',
          lotId: 'l197',
          label: 'Pure rough',
          isActive: true,
          rows: [
            const LotRow(
              id: 'r197-1',
              planId: 'p197a',
              pieces: 1,
              roughCarats: 86.82,
              colour: 'FBY',
              clarity: 'I3',
              category: ValuationCategory.pureRough,
              directRoughPerCt: 81,
              note: 'coating / inclusion — priced as rough only',
            ),
          ],
        ),
      ],
    ),

    // --- LUCARA lot 9: rejection (published as worthless). ---
    Lot(
      id: 'l9',
      tenderId: 't3',
      lotRef: 'BST-2603-A-009',
      sizeRange: '4-8GR',
      lotName: 'REJECTION',
      publishedPieces: 9,
      publishedCarats: 173.38,
      willBid: false,
      workStatus: LotWorkStatus.notStarted,
      plans: [
        LotPlan(
          id: 'p9a',
          lotId: 'l9',
          label: 'Rejection',
          isActive: true,
          rows: [
            const LotRow(
              id: 'r9-1',
              planId: 'p9a',
              pieces: 9,
              roughCarats: 173.38,
              category: ValuationCategory.rejection,
              note: 'house-declared rejection',
            ),
          ],
        ),
      ],
    ),
  ];

  static List<Lot> lotsForTender(String tenderId) =>
      lots.where((l) => l.tenderId == tenderId).toList();

  // ── Session store (mutable) ─────────────────────────────────────────
  // Makes the mock behave like a real app WITHIN a session: lots you create
  // and stones you save are held in memory so the create → see → evaluate flow
  // actually works. Cleared when the app restarts (no disk persistence yet).

  /// Stones saved per lot from the terminal, keyed by lot id. Each stone is a
  /// plain map (see PocLotEntryPage `_Stone.toMap`).
  static final Map<String, List<Map<String, dynamic>>> savedStones = {};

  /// The Capture tab's "unattached" photo tray (raw image bytes), session-only.
  static final List<Uint8List> trayImages = [];

  /// Add a newly-created (off-list) lot so it shows up in the Lots tab.
  static void addLot(Lot lot) => lots.add(lot);

  /// How many stones have been saved on a lot (0 if none).
  static int stoneCount(String lotId) => savedStones[lotId]?.length ?? 0;
}
