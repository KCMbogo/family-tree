import '../../domain/models/claim_event.dart';
import '../../domain/models/person.dart';

const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// `16 Sep 2026, 14:32` in the device's local time.
///
/// Claims are stored in UTC; they are only ever converted for display.
String formatTimestamp(DateTime utc) {
  final local = utc.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.day} ${_months[local.month - 1]} ${local.year}, '
      '$hour:$minute';
}

/// Human-readable description of what a claim asserts.
String describeClaim(ClaimEvent event) {
  if (event.isRetraction) {
    final target = event.valueAsString;
    if (target == ClaimFields.wholeEntity) return 'Removed from the tree';
    return 'Cleared ${ClaimFields.label(target ?? '').toLowerCase()}';
  }

  final label = ClaimFields.label(event.field);
  return '$label: ${describeClaimValue(event)}';
}

/// Formats a claim's value for display, decoding the enum-ish fields.
String describeClaimValue(ClaimEvent event) {
  final decoded = event.decodedValue;

  if (decoded is bool) return decoded ? 'Yes' : 'No';

  if (event.field == ClaimFields.gender) {
    return Gender.fromWire(decoded?.toString())?.label ?? '${decoded ?? ''}';
  }

  if (event.field == ClaimFields.photoMediaId) return 'updated';

  return '${decoded ?? ''}';
}

/// `'user_input'` → `'Entered by hand'`.
String describeSource(String source) => switch (source) {
      ClaimSource.userInput => 'Entered by hand',
      ClaimSource.imported => 'Imported',
      ClaimSource.aiTranscription => 'From a recording',
      ClaimSource.confirmedByOtherMember => 'Confirmed by a relative',
      _ => source,
    };
