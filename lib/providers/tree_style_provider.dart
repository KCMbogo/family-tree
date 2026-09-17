import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/tree_style.dart';

const _storageKey = 'tree_style';

/// The chosen tree style, remembered across restarts.
///
/// This is a display preference, not a fact about the family, so it lives in
/// preferences rather than in the claim log — nothing here would ever need to
/// sync to another device or be attributed to an author.
class TreeStyleController extends Notifier<TreeStyle> {
  @override
  TreeStyle build() {
    _restore();
    return TreeStyle.chart;
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_storageKey);
      if (stored != null) state = TreeStyle.fromWire(stored);
    } on Exception {
      // A preference that cannot be read is not worth failing over; the
      // default style is always valid.
    }
  }

  Future<void> select(TreeStyle style) async {
    state = style;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, style.wireName);
    } on Exception {
      // The choice still applies for this session.
    }
  }
}

final treeStyleProvider =
    NotifierProvider<TreeStyleController, TreeStyle>(TreeStyleController.new);
