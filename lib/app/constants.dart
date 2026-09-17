/// App-wide constants that are deliberately *configuration*, not schema.
///
/// Phase 1 has no accounts, so every claim is authored by a single hardcoded
/// local user. Because `author_id` is a real column on `claim_events` from day
/// one (see spec §2 rule 4), Phase 2 auth only has to replace the value this
/// file supplies — no migration, no repository change.
library;

/// The single local author used for every claim written in Phase 1.
///
/// Phase 2: replace reads of this constant with the signed-in user's UUID.
const String kLocalAuthorId = '6f1d0c5e-3a1b-4c7e-9f2d-0a1b2c3d4e5f';

/// The default name suggested when the user creates their first tree.
const String kDefaultTreeName = 'My Family';
