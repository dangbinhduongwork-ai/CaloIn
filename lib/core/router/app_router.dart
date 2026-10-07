import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/diary/presentation/add_meal_entry_screen.dart';
import '../../features/diary/presentation/quick_add_screen.dart';
import '../../features/foods/presentation/custom_food_screen.dart';
import '../../features/foods/presentation/food_library_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/profile/data/profile_providers.dart';
import '../../features/profile/presentation/onboarding_screen.dart';
import '../../features/profile/presentation/onboarding_summary_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import 'scaffold_with_nav_bar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _dashboardNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'dashboard');
final _historyNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'history');
final _settingsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'settings');

final appRouterProvider = Provider<GoRouter>((ref) {
  final profileAsync = ref.watch(profileProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      if (profileAsync.isLoading) {
        return null;
      }

      final hasProfile = profileAsync.value != null;
      final isGoingToOnboarding = state.matchedLocation.startsWith('/onboarding');

      if (!hasProfile && !isGoingToOnboarding) {
        return '/onboarding';
      }

      if (hasProfile && isGoingToOnboarding) {
        return '/';
      }

      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _dashboardNavigatorKey,
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _historyNavigatorKey,
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _settingsNavigatorKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/foods',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FoodLibraryScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
        routes: [
          GoRoute(
            path: 'summary',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const OnboardingSummaryScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/diary/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final mealType = state.uri.queryParameters['mealType'];
          return AddMealEntryScreen(initialMealType: mealType);
        },
      ),
      GoRoute(
        path: '/diary/quick-add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final mealType = state.uri.queryParameters['mealType'];
          return QuickAddScreen(initialMealType: mealType);
        },
      ),
      GoRoute(
        path: '/foods/custom',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CustomFoodScreen(),
      ),
    ],
  );
});
