import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/di/injection.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/otp_page.dart';
import '../features/auth/presentation/pages/profile_setup_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/vehicle_auction/presentation/pages/vehicle_auction_page.dart';
import '../features/property_auction/presentation/pages/property_auction_page.dart';
import '../features/car_bazaar/presentation/pages/car_bazaar_page.dart';
import '../features/bidding/presentation/pages/my_bids_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import 'main_shell.dart';

/// Route paths
class AppRoutes {
  AppRoutes._();

  // Auth
  static const String login = '/login';
  static const String otp = '/otp';
  static const String profileSetup = '/profile-setup';

  // Main
  static const String home = '/';
  static const String vehicles = '/vehicles';
  static const String properties = '/properties';
  static const String carBazaar = '/car-bazaar';
  static const String myBids = '/my-bids';
  static const String profile = '/profile';
  static const String notifications = '/notifications';

  // Detail
  static const String auctionDetail = '/auction/:id';
  static const String vehicleDetail = '/vehicle/:id';
  static const String propertyDetail = '/property/:id';
  static const String carBazaarDetail = '/car-bazaar/:id';
}

/// App router configuration
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router(AuthBloc authBloc) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoutes.home,
      debugLogDiagnostics: true,
      refreshListenable: _AuthRefreshStream(authBloc),
      redirect: (context, state) {
        // TODO: Remove this bypass after testing
        // BYPASS LOGIN FOR TESTING - always go to home
        return null;

        // final authState = authBloc.state;
        // final isAuthenticated = authState.isAuthenticated;
        // final isOtpSent = authState.isOtpSent;
        // final needsProfile = authState.needsProfile;
        // final isLoading = authState.status == AuthStatus.initial ||
        //     authState.status == AuthStatus.loading;

        // final isAuthRoute = state.matchedLocation == AppRoutes.login ||
        //     state.matchedLocation == AppRoutes.otp ||
        //     state.matchedLocation == AppRoutes.profileSetup;

        // // Wait for auth check
        // if (isLoading) return null;

        // // Need to complete profile
        // if (needsProfile && state.matchedLocation != AppRoutes.profileSetup) {
        //   return AppRoutes.profileSetup;
        // }

        // // OTP sent, go to OTP page
        // if (isOtpSent && state.matchedLocation != AppRoutes.otp) {
        //   return AppRoutes.otp;
        // }

        // // Not authenticated, redirect to login
        // if (!isAuthenticated && !isOtpSent && !needsProfile && !isAuthRoute) {
        //   return AppRoutes.login;
        // }

        // // Authenticated but on auth route, redirect to home
        // if (isAuthenticated && isAuthRoute) {
        //   return AppRoutes.home;
        // }

        // return null;
      },
      routes: [
        // Auth Routes
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.otp,
          builder: (context, state) => const OtpPage(),
        ),
        GoRoute(
          path: AppRoutes.profileSetup,
          builder: (context, state) => const ProfileSetupPage(),
        ),

        // Main Shell with Bottom Navigation
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.home,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomePage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.vehicles,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: VehicleAuctionPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.myBids,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: MyBidsPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.profile,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProfilePage(),
              ),
            ),
          ],
        ),

        // Standalone Pages
        GoRoute(
          path: AppRoutes.properties,
          builder: (context, state) => const PropertyAuctionPage(),
        ),
        GoRoute(
          path: AppRoutes.carBazaar,
          builder: (context, state) => const CarBazaarPage(),
        ),
      ],
    );
  }
}

/// Stream adapter for auth state changes
class _AuthRefreshStream extends ChangeNotifier {
  _AuthRefreshStream(AuthBloc authBloc) {
    _subscription = authBloc.stream.listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
