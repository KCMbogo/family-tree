import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/screens/add_person/add_person_screen.dart';
import '../presentation/screens/media_gallery/media_gallery_screen.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/person_profile/add_relationship_screen.dart';
import '../presentation/screens/person_profile/person_profile_screen.dart';
import '../presentation/screens/timeline/timeline_screen.dart';
import '../presentation/screens/tree_view/tree_view_screen.dart';
import '../presentation/widgets/home_shell.dart';
import '../providers/tree_providers.dart';

abstract final class Routes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String tree = '/tree';
  static const String timeline = '/timeline';
  static const String gallery = '/gallery';
  static const String addPerson = '/add-person';

  static String person(String id) => '/person/$id';
  static String editPerson(String id) => '/person/$id/edit';
  static String addRelationship(String id) => '/person/$id/add-relationship';

  /// The relationship step shown right after creating someone, so a new person
  /// can be connected without hunting for them in the tree first.
  static String connectNewPerson(String id) =>
      '/person/$id/add-relationship?onboarding=1';
}

final routerProvider = Provider<GoRouter>((ref) {
  // go_router needs a Listenable to know when to re-evaluate the redirect;
  // Riverpod gives us the change notification.
  final refresh = ValueNotifier<int>(0);
  ref.onDispose(refresh.dispose);
  ref.listen(primaryTreeProvider, (_, _) => refresh.value++);

  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final tree = ref.read(primaryTreeProvider);

      // Stay on the splash route until we know whether a tree exists, so the
      // first launch never flashes an empty tree before onboarding.
      if (tree.isLoading) return null;

      final location = state.matchedLocation;
      final hasTree = tree.value != null;

      if (!hasTree) {
        return location == Routes.welcome ? null : Routes.welcome;
      }
      if (location == Routes.welcome || location == Routes.splash) {
        return Routes.tree;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const _SplashScreen(),
      ),
      GoRoute(
        path: Routes.welcome,
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.tree,
              builder: (context, state) => const TreeViewScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.timeline,
              builder: (context, state) => const TimelineScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.gallery,
              builder: (context, state) => const MediaGalleryScreen(),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: Routes.addPerson,
        builder: (context, state) => const AddPersonScreen(),
      ),
      GoRoute(
        path: '/person/:id',
        builder: (context, state) =>
            PersonProfileScreen(personId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) => AddPersonScreen(
              personId: state.pathParameters['id'],
            ),
          ),
          GoRoute(
            path: 'add-relationship',
            builder: (context, state) => AddRelationshipScreen(
              personId: state.pathParameters['id']!,
              isNewPerson:
                  state.uri.queryParameters['onboarding'] == '1',
            ),
          ),
        ],
      ),
    ],
  );
});

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
