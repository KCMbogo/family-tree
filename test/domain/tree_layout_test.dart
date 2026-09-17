import 'package:family_tree/domain/models/person.dart';
import 'package:family_tree/domain/models/relationship.dart';
import 'package:family_tree/domain/services/tree_layout.dart';
import 'package:flutter_test/flutter_test.dart';

Person person(String id, {String? name, int? birthYear}) => Person(
      id: id,
      fullName: name ?? id,
      birthYear: birthYear,
      birthYearRaw: birthYear?.toString(),
    );

Relationship edge(String a, String b, RelationshipType type) => Relationship(
      id: '$a-$b-${type.wireName}',
      personAId: a,
      personBId: b,
      type: type,
    );

extension on TreeLayout {
  int generationOf(String id) => nodes.firstWhere((n) => n.id == id).generation;
  double xOf(String id) => nodes.firstWhere((n) => n.id == id).x;
  bool has(String id) => nodes.any((n) => n.id == id);
}

/// Tolerance for centring comparisons, in slot units.
const double _eps = 0.001;

void main() {
  group('generations', () {
    test('an empty tree lays out to nothing', () {
      final layout =
          TreeLayoutBuilder.compute(persons: const [], relationships: const []);

      expect(layout.isEmpty, isTrue);
      expect(layout.generationCount, 0);
    });

    test('children are placed below their parents', () {
      final layout = TreeLayoutBuilder.compute(
        persons: [person('gp'), person('p'), person('c')],
        relationships: [
          edge('gp', 'p', RelationshipType.parentOf),
          edge('p', 'c', RelationshipType.parentOf),
        ],
      );

      expect(layout.generationOf('gp'), 0);
      expect(layout.generationOf('p'), 1);
      expect(layout.generationOf('c'), 2);
      expect(layout.generationCount, 3);
    });

    test('spouses and siblings share a generation', () {
      final layout = TreeLayoutBuilder.compute(
        persons: [person('parent'), person('child'), person('inlaw')],
        relationships: [
          edge('parent', 'child', RelationshipType.parentOf),
          edge('child', 'inlaw', RelationshipType.spouseOf),
        ],
      );

      expect(layout.generationOf('inlaw'), layout.generationOf('child'));
    });

    test('a cycle in the data does not hang the layout', () {
      final layout = TreeLayoutBuilder.compute(
        persons: [person('a'), person('b')],
        relationships: [
          edge('a', 'b', RelationshipType.parentOf),
          edge('b', 'a', RelationshipType.parentOf),
        ],
      );

      expect(layout.nodes, hasLength(2));
    });
  });

  group('couples are laid out as a unit', () {
    test('spouses sit adjacent, about one card apart', () {
      final layout = TreeLayoutBuilder.compute(
        persons: [person('husband'), person('wife')],
        relationships: [edge('husband', 'wife', RelationshipType.spouseOf)],
      );

      final gap = (layout.xOf('husband') - layout.xOf('wife')).abs();
      expect(gap, greaterThan(0.9));
      expect(gap, lessThan(1.5),
          reason: 'a couple must read as a pair, not as two strangers');
    });

    test('a couple produces one connector between them', () {
      final layout = TreeLayoutBuilder.compute(
        persons: [person('a'), person('b')],
        relationships: [edge('a', 'b', RelationshipType.spouseOf)],
      );

      final couples =
          layout.edges.where((e) => e.kind == TreeEdgeKind.couple).toList();
      expect(couples, hasLength(1));
      expect(couples.single.fromGeneration, couples.single.toGeneration);
    });
  });

  group('children hang from their parent couple', () {
    test('an only child sits centred between both parents', () {
      final layout = TreeLayoutBuilder.compute(
        persons: [person('dad'), person('mum'), person('kid')],
        relationships: [
          edge('dad', 'mum', RelationshipType.spouseOf),
          edge('dad', 'kid', RelationshipType.parentOf),
          edge('mum', 'kid', RelationshipType.parentOf),
        ],
      );

      final midpoint = (layout.xOf('dad') + layout.xOf('mum')) / 2;
      expect(layout.xOf('kid'), closeTo(midpoint, _eps));
    });

    test('a sibling group is centred under its parents', () {
      final layout = TreeLayoutBuilder.compute(
        persons: [
          person('dad'),
          person('mum'),
          person('a', birthYear: 1960),
          person('b', birthYear: 1962),
          person('c', birthYear: 1964),
        ],
        relationships: [
          edge('dad', 'mum', RelationshipType.spouseOf),
          for (final kid in ['a', 'b', 'c']) ...[
            edge('dad', kid, RelationshipType.parentOf),
            edge('mum', kid, RelationshipType.parentOf),
          ],
        ],
      );

      final parentMid = (layout.xOf('dad') + layout.xOf('mum')) / 2;
      final childMid = (layout.xOf('a') + layout.xOf('c')) / 2;
      expect(childMid, closeTo(parentMid, _eps));
    });

    test('siblings are ordered oldest to youngest, left to right', () {
      final layout = TreeLayoutBuilder.compute(
        persons: [
          person('dad'),
          person('young', birthYear: 1970),
          person('old', birthYear: 1960),
        ],
        relationships: [
          edge('dad', 'young', RelationshipType.parentOf),
          edge('dad', 'old', RelationshipType.parentOf),
        ],
      );

      expect(layout.xOf('old'), lessThan(layout.xOf('young')));
    });

    test('parents stay centred over children across three generations', () {
      // The realistic shape that a simple two-card test does not exercise:
      // a couple with two children, one of whom marries and has children of
      // their own. Packing must not knock either couple off centre.
      final layout = TreeLayoutBuilder.compute(
        persons: [
          person('Juma', birthYear: 1930), person('Asha', birthYear: 1934),
          person('Neema', birthYear: 1958), person('Baraka', birthYear: 1956),
          person('Salim', birthYear: 1960),
          person('Amina', birthYear: 1985), person('Zawadi', birthYear: 1988),
        ],
        relationships: [
          edge('Juma', 'Asha', RelationshipType.spouseOf),
          for (final k in ['Neema', 'Salim']) ...[
            edge('Juma', k, RelationshipType.parentOf),
            edge('Asha', k, RelationshipType.parentOf),
          ],
          edge('Neema', 'Baraka', RelationshipType.spouseOf),
          for (final k in ['Amina', 'Zawadi']) ...[
            edge('Neema', k, RelationshipType.parentOf),
            edge('Baraka', k, RelationshipType.parentOf),
          ],
        ],
      );

      // Grandparents centred over their two children.
      final gpMid = (layout.xOf('Juma') + layout.xOf('Asha')) / 2;
      final genOneMid = (layout.xOf('Neema') + layout.xOf('Salim')) / 2;
      expect(genOneMid, closeTo(gpMid, _eps));

      // Parents centred over their own two children.
      final parentMid = (layout.xOf('Neema') + layout.xOf('Baraka')) / 2;
      final kidsMid = (layout.xOf('Amina') + layout.xOf('Zawadi')) / 2;
      expect(kidsMid, closeTo(parentMid, _eps));

      _expectNoOverlap(layout);
    });

    test('descent connectors hang from the couple centre, not one parent', () {
      final layout = TreeLayoutBuilder.compute(
        persons: [person('dad'), person('mum'), person('kid')],
        relationships: [
          edge('dad', 'mum', RelationshipType.spouseOf),
          edge('dad', 'kid', RelationshipType.parentOf),
          edge('mum', 'kid', RelationshipType.parentOf),
        ],
      );

      final descent =
          layout.edges.where((e) => e.kind == TreeEdgeKind.descent).toList();
      expect(descent, hasLength(1));

      final midpoint = (layout.xOf('dad') + layout.xOf('mum')) / 2;
      expect(descent.single.originX, closeTo(midpoint, _eps));
    });

    test('all children of one couple share a descent origin', () {
      final layout = TreeLayoutBuilder.compute(
        persons: [
          person('dad'),
          person('mum'),
          person('a', birthYear: 1960),
          person('b', birthYear: 1962),
        ],
        relationships: [
          edge('dad', 'mum', RelationshipType.spouseOf),
          for (final kid in ['a', 'b']) ...[
            edge('dad', kid, RelationshipType.parentOf),
            edge('mum', kid, RelationshipType.parentOf),
          ],
        ],
      );

      final origins = layout.edges
          .where((e) => e.kind == TreeEdgeKind.descent)
          .map((e) => e.originX!.toStringAsFixed(4))
          .toSet();
      expect(origins, hasLength(1),
          reason: 'a sibling bar must have a single hanging point');
    });
  });

  group('no overlap', () {
    test('two separate branches do not collide', () {
      // Two couples in generation 0, each with two children.
      final layout = TreeLayoutBuilder.compute(
        persons: [
          for (final id in ['a1', 'a2', 'b1', 'b2']) person(id),
          person('ac1', birthYear: 1980),
          person('ac2', birthYear: 1982),
          person('bc1', birthYear: 1981),
          person('bc2', birthYear: 1983),
        ],
        relationships: [
          edge('a1', 'a2', RelationshipType.spouseOf),
          edge('b1', 'b2', RelationshipType.spouseOf),
          for (final kid in ['ac1', 'ac2']) ...[
            edge('a1', kid, RelationshipType.parentOf),
            edge('a2', kid, RelationshipType.parentOf),
          ],
          for (final kid in ['bc1', 'bc2']) ...[
            edge('b1', kid, RelationshipType.parentOf),
            edge('b2', kid, RelationshipType.parentOf),
          ],
        ],
      );

      _expectNoOverlap(layout);
    });

    test('three generations of one lineage do not collide', () {
      final layout = TreeLayoutBuilder.compute(
        persons: [
          person('gf'), person('gm'),
          person('f', birthYear: 1950), person('m'),
          person('aunt', birthYear: 1955),
          person('kid1', birthYear: 1980), person('kid2', birthYear: 1983),
        ],
        relationships: [
          edge('gf', 'gm', RelationshipType.spouseOf),
          edge('gf', 'f', RelationshipType.parentOf),
          edge('gm', 'f', RelationshipType.parentOf),
          edge('gf', 'aunt', RelationshipType.parentOf),
          edge('gm', 'aunt', RelationshipType.parentOf),
          edge('f', 'm', RelationshipType.spouseOf),
          for (final kid in ['kid1', 'kid2']) ...[
            edge('f', kid, RelationshipType.parentOf),
            edge('m', kid, RelationshipType.parentOf),
          ],
        ],
      );

      _expectNoOverlap(layout);
      expect(layout.generationCount, 3);
    });

    test('unrelated people still each get a place', () {
      final layout = TreeLayoutBuilder.compute(
        persons: [person('a'), person('b'), person('c')],
        relationships: const [],
      );

      expect(layout.nodes, hasLength(3));
      _expectNoOverlap(layout);
    });
  });

  group('nobody is dropped', () {
    test('a person with no relationships still appears', () {
      final layout = TreeLayoutBuilder.compute(
        persons: [person('dad'), person('kid'), person('loner')],
        relationships: [edge('dad', 'kid', RelationshipType.parentOf)],
      );

      expect(layout.has('loner'), isTrue);
      expect(layout.nodes, hasLength(3));
    });

    test('retracted people are left out', () {
      final layout = TreeLayoutBuilder.compute(
        persons: [
          person('a'),
          const Person(id: 'gone', fullName: 'Gone', isRetracted: true),
        ],
        relationships: const [],
      );

      expect(layout.nodes.map((n) => n.id), ['a']);
    });

    test('edges pointing at missing people are ignored', () {
      final layout = TreeLayoutBuilder.compute(
        persons: [person('a')],
        relationships: [edge('a', 'ghost', RelationshipType.parentOf)],
      );

      expect(layout.nodes, hasLength(1));
      expect(layout.edges, isEmpty);
    });

    test('every person appears exactly once', () {
      final layout = TreeLayoutBuilder.compute(
        persons: [
          person('gf'), person('gm'), person('f'), person('m'), person('kid'),
        ],
        relationships: [
          edge('gf', 'gm', RelationshipType.spouseOf),
          edge('gf', 'f', RelationshipType.parentOf),
          edge('gm', 'f', RelationshipType.parentOf),
          edge('f', 'm', RelationshipType.spouseOf),
          edge('f', 'kid', RelationshipType.parentOf),
          edge('m', 'kid', RelationshipType.parentOf),
        ],
      );

      expect(layout.nodes.map((n) => n.id).toSet(), hasLength(5));
    });
  });

  group('siblings without recorded parents', () {
    test('are joined by a sibling connector', () {
      final layout = TreeLayoutBuilder.compute(
        persons: [person('a'), person('b')],
        relationships: [edge('a', 'b', RelationshipType.siblingOf)],
      );

      expect(
        layout.edges.where((e) => e.kind == TreeEdgeKind.siblingOnly),
        hasLength(1),
      );
    });

    test('are not double-drawn when they already share a parent', () {
      final layout = TreeLayoutBuilder.compute(
        persons: [person('dad'), person('a'), person('b')],
        relationships: [
          edge('dad', 'a', RelationshipType.parentOf),
          edge('dad', 'b', RelationshipType.parentOf),
          edge('a', 'b', RelationshipType.siblingOf),
        ],
      );

      expect(
        layout.edges.where((e) => e.kind == TreeEdgeKind.siblingOnly),
        isEmpty,
        reason: 'descent lines already show they are siblings',
      );
    });
  });
}

/// Asserts no two cards on the same row overlap.
void _expectNoOverlap(TreeLayout layout) {
  final byRow = <int, List<double>>{};
  for (final node in layout.nodes) {
    byRow.putIfAbsent(node.generation, () => []).add(node.x);
  }

  for (final entry in byRow.entries) {
    final xs = entry.value..sort();
    for (var i = 1; i < xs.length; i++) {
      expect(
        xs[i] - xs[i - 1],
        greaterThanOrEqualTo(1.0 - _eps),
        reason: 'cards overlap on generation ${entry.key}: $xs',
      );
    }
  }
}
