import '../models/person.dart';
import '../models/relationship.dart';

/// A person placed on the canvas.
class TreeNode {
  const TreeNode({
    required this.person,
    required this.generation,
    required this.x,
  });

  final Person person;

  /// Row index: 0 is the oldest generation present.
  final int generation;

  /// Horizontal centre, in "slot" units where 1.0 is one card pitch.
  ///
  /// Continuous rather than an integer column, because a child has to be able
  /// to sit at the midpoint between two parents — the single most recognisable
  /// feature of a real family tree, and one an integer grid cannot express.
  final double x;

  String get id => person.id;
}

/// What a connector joins.
enum TreeEdgeKind {
  /// Horizontal bar between two spouses.
  couple,

  /// Parent (or parent couple) down to a child.
  descent,

  /// Two people recorded as siblings with no shared parent in the tree.
  siblingOnly,
}

/// A drawable connector, in the same slot units as [TreeNode.x].
class TreeEdge {
  const TreeEdge({
    required this.kind,
    required this.fromX,
    required this.fromGeneration,
    required this.toX,
    required this.toGeneration,
    this.originX,
    this.hasTwoParents = false,
  });

  final TreeEdgeKind kind;

  final double fromX;
  final int fromGeneration;
  final double toX;
  final int toGeneration;

  /// For [TreeEdgeKind.descent], the x the sibling bar hangs from — the centre
  /// of the parent couple. Children of one couple share this, which is what
  /// makes them read as a sibling group.
  final double? originX;

  /// True when this descent comes from two parents, so a marriage bar exists
  /// at [originX] for the stem to start on. With one parent there is no bar
  /// and the stem starts at the card's bottom edge instead.
  final bool hasTwoParents;
}

/// A married (or otherwise paired) couple, plus their children.
///
/// Families, not individuals, are the unit a genealogical chart is laid out
/// around: children hang from the couple, and the couple is packed as one.
class FamilyUnit {
  const FamilyUnit({
    required this.parentIds,
    required this.childIds,
  });

  final List<String> parentIds;
  final List<String> childIds;
}

/// The computed shape of the tree.
class TreeLayout {
  const TreeLayout({
    required this.nodes,
    required this.edges,
    required this.width,
    required this.generationCount,
  });

  static const TreeLayout empty =
      TreeLayout(nodes: [], edges: [], width: 0, generationCount: 0);

  final List<TreeNode> nodes;
  final List<TreeEdge> edges;

  /// Total width in slot units.
  final double width;

  final int generationCount;

  bool get isEmpty => nodes.isEmpty;
}

/// Arranges people into a genealogical chart.
///
/// The algorithm is a tidy-tree pack (Reingold–Tilford in spirit) adapted for
/// genealogy, where the recursive unit is a *family* rather than a node:
///
/// 1. group people into generations, keeping spouses and siblings level;
/// 2. build family units (a couple plus their children);
/// 3. walk each root family depth-first, packing subtrees left to right and
///    centring every parent couple over its children;
/// 4. resolve people who belong to no family so nothing is ever dropped.
///
/// Positions are continuous, so a child genuinely sits midway between its
/// parents instead of snapping to a column.
abstract final class TreeLayoutBuilder {
  /// Safety cap for the generation relaxation loop. Hand-entered family data
  /// can contain cycles ("A is B's parent" *and* "B is A's parent"), and the
  /// layout must not hang because of a data-entry mistake.
  static const int _maxPasses = 64;

  /// Horizontal gap between two adjacent subtrees, in slot units.
  static const double _subtreeGap = 0.35;

  /// Gap between the two cards of a couple, in slot units.
  static const double _coupleGap = 0.12;

  static TreeLayout compute({
    required List<Person> persons,
    required List<Relationship> relationships,
  }) {
    final byId = {
      for (final person in persons)
        if (!person.isRetracted) person.id: person,
    };
    if (byId.isEmpty) return TreeLayout.empty;

    final graph = _Graph.from(byId, relationships);
    final generation = _assignGenerations(byId.keys, graph);
    final families = _buildFamilies(byId.keys, graph, generation);

    final placer = _Placer(
      byId: byId,
      graph: graph,
      generation: generation,
      families: families,
    );
    final positions = placer.run();

    final nodes = [
      for (final entry in positions.entries)
        TreeNode(
          person: byId[entry.key]!,
          generation: generation[entry.key]!,
          x: entry.value,
        ),
    ]..sort((a, b) => a.generation != b.generation
        ? a.generation.compareTo(b.generation)
        : a.x.compareTo(b.x));

    final maxX = positions.values.fold(0.0, (a, b) => a > b ? a : b);
    // x is a card centre, so the content runs half a card past the last one.

    return TreeLayout(
      nodes: nodes,
      edges: _buildEdges(graph, families, generation, positions),
      width: maxX + 0.5,
      generationCount:
          nodes.isEmpty ? 0 : nodes.map((n) => n.generation).reduce(
                (a, b) => a > b ? a : b,
              ) + 1,
    );
  }

  /// Pushes each person below their parents, and keeps spouses and siblings
  /// level, by relaxing until the assignment stops changing.
  static Map<String, int> _assignGenerations(
    Iterable<String> ids,
    _Graph graph,
  ) {
    final generation = {for (final id in ids) id: 0};

    for (var pass = 0; pass < _maxPasses; pass++) {
      var changed = false;

      for (final entry in graph.parentsOf.entries) {
        final deepestParent = entry.value
            .map((p) => generation[p] ?? 0)
            .fold(-1, (a, b) => a > b ? a : b);
        if (deepestParent >= 0 && generation[entry.key]! <= deepestParent) {
          generation[entry.key] = deepestParent + 1;
          changed = true;
        }
      }

      for (final peer in graph.peers) {
        final deeper = generation[peer.a]! > generation[peer.b]!
            ? generation[peer.a]!
            : generation[peer.b]!;
        if (generation[peer.a] != deeper || generation[peer.b] != deeper) {
          generation[peer.a] = deeper;
          generation[peer.b] = deeper;
          changed = true;
        }
      }

      if (!changed) break;
    }

    final minimum = generation.values.fold(0, (a, b) => a < b ? a : b);
    if (minimum != 0) {
      for (final id in generation.keys) {
        generation[id] = generation[id]! - minimum;
      }
    }

    return generation;
  }

  /// Groups people into couples-with-children.
  ///
  /// A child with two parents who are married to each other belongs to that
  /// couple's family; a child with a single recorded parent forms a
  /// one-parent family. Either way the children of the same parent set become
  /// one sibling group.
  static List<FamilyUnit> _buildFamilies(
    Iterable<String> ids,
    _Graph graph,
    Map<String, int> generation,
  ) {
    // Key a family by its sorted parent set, so full and half siblings group
    // exactly as a genealogist would expect.
    final childrenByParents = <String, List<String>>{};
    final parentSets = <String, List<String>>{};

    for (final id in ids) {
      final parents = (graph.parentsOf[id] ?? const <String>[]).toSet().toList()
        ..sort();
      if (parents.isEmpty) continue;
      final key = parents.join('|');
      childrenByParents.putIfAbsent(key, () => []).add(id);
      parentSets[key] = parents;
    }

    final families = <FamilyUnit>[];
    final pairedInFamily = <String>{};

    for (final entry in childrenByParents.entries) {
      final parents = parentSets[entry.key]!;
      final children = entry.value
        ..sort((a, b) => _birthOrder(graph, a).compareTo(_birthOrder(graph, b)));
      families.add(FamilyUnit(parentIds: parents, childIds: children));
      pairedInFamily.addAll(parents);
    }

    // Childless couples still need to be packed as a unit.
    for (final couple in graph.couples) {
      final alreadyTogether = families.any((f) =>
          f.parentIds.length == 2 &&
          f.parentIds.contains(couple.a) &&
          f.parentIds.contains(couple.b));
      if (alreadyTogether) continue;
      if (generation[couple.a] != generation[couple.b]) continue;

      families.add(FamilyUnit(
        parentIds: [couple.a, couple.b]..sort(),
        childIds: const [],
      ));
    }

    return families;
  }

  /// Sorts siblings oldest first when birth years are known.
  static int _birthOrder(_Graph graph, String id) =>
      graph.birthYearOf[id] ?? 1 << 30;

  static List<TreeEdge> _buildEdges(
    _Graph graph,
    List<FamilyUnit> families,
    Map<String, int> generation,
    Map<String, double> positions,
  ) {
    final edges = <TreeEdge>[];

    for (final couple in graph.couples) {
      final a = positions[couple.a];
      final b = positions[couple.b];
      if (a == null || b == null) continue;
      if (generation[couple.a] != generation[couple.b]) continue;

      edges.add(TreeEdge(
        kind: TreeEdgeKind.couple,
        fromX: a,
        fromGeneration: generation[couple.a]!,
        toX: b,
        toGeneration: generation[couple.b]!,
      ));
    }

    for (final family in families) {
      if (family.childIds.isEmpty) continue;

      // Materialised: this is re-read once per child below, and a lazy
      // iterable would recompute the whole map each time.
      final parentXs = family.parentIds
          .map((p) => positions[p])
          .whereType<double>()
          .toList();
      if (parentXs.isEmpty) continue;

      // Descent hangs from the centre of the couple, not from one parent.
      final originX =
          parentXs.reduce((a, b) => a + b) / parentXs.length;
      final parentGeneration = family.parentIds
          .map((p) => generation[p])
          .whereType<int>()
          .reduce((a, b) => a > b ? a : b);

      for (final childId in family.childIds) {
        final childX = positions[childId];
        if (childX == null) continue;
        edges.add(TreeEdge(
          kind: TreeEdgeKind.descent,
          fromX: originX,
          fromGeneration: parentGeneration,
          toX: childX,
          toGeneration: generation[childId]!,
          originX: originX,
          hasTwoParents: parentXs.length > 1,
        ));
      }
    }

    // Siblings asserted directly, with no parent recorded to join them.
    for (final pair in graph.siblings) {
      final sharesParent = (graph.parentsOf[pair.a] ?? const <String>[])
          .toSet()
          .intersection((graph.parentsOf[pair.b] ?? const <String>[]).toSet())
          .isNotEmpty;
      if (sharesParent) continue;

      final a = positions[pair.a];
      final b = positions[pair.b];
      if (a == null || b == null) continue;

      edges.add(TreeEdge(
        kind: TreeEdgeKind.siblingOnly,
        fromX: a,
        fromGeneration: generation[pair.a]!,
        toX: b,
        toGeneration: generation[pair.b]!,
      ));
    }

    return edges;
  }
}

/// Adjacency derived from the relationship list, built once per layout.
class _Graph {
  _Graph({
    required this.parentsOf,
    required this.childrenOf,
    required this.spousesOf,
    required this.couples,
    required this.siblings,
    required this.peers,
    required this.birthYearOf,
  });

  factory _Graph.from(
    Map<String, Person> byId,
    List<Relationship> relationships,
  ) {
    final parentsOf = <String, List<String>>{};
    final childrenOf = <String, List<String>>{};
    final spousesOf = <String, List<String>>{};
    final couples = <({String a, String b})>[];
    final siblings = <({String a, String b})>[];
    final peers = <({String a, String b})>[];

    final seenParent = <String>{};
    final seenCouple = <String>{};
    final seenSibling = <String>{};

    final usable = relationships.where((r) =>
        r.isComplete &&
        byId.containsKey(r.personAId) &&
        byId.containsKey(r.personBId));

    for (final relationship in usable) {
      final a = relationship.personAId!;
      final b = relationship.personBId!;

      // Older data can assert the same fact twice (the same child recorded
      // from each parent's profile). Deduplicate here so a doubled edge never
      // draws a doubled line or splits a sibling group.
      final key = [a, b].join('|');
      final mirrored = [b, a].join('|');

      switch (relationship.type!) {
        case RelationshipType.parentOf:
          if (!seenParent.add(key)) continue;
          parentsOf.putIfAbsent(b, () => []).add(a);
          childrenOf.putIfAbsent(a, () => []).add(b);
        case RelationshipType.spouseOf:
          if (seenCouple.contains(mirrored) || !seenCouple.add(key)) continue;
          spousesOf.putIfAbsent(a, () => []).add(b);
          spousesOf.putIfAbsent(b, () => []).add(a);
          couples.add((a: a, b: b));
          peers.add((a: a, b: b));
        case RelationshipType.siblingOf:
          if (seenSibling.contains(mirrored) || !seenSibling.add(key)) {
            continue;
          }
          siblings.add((a: a, b: b));
          peers.add((a: a, b: b));
      }
    }

    return _Graph(
      parentsOf: parentsOf,
      childrenOf: childrenOf,
      spousesOf: spousesOf,
      couples: couples,
      siblings: siblings,
      peers: peers,
      birthYearOf: {
        for (final person in byId.values)
          if (person.birthYear != null) person.id: person.birthYear!,
      },
    );
  }

  final Map<String, List<String>> parentsOf;
  final Map<String, List<String>> childrenOf;
  final Map<String, List<String>> spousesOf;
  final List<({String a, String b})> couples;
  final List<({String a, String b})> siblings;
  final List<({String a, String b})> peers;
  final Map<String, int> birthYearOf;
}

/// Packs family subtrees left to right, centring each couple over its children.
///
/// This is the part that makes the chart look like a family tree rather than a
/// list. It walks top-down, and on the way back up re-centres every parent over
/// the block its descendants occupy, shifting later subtrees right so nothing
/// overlaps.
class _Placer {
  _Placer({
    required this.byId,
    required this.graph,
    required this.generation,
    required this.families,
  });

  final Map<String, Person> byId;
  final _Graph graph;
  final Map<String, int> generation;
  final List<FamilyUnit> families;

  final Map<String, double> _x = {};
  final Set<String> _placed = {};

  /// Rightmost occupied x per generation, so subtrees never collide.
  final Map<int, double> _rowCursor = {};

  /// The family a person heads, keyed by parent id.
  late final Map<String, FamilyUnit> _familyByParent = {
    for (final family in families)
      for (final parent in family.parentIds) parent: family,
  };

  Map<String, double> run() {
    for (final rootId in _roots()) {
      _placeFamilyOf(rootId);
    }


    // Anyone not reachable through a family (no parents, no spouse, no
    // children) still belongs on the chart — they are simply their own root.
    for (final id in _orderedIds()) {
      if (_placed.contains(id)) continue;
      _placeSingle(id);
    }

    _recentre();
    _normalise();
    return _x;
  }

  /// Slides each parent couple onto the midpoint of its children.
  ///
  /// Packing places subtrees so they do not collide, which can leave a couple
  /// slightly off-centre above its children. Parents are freer to move than a
  /// packed subtree, so centring is re-asserted here, bottom-up, and only when
  /// the move does not collide with someone already on that row.
  void _recentre() {
    final rows = <int, List<String>>{};
    for (final entry in _x.entries) {
      rows.putIfAbsent(generation[entry.key]!, () => []).add(entry.key);
    }

    // Deepest generation first: children settle before their parents centre.
    final ordered = rows.keys.toList()..sort((a, b) => b.compareTo(a));

    for (final row in ordered) {
      for (final family in families) {
        if (family.childIds.isEmpty) continue;
        if (!family.parentIds.every(_x.containsKey)) continue;
        if (generation[family.parentIds.first] != row) continue;

        final childXs =
            family.childIds.map((c) => _x[c]).whereType<double>().toList()
              ..sort();
        if (childXs.isEmpty) continue;

        final target = (childXs.first + childXs.last) / 2;
        final parents = family.parentIds.toList()
          ..sort((a, b) => _x[a]!.compareTo(_x[b]!));
        final current =
            (_x[parents.first]! + _x[parents.last]!) / 2;

        final delta = target - current;
        if (delta.abs() < 0.0001) continue;
        if (!_canShift(parents, delta)) continue;

        for (final parentId in parents) {
          _x[parentId] = _x[parentId]! + delta;
        }
      }
    }
  }

  /// True when moving [ids] by [delta] keeps a full card of clearance from
  /// everyone else on their row.
  bool _canShift(List<String> ids, double delta) {
    final moving = ids.toSet();

    for (final id in ids) {
      final row = generation[id]!;
      final proposed = _x[id]! + delta;

      for (final entry in _x.entries) {
        if (moving.contains(entry.key)) continue;
        if (generation[entry.key] != row) continue;
        if ((proposed - entry.value).abs() < 1.0 - 0.0001) return false;
      }
    }
    return true;
  }

  /// People who start a lineage: no parents recorded in this tree.
  ///
  /// Ordered oldest first so the chart reads chronologically left to right.
  List<String> _roots() {
    final roots = _orderedIds()
        .where((id) => (graph.parentsOf[id] ?? const []).isEmpty)
        .toList();

    // A spouse who married in is placed by their partner's family, not as a
    // separate root, otherwise couples get split across the canvas.
    final claimedBySpouse = <String>{};
    for (final id in roots) {
      if (claimedBySpouse.contains(id)) continue;
      for (final spouse in graph.spousesOf[id] ?? const <String>[]) {
        if (roots.contains(spouse)) claimedBySpouse.add(spouse);
      }
    }

    return roots.where((id) => !claimedBySpouse.contains(id)).toList();
  }

  /// Deterministic order: oldest first, then by name.
  List<String> _orderedIds() {
    final ids = byId.keys.toList();
    ids.sort((a, b) {
      final ya = graph.birthYearOf[a];
      final yb = graph.birthYearOf[b];
      if (ya != null && yb != null && ya != yb) return ya.compareTo(yb);
      if (ya != null && yb == null) return -1;
      if (ya == null && yb != null) return 1;
      return byId[a]!.displayName.compareTo(byId[b]!.displayName);
    });
    return ids;
  }

  /// Places [personId], their spouse, and everything below them.
  ///
  /// Returns the centre of the placed block, which the caller uses to centre
  /// the generation above.
  double _placeFamilyOf(String personId) {
    if (_placed.contains(personId)) return _x[personId]!;

    final row = generation[personId]!;
    final family = _familyByParent[personId];

    // Lay the children out first, then sit the parents over their midpoint —
    // the defining move of a genealogical chart.
    final childCentres = <double>[];
    if (family != null) {
      for (final childId in family.childIds) {
        if (_placed.contains(childId)) continue;
        childCentres.add(_placeFamilyOf(childId));
      }
    }

    final partners = _partnersOf(personId, family);
    final blockWidth = partners.length + (partners.length - 1) * _gapUnits;

    double leftEdge;
    if (childCentres.isNotEmpty) {
      final childrenCentre =
          (childCentres.first + childCentres.last) / 2;
      leftEdge = childrenCentre - blockWidth / 2;
      // Never overlap what is already on this row. If the couple has to move
      // right, slide their whole subtree by the same amount so the children
      // stay exactly under them — centring is re-asserted in _recentre().
      final minimum = _rowCursor[row];
      if (minimum != null && leftEdge < minimum) {
        final shift = minimum - leftEdge;
        leftEdge = minimum;
        _shiftSubtree(family!, shift);
      }
    } else {
      leftEdge = _nextFreeX(row);
    }

    // `_x` holds card *centres*, so the first partner sits half a card in
    // from the block's left edge. Mixing edges and centres here is what makes
    // a child drift off its parents' midpoint.
    var cursor = leftEdge + 0.5;
    for (final partnerId in partners) {
      _x[partnerId] = cursor;
      _placed.add(partnerId);
      cursor += 1 + _gapUnits;
    }
    _occupy(row, leftEdge, blockWidth);

    final centre = leftEdge + blockWidth / 2;

    // Children recorded after the parents were positioned.
    if (family != null) {
      for (final childId in family.childIds) {
        if (_placed.contains(childId)) continue;
        _placeFamilyOf(childId);
      }
    }

    return centre;
  }

  /// The people that sit side by side on this row as one block: the person and
  /// the spouse they share this family with.
  List<String> _partnersOf(String personId, FamilyUnit? family) {
    if (family != null && family.parentIds.length == 2) {
      final ordered = family.parentIds.toList()
        ..sort((a, b) => _sideOf(a).compareTo(_sideOf(b)));
      if (ordered.every((p) => !_placed.contains(p))) return ordered;
    }

    final spouse = (graph.spousesOf[personId] ?? const <String>[])
        .where((s) =>
            !_placed.contains(s) &&
            s != personId &&
            generation[s] == generation[personId])
        .toList();

    if (spouse.isEmpty) return [personId];
    return [personId, spouse.first]..sort((a, b) => _sideOf(a).compareTo(_sideOf(b)));
  }

  /// Keeps couples in a stable left/right order across rebuilds.
  String _sideOf(String id) => byId[id]!.displayName;

  void _placeSingle(String id) {
    final row = generation[id]!;
    final partners = _partnersOf(id, _familyByParent[id]);
    final blockWidth = partners.length + (partners.length - 1) * _gapUnits;
    final leftEdge = _nextFreeX(row);

    var cursor = leftEdge + 0.5;
    for (final partnerId in partners) {
      _x[partnerId] = cursor;
      _placed.add(partnerId);
      cursor += 1 + _gapUnits;
    }
    _occupy(row, leftEdge, blockWidth);

    // Their descendants still need placing.
    final family = _familyByParent[id];
    if (family == null) return;
    for (final childId in family.childIds) {
      if (_placed.contains(childId)) continue;
      _placeFamilyOf(childId);
    }
  }

  /// Slides an already-placed subtree right, so a parent can stay centred.
  void _shiftSubtree(FamilyUnit family, double delta) {
    if (delta == 0) return;
    final seen = <String>{};

    void walk(String id) {
      if (!seen.add(id)) return;
      final current = _x[id];
      if (current == null) return;
      _x[id] = current + delta;
      _occupy(generation[id]!, _x[id]! - 0.5, 1);

      final sub = _familyByParent[id];
      if (sub == null) return;
      for (final childId in sub.childIds) {
        walk(childId);
      }
      for (final parentId in sub.parentIds) {
        if (parentId != id) walk(parentId);
      }
    }

    for (final childId in family.childIds) {
      walk(childId);
    }
  }

  double _nextFreeX(int row) {
    return _rowCursor[row] ?? 0;
  }

  void _occupy(int row, double leftEdge, double width) {
    final right = leftEdge + width + TreeLayoutBuilder._subtreeGap;
    final existing = _rowCursor[row];
    if (existing == null || right > existing) _rowCursor[row] = right;
  }

  /// Shifts everything so the leftmost card sits at x = 0.
  void _normalise() {
    if (_x.isEmpty) return;
    final minX = _x.values.reduce((a, b) => a < b ? a : b);
    final delta = 0.5 - minX;
    if (delta == 0) return;
    for (final id in _x.keys.toList()) {
      _x[id] = _x[id]! + delta;
    }
  }

  static double get _gapUnits => TreeLayoutBuilder._coupleGap;
}
