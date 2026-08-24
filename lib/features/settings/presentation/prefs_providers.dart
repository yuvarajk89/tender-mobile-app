import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/persistence/local_store.dart';

/// How the grade selector (Shape/Colour/Clarity) is shown on the lot-capture
/// screen. Two patterns the client compared:
///   • 'inline'  — today's inline horizontal chip rows
///   • 'tabbed'  — yesterday's tabbed bottom-sheet with a vertical list
/// Persisted locally. (The grade VALUES come from the backend; this is only the
/// selection UI style.)
class GradeStyle {
  static const inline = 'inline';
  static const tabbed = 'tabbed';
}

class GradeStyleController extends StateNotifier<String> {
  GradeStyleController() : super(LocalStore.I.loadGradeStyle() ?? GradeStyle.inline);
  void set(String s) {
    state = s;
    LocalStore.I.persistGradeStyle(s);
  }
}

final gradeStyleProvider =
    StateNotifierProvider<GradeStyleController, String>((ref) {
  return GradeStyleController();
});
