import 'dart:typed_data';
import '../../features/lot/domain/lot.dart';
import '../../features/tender/domain/tender.dart';

/// Mock dataset — 10 tenders. BDM-2604 (BURGUNDY) is real, parsed from the
/// Bonas "List of Goods" PDF (49 lots, valid weight / stone-count / size / name).
/// The other 9 are clean sample tenders. Lots start un-captured; the buyer adds
/// photos + grade + inputs on the phone (persisted via LocalStore).
class MockData {
  MockData._();

  static final DateTime _base = DateTime.now();
  static DateTime _at(int daysFromNow, int hour) {
    final d = _base.add(Duration(days: daysFromNow));
    return DateTime(d.year, d.month, d.day, hour);
  }

  static final List<Tender> tenders = [
    Tender(id: 't1', saleCode: 'BDM-2604', house: 'BURGUNDY', mine: 'Ekati', origin: 'Ekati, Canada', viewingsStart: _at(0, 9), closure: _at(3, 15), biddingPlatform: 'burgundybids.com', declaredCarats: 15503.09, lotCount: 49, willBidCount: 18, doneCount: 0),
    Tender(id: 't2', saleCode: 'BST-2601-B', house: 'BONAS', mine: 'Ekati', origin: 'Ekati, Canada', viewingsStart: _at(-1, 9), closure: _at(1, 15), biddingPlatform: 'burgundybids.com', declaredCarats: 912.9, lotCount: 15, willBidCount: 7, doneCount: 0),
    Tender(id: 't3', saleCode: 'LLD-2606', house: 'LUCARA', mine: 'Karowe', origin: 'Karowe, Botswana', viewingsStart: _at(0, 9), closure: _at(2, 15), biddingPlatform: 'lucara.bidx.com', declaredCarats: 912.9, lotCount: 15, willBidCount: 7, doneCount: 0),
    Tender(id: 't4', saleCode: 'ALR-4726', house: 'ALROSA', mine: 'Mirny', origin: 'Mirny, Russia', viewingsStart: _at(1, 9), closure: _at(3, 15), biddingPlatform: 'alrosa.bids.com', declaredCarats: 912.9, lotCount: 15, willBidCount: 7, doneCount: 0),
    Tender(id: 't5', saleCode: 'DBS-2603', house: 'DE BEERS', mine: 'Jwaneng', origin: 'Jwaneng, Botswana', viewingsStart: _at(2, 9), closure: _at(4, 15), biddingPlatform: 'debeersgroup.bids', declaredCarats: 912.9, lotCount: 15, willBidCount: 7, doneCount: 0),
    Tender(id: 't6', saleCode: 'PET-CDM26', house: 'PETRA', mine: 'Cullinan', origin: 'Cullinan, South Africa', viewingsStart: _at(3, 9), closure: _at(5, 15), biddingPlatform: 'petra.bidx.com', declaredCarats: 912.9, lotCount: 15, willBidCount: 7, doneCount: 0),
    Tender(id: 't7', saleCode: 'GDL-2606', house: 'GEM DIAMONDS', mine: 'Letseng', origin: 'Letseng, Lesotho', viewingsStart: _at(0, 9), closure: _at(2, 15), biddingPlatform: 'gemdiamonds.bids', declaredCarats: 912.9, lotCount: 15, willBidCount: 7, doneCount: 0),
    Tender(id: 't8', saleCode: 'WIL-2606', house: 'WILLIAMSON', mine: 'Mwadui', origin: 'Mwadui, Tanzania', viewingsStart: _at(1, 9), closure: _at(3, 15), biddingPlatform: 'williamson.bidx', declaredCarats: 912.9, lotCount: 15, willBidCount: 7, doneCount: 0),
    Tender(id: 't9', saleCode: 'TAGS-Q3', house: 'TAGS', mine: 'Dubai', origin: 'Dubai, UAE', viewingsStart: _at(2, 9), closure: _at(4, 15), biddingPlatform: 'tagsauctions.com', declaredCarats: 912.9, lotCount: 15, willBidCount: 7, doneCount: 0),
    Tender(id: 't10', saleCode: 'GRIB-2606', house: 'GRIB', mine: 'Grib', origin: 'Grib, Russia', viewingsStart: _at(4, 9), closure: _at(6, 15), biddingPlatform: 'gribdiamonds.bids', declaredCarats: 912.9, lotCount: 15, willBidCount: 7, doneCount: 0),
  ];

  static final List<Lot> lots = [
    Lot(id: 'l_001', tenderId: 't1', lotRef: 'BDM-2604-001', sizeRange: '+10.80CT', lotName: 'SINGLE FANCY YELLOW', publishedPieces: 1, publishedCarats: 18.63, willBid: true),
    Lot(id: 'l_002', tenderId: 't1', lotRef: 'BDM-2604-002', sizeRange: '+10.80CT', lotName: 'SINGLE CLIVAGE WHITE', publishedPieces: 1, publishedCarats: 17.04, willBid: true),
    Lot(id: 'l_003', tenderId: 't1', lotRef: 'BDM-2604-003', sizeRange: '+10.80CT', lotName: 'SINGLE LIGHT BROWN', publishedPieces: 1, publishedCarats: 14.21, willBid: true),
    Lot(id: 'l_004', tenderId: 't1', lotRef: 'BDM-2604-004', sizeRange: '+10.80CT', lotName: 'SINGLE LIGHT BROWN', publishedPieces: 1, publishedCarats: 12.96, willBid: true),
    Lot(id: 'l_005', tenderId: 't1', lotRef: 'BDM-2604-005', sizeRange: '+10.80CT', lotName: 'SINGLE FANCY YELLOW', publishedPieces: 1, publishedCarats: 12.2, willBid: true),
    Lot(id: 'l_006', tenderId: 't1', lotRef: 'BDM-2604-006', sizeRange: '+10.80CT', lotName: 'SINGLE COLOURED', publishedPieces: 1, publishedCarats: 12.03, willBid: true),
    Lot(id: 'l_007', tenderId: 't1', lotRef: 'BDM-2604-007', sizeRange: '+10.80CT', lotName: 'SINGLE COLOURED', publishedPieces: 1, publishedCarats: 11.81, willBid: true),
    Lot(id: 'l_008', tenderId: 't1', lotRef: 'BDM-2604-008', sizeRange: '6CT', lotName: 'SINGLE TYPE IIa WHITE', publishedPieces: 1, publishedCarats: 6.58, willBid: true),
    Lot(id: 'l_009', tenderId: 't1', lotRef: 'BDM-2604-009', sizeRange: '+10.80CT', lotName: 'CLIVAGE BASKET', publishedPieces: 3, publishedCarats: 39.03, willBid: false),
    Lot(id: 'l_010', tenderId: 't1', lotRef: 'BDM-2604-010', sizeRange: '+10.80CT', lotName: 'BROWN CLIVAGE BASKET', publishedPieces: 5, publishedCarats: 72.58, willBid: false),
    Lot(id: 'l_011', tenderId: 't1', lotRef: 'BDM-2604-011', sizeRange: '5-7CT', lotName: 'Z HIGH', publishedPieces: 7, publishedCarats: 40.59, willBid: false),
    Lot(id: 'l_012', tenderId: 't1', lotRef: 'BDM-2604-012', sizeRange: '5-9CT', lotName: 'Z SPOTTED', publishedPieces: 11, publishedCarats: 65.28, willBid: false),
    Lot(id: 'l_013', tenderId: 't1', lotRef: 'BDM-2604-013', sizeRange: '5-9CT', lotName: 'MB GEM', publishedPieces: 8, publishedCarats: 55.78, willBid: true),
    Lot(id: 'l_014', tenderId: 't1', lotRef: 'BDM-2604-014', sizeRange: '5-10CT', lotName: 'CLIVAGE HIGH', publishedPieces: 20, publishedCarats: 131.75, willBid: false),
    Lot(id: 'l_015', tenderId: 't1', lotRef: 'BDM-2604-015', sizeRange: '2.5-4CT', lotName: 'Z HIGH', publishedPieces: 57, publishedCarats: 182.9, willBid: false),
    Lot(id: 'l_016', tenderId: 't1', lotRef: 'BDM-2604-016', sizeRange: '2.5-4CT', lotName: 'Z SPOTTED', publishedPieces: 64, publishedCarats: 201.45, willBid: false),
    Lot(id: 'l_017', tenderId: 't1', lotRef: 'BDM-2604-017', sizeRange: '2.5-4CT', lotName: 'MB GEM', publishedPieces: 50, publishedCarats: 157.15, willBid: true),
    Lot(id: 'l_018', tenderId: 't1', lotRef: 'BDM-2604-018', sizeRange: '2.5-7CT', lotName: 'Z/MB COATED GEM', publishedPieces: 14, publishedCarats: 51.95, willBid: true),
    Lot(id: 'l_019', tenderId: 't1', lotRef: 'BDM-2604-019', sizeRange: '2.5-10CT', lotName: 'COLOURED GEM', publishedPieces: 44, publishedCarats: 232.21, willBid: true),
    Lot(id: 'l_020', tenderId: 't1', lotRef: 'BDM-2604-020', sizeRange: '3-6CT', lotName: 'LIGHT BROWN GEM', publishedPieces: 14, publishedCarats: 49.22, willBid: true),
    Lot(id: 'l_021', tenderId: 't1', lotRef: 'BDM-2604-021', sizeRange: '2.5-6CT', lotName: 'BROWN GEM', publishedPieces: 35, publishedCarats: 125.6, willBid: true),
    Lot(id: 'l_022', tenderId: 't1', lotRef: 'BDM-2604-022', sizeRange: '2.5-7CT', lotName: 'BLACK Z', publishedPieces: 42, publishedCarats: 148.39, willBid: false),
    Lot(id: 'l_023', tenderId: 't1', lotRef: 'BDM-2604-023', sizeRange: '2.5-4CT', lotName: 'CLIVAGE HIGH', publishedPieces: 99, publishedCarats: 332.46, willBid: false),
    Lot(id: 'l_024', tenderId: 't1', lotRef: 'BDM-2604-024', sizeRange: '2.5-10CT', lotName: 'COLOURED CLIVAGE', publishedPieces: 28, publishedCarats: 123.35, willBid: false),
    Lot(id: 'l_025', tenderId: 't1', lotRef: 'BDM-2604-025', sizeRange: '2.5-8CT', lotName: 'CLIVAGE MIXED', publishedPieces: 94, publishedCarats: 351.72, willBid: false),
    Lot(id: 'l_026', tenderId: 't1', lotRef: 'BDM-2604-026', sizeRange: '2.5-7CT', lotName: 'LIGHT BROWN CLIVAGE', publishedPieces: 35, publishedCarats: 128.18, willBid: false),
    Lot(id: 'l_027', tenderId: 't1', lotRef: 'BDM-2604-027', sizeRange: '2.5-10CT', lotName: 'BROWN CLIVAGE', publishedPieces: 262, publishedCarats: 1000.77, willBid: false),
    Lot(id: 'l_028', tenderId: 't1', lotRef: 'BDM-2604-028', sizeRange: '+2.5CT', lotName: 'REJECTIONS/BT', publishedPieces: 250, publishedCarats: 1055.8, willBid: false),
    Lot(id: 'l_029', tenderId: 't1', lotRef: 'BDM-2604-029', sizeRange: '8GR', lotName: 'Z HIGH', publishedPieces: 44, publishedCarats: 93.78, willBid: false),
    Lot(id: 'l_030', tenderId: 't1', lotRef: 'BDM-2604-030', sizeRange: '4-6GR', lotName: 'Z HIGH', publishedPieces: 227, publishedCarats: 280.89, willBid: false),
    Lot(id: 'l_031', tenderId: 't1', lotRef: 'BDM-2604-031', sizeRange: '8GR', lotName: 'Z SPOTTED', publishedPieces: 62, publishedCarats: 130.08, willBid: false),
    Lot(id: 'l_032', tenderId: 't1', lotRef: 'BDM-2604-032', sizeRange: '4-6GR', lotName: 'Z SPOTTED', publishedPieces: 249, publishedCarats: 315.42, willBid: false),
    Lot(id: 'l_033', tenderId: 't1', lotRef: 'BDM-2604-033', sizeRange: '4-8GR', lotName: 'MB HIGH', publishedPieces: 126, publishedCarats: 164.55, willBid: false),
    Lot(id: 'l_034', tenderId: 't1', lotRef: 'BDM-2604-034', sizeRange: '4-8GR', lotName: 'MB SPOTTED', publishedPieces: 135, publishedCarats: 194.09, willBid: false),
    Lot(id: 'l_035', tenderId: 't1', lotRef: 'BDM-2604-035', sizeRange: '4-8GR', lotName: 'FANCY SHAPES', publishedPieces: 151, publishedCarats: 204.31, willBid: false),
    Lot(id: 'l_036', tenderId: 't1', lotRef: 'BDM-2604-036', sizeRange: '3-8GR', lotName: 'Z/MB COLLECTION', publishedPieces: 110, publishedCarats: 133.33, willBid: false),
    Lot(id: 'l_037', tenderId: 't1', lotRef: 'BDM-2604-037', sizeRange: '4-8GR', lotName: 'Z/MB COATED GEM', publishedPieces: 50, publishedCarats: 69.17, willBid: true),
    Lot(id: 'l_038', tenderId: 't1', lotRef: 'BDM-2604-038', sizeRange: '4-8GR', lotName: 'Z/MB FLUOR', publishedPieces: 298, publishedCarats: 402.27, willBid: false),
    Lot(id: 'l_039', tenderId: 't1', lotRef: 'BDM-2604-039', sizeRange: '4-8GR', lotName: 'COLOURED GEM', publishedPieces: 189, publishedCarats: 260.42, willBid: true),
    Lot(id: 'l_040', tenderId: 't1', lotRef: 'BDM-2604-040', sizeRange: '4-8GR', lotName: 'LIGHT BROWN GEM', publishedPieces: 158, publishedCarats: 201.6, willBid: true),
    Lot(id: 'l_041', tenderId: 't1', lotRef: 'BDM-2604-041', sizeRange: '4-8GR', lotName: 'BROWN GEM', publishedPieces: 475, publishedCarats: 610.86, willBid: true),
    Lot(id: 'l_042', tenderId: 't1', lotRef: 'BDM-2604-042', sizeRange: '4-8GR', lotName: 'BLACK Z', publishedPieces: 246, publishedCarats: 344.29, willBid: false),
    Lot(id: 'l_043', tenderId: 't1', lotRef: 'BDM-2604-043', sizeRange: '4-8GR', lotName: 'CLIVAGE HIGH', publishedPieces: 279, publishedCarats: 375.44, willBid: false),
    Lot(id: 'l_044', tenderId: 't1', lotRef: 'BDM-2604-044', sizeRange: '4-8GR', lotName: 'FLAT CLIVAGE', publishedPieces: 239, publishedCarats: 315.0, willBid: false),
    Lot(id: 'l_045', tenderId: 't1', lotRef: 'BDM-2604-045', sizeRange: '4-8GR', lotName: 'CLIVAGE MIXED', publishedPieces: 476, publishedCarats: 663.98, willBid: false),
    Lot(id: 'l_046', tenderId: 't1', lotRef: 'BDM-2604-046', sizeRange: '4-8GR', lotName: 'LIGHT BROWN CLIVAGE', publishedPieces: 271, publishedCarats: 370.68, willBid: false),
    Lot(id: 'l_047', tenderId: 't1', lotRef: 'BDM-2604-047', sizeRange: '4-8GR', lotName: 'BROWN CLIVAGE', publishedPieces: 1960, publishedCarats: 2580.22, willBid: false),
    Lot(id: 'l_048', tenderId: 't1', lotRef: 'BDM-2604-048', sizeRange: '4-8GR', lotName: 'BROWN/BLACK CLIVAGE', publishedPieces: 267, publishedCarats: 361.53, willBid: false),
    Lot(id: 'l_049', tenderId: 't1', lotRef: 'BDM-2604-049', sizeRange: '4-8GR', lotName: 'REJECTIONS/BT', publishedPieces: 2211, publishedCarats: 2779.56, willBid: false),
    Lot(id: 't2_l001', tenderId: 't2', lotRef: 'BST-2601-B-001', sizeRange: '+10.80CT', lotName: 'FANCY YELLOW', publishedPieces: 1, publishedCarats: 12.4, willBid: false),
    Lot(id: 't2_l002', tenderId: 't2', lotRef: 'BST-2601-B-002', sizeRange: '6CT', lotName: 'LIGHT BROWN', publishedPieces: 1, publishedCarats: 9.8, willBid: false),
    Lot(id: 't2_l003', tenderId: 't2', lotRef: 'BST-2601-B-003', sizeRange: '5-7CT', lotName: 'COLOURED GEM', publishedPieces: 3, publishedCarats: 45.3, willBid: true),
    Lot(id: 't2_l004', tenderId: 't2', lotRef: 'BST-2601-B-004', sizeRange: '2.5-4CT', lotName: 'CLIVAGE HIGH', publishedPieces: 20, publishedCarats: 131.7, willBid: false),
    Lot(id: 't2_l005', tenderId: 't2', lotRef: 'BST-2601-B-005', sizeRange: '2.5-10CT', lotName: 'BROWN GEM', publishedPieces: 50, publishedCarats: 182.9, willBid: true),
    Lot(id: 't2_l006', tenderId: 't2', lotRef: 'BST-2601-B-006', sizeRange: '4-8GR', lotName: 'Z SPOTTED', publishedPieces: 7, publishedCarats: 40.6, willBid: false),
    Lot(id: 't2_l007', tenderId: 't2', lotRef: 'BST-2601-B-007', sizeRange: '+10.80CT', lotName: 'MB GEM', publishedPieces: 1, publishedCarats: 12.4, willBid: true),
    Lot(id: 't2_l008', tenderId: 't2', lotRef: 'BST-2601-B-008', sizeRange: '6CT', lotName: 'WHITE GEM', publishedPieces: 1, publishedCarats: 9.8, willBid: true),
    Lot(id: 't2_l009', tenderId: 't2', lotRef: 'BST-2601-B-009', sizeRange: '5-7CT', lotName: 'FANCY YELLOW', publishedPieces: 3, publishedCarats: 45.3, willBid: false),
    Lot(id: 't2_l010', tenderId: 't2', lotRef: 'BST-2601-B-010', sizeRange: '2.5-4CT', lotName: 'LIGHT BROWN', publishedPieces: 20, publishedCarats: 131.7, willBid: false),
    Lot(id: 't2_l011', tenderId: 't2', lotRef: 'BST-2601-B-011', sizeRange: '2.5-10CT', lotName: 'COLOURED GEM', publishedPieces: 50, publishedCarats: 182.9, willBid: true),
    Lot(id: 't2_l012', tenderId: 't2', lotRef: 'BST-2601-B-012', sizeRange: '4-8GR', lotName: 'CLIVAGE HIGH', publishedPieces: 7, publishedCarats: 40.6, willBid: false),
    Lot(id: 't2_l013', tenderId: 't2', lotRef: 'BST-2601-B-013', sizeRange: '+10.80CT', lotName: 'BROWN GEM', publishedPieces: 1, publishedCarats: 12.4, willBid: true),
    Lot(id: 't2_l014', tenderId: 't2', lotRef: 'BST-2601-B-014', sizeRange: '6CT', lotName: 'Z SPOTTED', publishedPieces: 1, publishedCarats: 9.8, willBid: false),
    Lot(id: 't2_l015', tenderId: 't2', lotRef: 'BST-2601-B-015', sizeRange: '5-7CT', lotName: 'MB GEM', publishedPieces: 3, publishedCarats: 45.3, willBid: true),
    Lot(id: 't3_l001', tenderId: 't3', lotRef: 'LLD-2606-001', sizeRange: '+10.80CT', lotName: 'FANCY YELLOW', publishedPieces: 1, publishedCarats: 12.4, willBid: false),
    Lot(id: 't3_l002', tenderId: 't3', lotRef: 'LLD-2606-002', sizeRange: '6CT', lotName: 'LIGHT BROWN', publishedPieces: 1, publishedCarats: 9.8, willBid: false),
    Lot(id: 't3_l003', tenderId: 't3', lotRef: 'LLD-2606-003', sizeRange: '5-7CT', lotName: 'COLOURED GEM', publishedPieces: 3, publishedCarats: 45.3, willBid: true),
    Lot(id: 't3_l004', tenderId: 't3', lotRef: 'LLD-2606-004', sizeRange: '2.5-4CT', lotName: 'CLIVAGE HIGH', publishedPieces: 20, publishedCarats: 131.7, willBid: false),
    Lot(id: 't3_l005', tenderId: 't3', lotRef: 'LLD-2606-005', sizeRange: '2.5-10CT', lotName: 'BROWN GEM', publishedPieces: 50, publishedCarats: 182.9, willBid: true),
    Lot(id: 't3_l006', tenderId: 't3', lotRef: 'LLD-2606-006', sizeRange: '4-8GR', lotName: 'Z SPOTTED', publishedPieces: 7, publishedCarats: 40.6, willBid: false),
    Lot(id: 't3_l007', tenderId: 't3', lotRef: 'LLD-2606-007', sizeRange: '+10.80CT', lotName: 'MB GEM', publishedPieces: 1, publishedCarats: 12.4, willBid: true),
    Lot(id: 't3_l008', tenderId: 't3', lotRef: 'LLD-2606-008', sizeRange: '6CT', lotName: 'WHITE GEM', publishedPieces: 1, publishedCarats: 9.8, willBid: true),
    Lot(id: 't3_l009', tenderId: 't3', lotRef: 'LLD-2606-009', sizeRange: '5-7CT', lotName: 'FANCY YELLOW', publishedPieces: 3, publishedCarats: 45.3, willBid: false),
    Lot(id: 't3_l010', tenderId: 't3', lotRef: 'LLD-2606-010', sizeRange: '2.5-4CT', lotName: 'LIGHT BROWN', publishedPieces: 20, publishedCarats: 131.7, willBid: false),
    Lot(id: 't3_l011', tenderId: 't3', lotRef: 'LLD-2606-011', sizeRange: '2.5-10CT', lotName: 'COLOURED GEM', publishedPieces: 50, publishedCarats: 182.9, willBid: true),
    Lot(id: 't3_l012', tenderId: 't3', lotRef: 'LLD-2606-012', sizeRange: '4-8GR', lotName: 'CLIVAGE HIGH', publishedPieces: 7, publishedCarats: 40.6, willBid: false),
    Lot(id: 't3_l013', tenderId: 't3', lotRef: 'LLD-2606-013', sizeRange: '+10.80CT', lotName: 'BROWN GEM', publishedPieces: 1, publishedCarats: 12.4, willBid: true),
    Lot(id: 't3_l014', tenderId: 't3', lotRef: 'LLD-2606-014', sizeRange: '6CT', lotName: 'Z SPOTTED', publishedPieces: 1, publishedCarats: 9.8, willBid: false),
    Lot(id: 't3_l015', tenderId: 't3', lotRef: 'LLD-2606-015', sizeRange: '5-7CT', lotName: 'MB GEM', publishedPieces: 3, publishedCarats: 45.3, willBid: true),
    Lot(id: 't4_l001', tenderId: 't4', lotRef: 'ALR-4726-001', sizeRange: '+10.80CT', lotName: 'FANCY YELLOW', publishedPieces: 1, publishedCarats: 12.4, willBid: false),
    Lot(id: 't4_l002', tenderId: 't4', lotRef: 'ALR-4726-002', sizeRange: '6CT', lotName: 'LIGHT BROWN', publishedPieces: 1, publishedCarats: 9.8, willBid: false),
    Lot(id: 't4_l003', tenderId: 't4', lotRef: 'ALR-4726-003', sizeRange: '5-7CT', lotName: 'COLOURED GEM', publishedPieces: 3, publishedCarats: 45.3, willBid: true),
    Lot(id: 't4_l004', tenderId: 't4', lotRef: 'ALR-4726-004', sizeRange: '2.5-4CT', lotName: 'CLIVAGE HIGH', publishedPieces: 20, publishedCarats: 131.7, willBid: false),
    Lot(id: 't4_l005', tenderId: 't4', lotRef: 'ALR-4726-005', sizeRange: '2.5-10CT', lotName: 'BROWN GEM', publishedPieces: 50, publishedCarats: 182.9, willBid: true),
    Lot(id: 't4_l006', tenderId: 't4', lotRef: 'ALR-4726-006', sizeRange: '4-8GR', lotName: 'Z SPOTTED', publishedPieces: 7, publishedCarats: 40.6, willBid: false),
    Lot(id: 't4_l007', tenderId: 't4', lotRef: 'ALR-4726-007', sizeRange: '+10.80CT', lotName: 'MB GEM', publishedPieces: 1, publishedCarats: 12.4, willBid: true),
    Lot(id: 't4_l008', tenderId: 't4', lotRef: 'ALR-4726-008', sizeRange: '6CT', lotName: 'WHITE GEM', publishedPieces: 1, publishedCarats: 9.8, willBid: true),
    Lot(id: 't4_l009', tenderId: 't4', lotRef: 'ALR-4726-009', sizeRange: '5-7CT', lotName: 'FANCY YELLOW', publishedPieces: 3, publishedCarats: 45.3, willBid: false),
    Lot(id: 't4_l010', tenderId: 't4', lotRef: 'ALR-4726-010', sizeRange: '2.5-4CT', lotName: 'LIGHT BROWN', publishedPieces: 20, publishedCarats: 131.7, willBid: false),
    Lot(id: 't4_l011', tenderId: 't4', lotRef: 'ALR-4726-011', sizeRange: '2.5-10CT', lotName: 'COLOURED GEM', publishedPieces: 50, publishedCarats: 182.9, willBid: true),
    Lot(id: 't4_l012', tenderId: 't4', lotRef: 'ALR-4726-012', sizeRange: '4-8GR', lotName: 'CLIVAGE HIGH', publishedPieces: 7, publishedCarats: 40.6, willBid: false),
    Lot(id: 't4_l013', tenderId: 't4', lotRef: 'ALR-4726-013', sizeRange: '+10.80CT', lotName: 'BROWN GEM', publishedPieces: 1, publishedCarats: 12.4, willBid: true),
    Lot(id: 't4_l014', tenderId: 't4', lotRef: 'ALR-4726-014', sizeRange: '6CT', lotName: 'Z SPOTTED', publishedPieces: 1, publishedCarats: 9.8, willBid: false),
    Lot(id: 't4_l015', tenderId: 't4', lotRef: 'ALR-4726-015', sizeRange: '5-7CT', lotName: 'MB GEM', publishedPieces: 3, publishedCarats: 45.3, willBid: true),
    Lot(id: 't5_l001', tenderId: 't5', lotRef: 'DBS-2603-001', sizeRange: '+10.80CT', lotName: 'FANCY YELLOW', publishedPieces: 1, publishedCarats: 12.4, willBid: false),
    Lot(id: 't5_l002', tenderId: 't5', lotRef: 'DBS-2603-002', sizeRange: '6CT', lotName: 'LIGHT BROWN', publishedPieces: 1, publishedCarats: 9.8, willBid: false),
    Lot(id: 't5_l003', tenderId: 't5', lotRef: 'DBS-2603-003', sizeRange: '5-7CT', lotName: 'COLOURED GEM', publishedPieces: 3, publishedCarats: 45.3, willBid: true),
    Lot(id: 't5_l004', tenderId: 't5', lotRef: 'DBS-2603-004', sizeRange: '2.5-4CT', lotName: 'CLIVAGE HIGH', publishedPieces: 20, publishedCarats: 131.7, willBid: false),
    Lot(id: 't5_l005', tenderId: 't5', lotRef: 'DBS-2603-005', sizeRange: '2.5-10CT', lotName: 'BROWN GEM', publishedPieces: 50, publishedCarats: 182.9, willBid: true),
    Lot(id: 't5_l006', tenderId: 't5', lotRef: 'DBS-2603-006', sizeRange: '4-8GR', lotName: 'Z SPOTTED', publishedPieces: 7, publishedCarats: 40.6, willBid: false),
    Lot(id: 't5_l007', tenderId: 't5', lotRef: 'DBS-2603-007', sizeRange: '+10.80CT', lotName: 'MB GEM', publishedPieces: 1, publishedCarats: 12.4, willBid: true),
    Lot(id: 't5_l008', tenderId: 't5', lotRef: 'DBS-2603-008', sizeRange: '6CT', lotName: 'WHITE GEM', publishedPieces: 1, publishedCarats: 9.8, willBid: true),
    Lot(id: 't5_l009', tenderId: 't5', lotRef: 'DBS-2603-009', sizeRange: '5-7CT', lotName: 'FANCY YELLOW', publishedPieces: 3, publishedCarats: 45.3, willBid: false),
    Lot(id: 't5_l010', tenderId: 't5', lotRef: 'DBS-2603-010', sizeRange: '2.5-4CT', lotName: 'LIGHT BROWN', publishedPieces: 20, publishedCarats: 131.7, willBid: false),
    Lot(id: 't5_l011', tenderId: 't5', lotRef: 'DBS-2603-011', sizeRange: '2.5-10CT', lotName: 'COLOURED GEM', publishedPieces: 50, publishedCarats: 182.9, willBid: true),
    Lot(id: 't5_l012', tenderId: 't5', lotRef: 'DBS-2603-012', sizeRange: '4-8GR', lotName: 'CLIVAGE HIGH', publishedPieces: 7, publishedCarats: 40.6, willBid: false),
    Lot(id: 't5_l013', tenderId: 't5', lotRef: 'DBS-2603-013', sizeRange: '+10.80CT', lotName: 'BROWN GEM', publishedPieces: 1, publishedCarats: 12.4, willBid: true),
    Lot(id: 't5_l014', tenderId: 't5', lotRef: 'DBS-2603-014', sizeRange: '6CT', lotName: 'Z SPOTTED', publishedPieces: 1, publishedCarats: 9.8, willBid: false),
    Lot(id: 't5_l015', tenderId: 't5', lotRef: 'DBS-2603-015', sizeRange: '5-7CT', lotName: 'MB GEM', publishedPieces: 3, publishedCarats: 45.3, willBid: true),
    Lot(id: 't6_l001', tenderId: 't6', lotRef: 'PET-CDM26-001', sizeRange: '+10.80CT', lotName: 'FANCY YELLOW', publishedPieces: 1, publishedCarats: 12.4, willBid: false),
    Lot(id: 't6_l002', tenderId: 't6', lotRef: 'PET-CDM26-002', sizeRange: '6CT', lotName: 'LIGHT BROWN', publishedPieces: 1, publishedCarats: 9.8, willBid: false),
    Lot(id: 't6_l003', tenderId: 't6', lotRef: 'PET-CDM26-003', sizeRange: '5-7CT', lotName: 'COLOURED GEM', publishedPieces: 3, publishedCarats: 45.3, willBid: true),
    Lot(id: 't6_l004', tenderId: 't6', lotRef: 'PET-CDM26-004', sizeRange: '2.5-4CT', lotName: 'CLIVAGE HIGH', publishedPieces: 20, publishedCarats: 131.7, willBid: false),
    Lot(id: 't6_l005', tenderId: 't6', lotRef: 'PET-CDM26-005', sizeRange: '2.5-10CT', lotName: 'BROWN GEM', publishedPieces: 50, publishedCarats: 182.9, willBid: true),
    Lot(id: 't6_l006', tenderId: 't6', lotRef: 'PET-CDM26-006', sizeRange: '4-8GR', lotName: 'Z SPOTTED', publishedPieces: 7, publishedCarats: 40.6, willBid: false),
    Lot(id: 't6_l007', tenderId: 't6', lotRef: 'PET-CDM26-007', sizeRange: '+10.80CT', lotName: 'MB GEM', publishedPieces: 1, publishedCarats: 12.4, willBid: true),
    Lot(id: 't6_l008', tenderId: 't6', lotRef: 'PET-CDM26-008', sizeRange: '6CT', lotName: 'WHITE GEM', publishedPieces: 1, publishedCarats: 9.8, willBid: true),
    Lot(id: 't6_l009', tenderId: 't6', lotRef: 'PET-CDM26-009', sizeRange: '5-7CT', lotName: 'FANCY YELLOW', publishedPieces: 3, publishedCarats: 45.3, willBid: false),
    Lot(id: 't6_l010', tenderId: 't6', lotRef: 'PET-CDM26-010', sizeRange: '2.5-4CT', lotName: 'LIGHT BROWN', publishedPieces: 20, publishedCarats: 131.7, willBid: false),
    Lot(id: 't6_l011', tenderId: 't6', lotRef: 'PET-CDM26-011', sizeRange: '2.5-10CT', lotName: 'COLOURED GEM', publishedPieces: 50, publishedCarats: 182.9, willBid: true),
    Lot(id: 't6_l012', tenderId: 't6', lotRef: 'PET-CDM26-012', sizeRange: '4-8GR', lotName: 'CLIVAGE HIGH', publishedPieces: 7, publishedCarats: 40.6, willBid: false),
    Lot(id: 't6_l013', tenderId: 't6', lotRef: 'PET-CDM26-013', sizeRange: '+10.80CT', lotName: 'BROWN GEM', publishedPieces: 1, publishedCarats: 12.4, willBid: true),
    Lot(id: 't6_l014', tenderId: 't6', lotRef: 'PET-CDM26-014', sizeRange: '6CT', lotName: 'Z SPOTTED', publishedPieces: 1, publishedCarats: 9.8, willBid: false),
    Lot(id: 't6_l015', tenderId: 't6', lotRef: 'PET-CDM26-015', sizeRange: '5-7CT', lotName: 'MB GEM', publishedPieces: 3, publishedCarats: 45.3, willBid: true),
    Lot(id: 't7_l001', tenderId: 't7', lotRef: 'GDL-2606-001', sizeRange: '+10.80CT', lotName: 'FANCY YELLOW', publishedPieces: 1, publishedCarats: 12.4, willBid: false),
    Lot(id: 't7_l002', tenderId: 't7', lotRef: 'GDL-2606-002', sizeRange: '6CT', lotName: 'LIGHT BROWN', publishedPieces: 1, publishedCarats: 9.8, willBid: false),
    Lot(id: 't7_l003', tenderId: 't7', lotRef: 'GDL-2606-003', sizeRange: '5-7CT', lotName: 'COLOURED GEM', publishedPieces: 3, publishedCarats: 45.3, willBid: true),
    Lot(id: 't7_l004', tenderId: 't7', lotRef: 'GDL-2606-004', sizeRange: '2.5-4CT', lotName: 'CLIVAGE HIGH', publishedPieces: 20, publishedCarats: 131.7, willBid: false),
    Lot(id: 't7_l005', tenderId: 't7', lotRef: 'GDL-2606-005', sizeRange: '2.5-10CT', lotName: 'BROWN GEM', publishedPieces: 50, publishedCarats: 182.9, willBid: true),
    Lot(id: 't7_l006', tenderId: 't7', lotRef: 'GDL-2606-006', sizeRange: '4-8GR', lotName: 'Z SPOTTED', publishedPieces: 7, publishedCarats: 40.6, willBid: false),
    Lot(id: 't7_l007', tenderId: 't7', lotRef: 'GDL-2606-007', sizeRange: '+10.80CT', lotName: 'MB GEM', publishedPieces: 1, publishedCarats: 12.4, willBid: true),
    Lot(id: 't7_l008', tenderId: 't7', lotRef: 'GDL-2606-008', sizeRange: '6CT', lotName: 'WHITE GEM', publishedPieces: 1, publishedCarats: 9.8, willBid: true),
    Lot(id: 't7_l009', tenderId: 't7', lotRef: 'GDL-2606-009', sizeRange: '5-7CT', lotName: 'FANCY YELLOW', publishedPieces: 3, publishedCarats: 45.3, willBid: false),
    Lot(id: 't7_l010', tenderId: 't7', lotRef: 'GDL-2606-010', sizeRange: '2.5-4CT', lotName: 'LIGHT BROWN', publishedPieces: 20, publishedCarats: 131.7, willBid: false),
    Lot(id: 't7_l011', tenderId: 't7', lotRef: 'GDL-2606-011', sizeRange: '2.5-10CT', lotName: 'COLOURED GEM', publishedPieces: 50, publishedCarats: 182.9, willBid: true),
    Lot(id: 't7_l012', tenderId: 't7', lotRef: 'GDL-2606-012', sizeRange: '4-8GR', lotName: 'CLIVAGE HIGH', publishedPieces: 7, publishedCarats: 40.6, willBid: false),
    Lot(id: 't7_l013', tenderId: 't7', lotRef: 'GDL-2606-013', sizeRange: '+10.80CT', lotName: 'BROWN GEM', publishedPieces: 1, publishedCarats: 12.4, willBid: true),
    Lot(id: 't7_l014', tenderId: 't7', lotRef: 'GDL-2606-014', sizeRange: '6CT', lotName: 'Z SPOTTED', publishedPieces: 1, publishedCarats: 9.8, willBid: false),
    Lot(id: 't7_l015', tenderId: 't7', lotRef: 'GDL-2606-015', sizeRange: '5-7CT', lotName: 'MB GEM', publishedPieces: 3, publishedCarats: 45.3, willBid: true),
    Lot(id: 't8_l001', tenderId: 't8', lotRef: 'WIL-2606-001', sizeRange: '+10.80CT', lotName: 'FANCY YELLOW', publishedPieces: 1, publishedCarats: 12.4, willBid: false),
    Lot(id: 't8_l002', tenderId: 't8', lotRef: 'WIL-2606-002', sizeRange: '6CT', lotName: 'LIGHT BROWN', publishedPieces: 1, publishedCarats: 9.8, willBid: false),
    Lot(id: 't8_l003', tenderId: 't8', lotRef: 'WIL-2606-003', sizeRange: '5-7CT', lotName: 'COLOURED GEM', publishedPieces: 3, publishedCarats: 45.3, willBid: true),
    Lot(id: 't8_l004', tenderId: 't8', lotRef: 'WIL-2606-004', sizeRange: '2.5-4CT', lotName: 'CLIVAGE HIGH', publishedPieces: 20, publishedCarats: 131.7, willBid: false),
    Lot(id: 't8_l005', tenderId: 't8', lotRef: 'WIL-2606-005', sizeRange: '2.5-10CT', lotName: 'BROWN GEM', publishedPieces: 50, publishedCarats: 182.9, willBid: true),
    Lot(id: 't8_l006', tenderId: 't8', lotRef: 'WIL-2606-006', sizeRange: '4-8GR', lotName: 'Z SPOTTED', publishedPieces: 7, publishedCarats: 40.6, willBid: false),
    Lot(id: 't8_l007', tenderId: 't8', lotRef: 'WIL-2606-007', sizeRange: '+10.80CT', lotName: 'MB GEM', publishedPieces: 1, publishedCarats: 12.4, willBid: true),
    Lot(id: 't8_l008', tenderId: 't8', lotRef: 'WIL-2606-008', sizeRange: '6CT', lotName: 'WHITE GEM', publishedPieces: 1, publishedCarats: 9.8, willBid: true),
    Lot(id: 't8_l009', tenderId: 't8', lotRef: 'WIL-2606-009', sizeRange: '5-7CT', lotName: 'FANCY YELLOW', publishedPieces: 3, publishedCarats: 45.3, willBid: false),
    Lot(id: 't8_l010', tenderId: 't8', lotRef: 'WIL-2606-010', sizeRange: '2.5-4CT', lotName: 'LIGHT BROWN', publishedPieces: 20, publishedCarats: 131.7, willBid: false),
    Lot(id: 't8_l011', tenderId: 't8', lotRef: 'WIL-2606-011', sizeRange: '2.5-10CT', lotName: 'COLOURED GEM', publishedPieces: 50, publishedCarats: 182.9, willBid: true),
    Lot(id: 't8_l012', tenderId: 't8', lotRef: 'WIL-2606-012', sizeRange: '4-8GR', lotName: 'CLIVAGE HIGH', publishedPieces: 7, publishedCarats: 40.6, willBid: false),
    Lot(id: 't8_l013', tenderId: 't8', lotRef: 'WIL-2606-013', sizeRange: '+10.80CT', lotName: 'BROWN GEM', publishedPieces: 1, publishedCarats: 12.4, willBid: true),
    Lot(id: 't8_l014', tenderId: 't8', lotRef: 'WIL-2606-014', sizeRange: '6CT', lotName: 'Z SPOTTED', publishedPieces: 1, publishedCarats: 9.8, willBid: false),
    Lot(id: 't8_l015', tenderId: 't8', lotRef: 'WIL-2606-015', sizeRange: '5-7CT', lotName: 'MB GEM', publishedPieces: 3, publishedCarats: 45.3, willBid: true),
    Lot(id: 't9_l001', tenderId: 't9', lotRef: 'TAGS-Q3-001', sizeRange: '+10.80CT', lotName: 'FANCY YELLOW', publishedPieces: 1, publishedCarats: 12.4, willBid: false),
    Lot(id: 't9_l002', tenderId: 't9', lotRef: 'TAGS-Q3-002', sizeRange: '6CT', lotName: 'LIGHT BROWN', publishedPieces: 1, publishedCarats: 9.8, willBid: false),
    Lot(id: 't9_l003', tenderId: 't9', lotRef: 'TAGS-Q3-003', sizeRange: '5-7CT', lotName: 'COLOURED GEM', publishedPieces: 3, publishedCarats: 45.3, willBid: true),
    Lot(id: 't9_l004', tenderId: 't9', lotRef: 'TAGS-Q3-004', sizeRange: '2.5-4CT', lotName: 'CLIVAGE HIGH', publishedPieces: 20, publishedCarats: 131.7, willBid: false),
    Lot(id: 't9_l005', tenderId: 't9', lotRef: 'TAGS-Q3-005', sizeRange: '2.5-10CT', lotName: 'BROWN GEM', publishedPieces: 50, publishedCarats: 182.9, willBid: true),
    Lot(id: 't9_l006', tenderId: 't9', lotRef: 'TAGS-Q3-006', sizeRange: '4-8GR', lotName: 'Z SPOTTED', publishedPieces: 7, publishedCarats: 40.6, willBid: false),
    Lot(id: 't9_l007', tenderId: 't9', lotRef: 'TAGS-Q3-007', sizeRange: '+10.80CT', lotName: 'MB GEM', publishedPieces: 1, publishedCarats: 12.4, willBid: true),
    Lot(id: 't9_l008', tenderId: 't9', lotRef: 'TAGS-Q3-008', sizeRange: '6CT', lotName: 'WHITE GEM', publishedPieces: 1, publishedCarats: 9.8, willBid: true),
    Lot(id: 't9_l009', tenderId: 't9', lotRef: 'TAGS-Q3-009', sizeRange: '5-7CT', lotName: 'FANCY YELLOW', publishedPieces: 3, publishedCarats: 45.3, willBid: false),
    Lot(id: 't9_l010', tenderId: 't9', lotRef: 'TAGS-Q3-010', sizeRange: '2.5-4CT', lotName: 'LIGHT BROWN', publishedPieces: 20, publishedCarats: 131.7, willBid: false),
    Lot(id: 't9_l011', tenderId: 't9', lotRef: 'TAGS-Q3-011', sizeRange: '2.5-10CT', lotName: 'COLOURED GEM', publishedPieces: 50, publishedCarats: 182.9, willBid: true),
    Lot(id: 't9_l012', tenderId: 't9', lotRef: 'TAGS-Q3-012', sizeRange: '4-8GR', lotName: 'CLIVAGE HIGH', publishedPieces: 7, publishedCarats: 40.6, willBid: false),
    Lot(id: 't9_l013', tenderId: 't9', lotRef: 'TAGS-Q3-013', sizeRange: '+10.80CT', lotName: 'BROWN GEM', publishedPieces: 1, publishedCarats: 12.4, willBid: true),
    Lot(id: 't9_l014', tenderId: 't9', lotRef: 'TAGS-Q3-014', sizeRange: '6CT', lotName: 'Z SPOTTED', publishedPieces: 1, publishedCarats: 9.8, willBid: false),
    Lot(id: 't9_l015', tenderId: 't9', lotRef: 'TAGS-Q3-015', sizeRange: '5-7CT', lotName: 'MB GEM', publishedPieces: 3, publishedCarats: 45.3, willBid: true),
    Lot(id: 't10_l001', tenderId: 't10', lotRef: 'GRIB-2606-001', sizeRange: '+10.80CT', lotName: 'FANCY YELLOW', publishedPieces: 1, publishedCarats: 12.4, willBid: false),
    Lot(id: 't10_l002', tenderId: 't10', lotRef: 'GRIB-2606-002', sizeRange: '6CT', lotName: 'LIGHT BROWN', publishedPieces: 1, publishedCarats: 9.8, willBid: false),
    Lot(id: 't10_l003', tenderId: 't10', lotRef: 'GRIB-2606-003', sizeRange: '5-7CT', lotName: 'COLOURED GEM', publishedPieces: 3, publishedCarats: 45.3, willBid: true),
    Lot(id: 't10_l004', tenderId: 't10', lotRef: 'GRIB-2606-004', sizeRange: '2.5-4CT', lotName: 'CLIVAGE HIGH', publishedPieces: 20, publishedCarats: 131.7, willBid: false),
    Lot(id: 't10_l005', tenderId: 't10', lotRef: 'GRIB-2606-005', sizeRange: '2.5-10CT', lotName: 'BROWN GEM', publishedPieces: 50, publishedCarats: 182.9, willBid: true),
    Lot(id: 't10_l006', tenderId: 't10', lotRef: 'GRIB-2606-006', sizeRange: '4-8GR', lotName: 'Z SPOTTED', publishedPieces: 7, publishedCarats: 40.6, willBid: false),
    Lot(id: 't10_l007', tenderId: 't10', lotRef: 'GRIB-2606-007', sizeRange: '+10.80CT', lotName: 'MB GEM', publishedPieces: 1, publishedCarats: 12.4, willBid: true),
    Lot(id: 't10_l008', tenderId: 't10', lotRef: 'GRIB-2606-008', sizeRange: '6CT', lotName: 'WHITE GEM', publishedPieces: 1, publishedCarats: 9.8, willBid: true),
    Lot(id: 't10_l009', tenderId: 't10', lotRef: 'GRIB-2606-009', sizeRange: '5-7CT', lotName: 'FANCY YELLOW', publishedPieces: 3, publishedCarats: 45.3, willBid: false),
    Lot(id: 't10_l010', tenderId: 't10', lotRef: 'GRIB-2606-010', sizeRange: '2.5-4CT', lotName: 'LIGHT BROWN', publishedPieces: 20, publishedCarats: 131.7, willBid: false),
    Lot(id: 't10_l011', tenderId: 't10', lotRef: 'GRIB-2606-011', sizeRange: '2.5-10CT', lotName: 'COLOURED GEM', publishedPieces: 50, publishedCarats: 182.9, willBid: true),
    Lot(id: 't10_l012', tenderId: 't10', lotRef: 'GRIB-2606-012', sizeRange: '4-8GR', lotName: 'CLIVAGE HIGH', publishedPieces: 7, publishedCarats: 40.6, willBid: false),
    Lot(id: 't10_l013', tenderId: 't10', lotRef: 'GRIB-2606-013', sizeRange: '+10.80CT', lotName: 'BROWN GEM', publishedPieces: 1, publishedCarats: 12.4, willBid: true),
    Lot(id: 't10_l014', tenderId: 't10', lotRef: 'GRIB-2606-014', sizeRange: '6CT', lotName: 'Z SPOTTED', publishedPieces: 1, publishedCarats: 9.8, willBid: false),
    Lot(id: 't10_l015', tenderId: 't10', lotRef: 'GRIB-2606-015', sizeRange: '5-7CT', lotName: 'MB GEM', publishedPieces: 3, publishedCarats: 45.3, willBid: true),
  ];

  static List<Lot> lotsForTender(String tenderId) =>
      lots.where((l) => l.tenderId == tenderId).toList();

  // ── session store: ONE capture per lot (mutable, persisted by LocalStore) ─
  // A "capture" is what the buyer records at the table for a lot: grade
  // (shape/colour/clarity) + photos + notes. The lot's stone count & weight
  // come from the PDF and are NOT re-entered. After capture the lot moves to the
  // estimate team, who fill yield% + $/ct (status → estimated).
  //
  // captures[lotId] = {
  //   shape, colour, clarity, notes,       ← buyer (capture)
  //   images: [Uint8List],
  //   status: 'captured' | 'estimated',
  //   yieldPct, pricePerCt, marginPct,     ← estimate team
  // }
  static final Map<String, Map<String, dynamic>> captures = {};

  /// Per-lot Will-Bid override set on the phone (lotId → true/false). Falls back
  /// to the lot's published willBid flag when the buyer hasn't touched it.
  static final Map<String, bool> willBidOverride = {};
  static bool willBid(Lot lot) => willBidOverride[lot.id] ?? lot.willBid;
  static void toggleWillBid(Lot lot) =>
      willBidOverride[lot.id] = !willBid(lot);

  static void addLot(Lot lot) => lots.add(lot);

  static Map<String, dynamic>? capture(String lotId) => captures[lotId];
  static String captureStatus(String lotId) =>
      captures[lotId] == null ? 'todo' : (captures[lotId]!['status'] as String);
  static bool isCaptured(String lotId) => captures.containsKey(lotId);
  static bool isEstimated(String lotId) => captureStatus(lotId) == 'estimated';

  static Uint8List? firstPhoto(String lotId) {
    final imgs = captures[lotId]?['images'] as List?;
    return (imgs != null && imgs.isNotEmpty) ? imgs.first as Uint8List : null;
  }

  static int photoCount(String lotId) =>
      (captures[lotId]?['images'] as List?)?.length ?? 0;

  static List<Lot> capturedLots(String tenderId) => lotsForTender(tenderId)
      .where((l) => captureStatus(l.id) == 'captured')
      .toList();
}
