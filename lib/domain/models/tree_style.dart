/// The visual styles the tree can be drawn in.
///
/// The layout is shared: every style renders the same `TreeLayout`, so a new
/// style is a drawing concern only and can never disagree with another about
/// who belongs where.
enum TreeStyle {
  chart(
    'chart',
    'Chart',
    'Classic genealogy chart with square connectors',
  ),
  organic(
    'organic',
    'Tree',
    'Curved branches growing up from a trunk',
  ),
  portrait(
    'portrait',
    'Portraits',
    'Large photo cards for a family with pictures',
  );

  const TreeStyle(this.wireName, this.label, this.description);

  /// Stored value, so the chosen style survives a restart.
  final String wireName;

  final String label;
  final String description;

  static TreeStyle fromWire(String? value) {
    if (value == null) return TreeStyle.chart;
    for (final style in values) {
      if (style.wireName == value) return style;
    }
    return TreeStyle.chart;
  }
}
