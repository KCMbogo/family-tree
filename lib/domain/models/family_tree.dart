import 'package:meta/meta.dart';

/// A named family tree. Phase 1 uses exactly one, but the table and model are
/// already scoped for several so multi-tree support is additive later.
@immutable
class FamilyTree {
  const FamilyTree({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  final String id;
  final String name;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      other is FamilyTree && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}
