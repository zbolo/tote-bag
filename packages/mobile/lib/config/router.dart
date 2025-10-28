import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/auth/sign_up_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/list/list_detail_screen.dart';
import '../screens/scanner/barcode_scanner_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final currentUser = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoading = currentUser is AsyncLoading;
      final isAuthenticated = currentUser.value != null;

      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (isLoading) {
        return null; // Show loading screen
      }

      if (!isAuthenticated && !isAuthRoute) {
        return '/auth/signin';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/auth/signin',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/list/:id',
        builder: (context, state) {
          final listId = state.pathParameters['id']!;
          return ListDetailScreen(listId: listId);
        },
      ),
      GoRoute(
        path: '/scanner/:listId',
        builder: (context, state) {
          final listId = state.pathParameters['listId']!;
          return BarcodeScannerScreen(listId: listId);
        },
      ),
    ],
  );
});
