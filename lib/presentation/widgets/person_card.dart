import 'package:flutter/material.dart';

import '../../domain/models/person.dart';
import 'person_avatar.dart';

/// The fixed-size card used on the tree canvas.
///
/// Its dimensions come from `TreeMetrics` so the connector painter and the
/// cards always agree on where a person sits.
class PersonCard extends StatelessWidget {
  const PersonCard({
    required this.person,
    required this.onTap,
    this.width,
    this.height,
    super.key,
  });

  final Person person;
  final VoidCallback onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                PersonAvatar(person: person, radius: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person.displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                        ),
                      ),
                      if (person.birthYearRaw != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          person.isDeceased
                              ? 'b. ${person.birthYearRaw}  ·  †'
                              : 'b. ${person.birthYearRaw}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ] else if (person.isDeceased) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Deceased',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The list-style row used on the profile and picker screens.
class PersonListTile extends StatelessWidget {
  const PersonListTile({
    required this.person,
    required this.onTap,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final Person person;
  final VoidCallback onTap;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final details = subtitle ?? _describe(person);

    return ListTile(
      onTap: onTap,
      leading: PersonAvatar(person: person),
      title: Text(person.displayName),
      subtitle: details == null ? null : Text(details),
      trailing: trailing,
    );
  }

  static String? _describe(Person person) {
    final parts = <String>[
      if (person.birthYearRaw != null) 'b. ${person.birthYearRaw}',
      if (person.birthPlace != null) person.birthPlace!,
      if (person.isDeceased) 'Deceased',
    ];
    return parts.isEmpty ? null : parts.join('  ·  ');
  }
}
