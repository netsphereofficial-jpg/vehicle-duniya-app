import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/otp_page.dart';
import '../features/auth/presentation/pages/profile_setup_page.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/vehicle_auction/presentation/pages/vehicle_auction_page.dart';
import '../features/vehicle_auction/presentation/pages/auction_detail_page.dart';
import '../features/property_auction/presentation/pages/property_auction_page.dart';
import '../features/car_bazaar/presentation/pages/car_bazaar_page.dart';
import '../features/bidding/presentation/pages/my_bids_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/more/presentation/pages/more_page.dart';
import '../features/more/presentation/pages/edit_profile_page.dart';
import '../features/more/presentation/pages/kyc_page.dart';
import '../features/more/presentation/pages/bank_details_page.dart';
import '../features/more/presentation/pages/membership_page.dart';
import '../features/more/presentation/pages/about_page.dart';
import '../features/more/presentation/pages/policy_page.dart';
import '../features/more/presentation/pages/coming_soon_page.dart';
import 'main_shell.dart';

/// Route paths
class AppRoutes {
  AppRoutes._();

  // Auth
  static const String splash = '/splash';
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
  static const String more = '/more';
  static const String notifications = '/notifications';

  // More Section Sub-Routes
  static const String editProfile = '/more/edit-profile';
  static const String kyc = '/more/kyc';
  static const String bankDetails = '/more/bank-details';
  static const String membership = '/more/membership';
  static const String membershipRegister = '/more/membership-register';
  static const String auctionDashboard = '/more/auction-dashboard';
  static const String sellerListing = '/more/seller-listing';
  static const String buyerListing = '/more/buyer-listing';
  static const String about = '/more/about';
  static const String help = '/more/help';
  static const String complaint = '/more/complaint';
  static const String policyRefund = '/more/policy/refund';
  static const String policyPrivacy = '/more/policy/privacy';
  static const String policyTerms = '/more/policy/terms';

  // Detail
  static const String vehicleAuctionDetail = '/vehicles/auction/:id';
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
      initialLocation: AppRoutes.splash,
      debugLogDiagnostics: true,
      refreshListenable: _AuthRefreshStream(authBloc),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuthenticated = authState.isAuthenticated;
        final isOtpSent = authState.isOtpSent;
        final needsProfile = authState.needsProfile;
        final isLoading = authState.status == AuthStatus.initial ||
            authState.status == AuthStatus.loading;

        final isSplash = state.matchedLocation == AppRoutes.splash;
        final isAuthRoute = state.matchedLocation == AppRoutes.login ||
            state.matchedLocation == AppRoutes.otp ||
            state.matchedLocation == AppRoutes.profileSetup;

        // Still loading - stay on or go to splash
        if (isLoading) {
          return isSplash ? null : AppRoutes.splash;
        }

        // Done loading - redirect from splash to appropriate screen
        if (isSplash) {
          if (isAuthenticated) return AppRoutes.home;
          if (needsProfile) return AppRoutes.profileSetup;
          if (isOtpSent) return AppRoutes.otp;
          return AppRoutes.login;
        }

        // Need to complete profile
        if (needsProfile && state.matchedLocation != AppRoutes.profileSetup) {
          return AppRoutes.profileSetup;
        }

        // OTP sent, go to OTP page
        if (isOtpSent && state.matchedLocation != AppRoutes.otp) {
          return AppRoutes.otp;
        }

        // Not authenticated, redirect to login
        if (!isAuthenticated && !isOtpSent && !needsProfile && !isAuthRoute) {
          return AppRoutes.login;
        }

        // Authenticated but on auth route, redirect to home
        if (isAuthenticated && isAuthRoute) {
          return AppRoutes.home;
        }

        return null;
      },
      routes: [
        // Splash
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashPage(),
        ),
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
              path: AppRoutes.properties,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: PropertyAuctionPage(),
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
            GoRoute(
              path: AppRoutes.more,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: MorePage(),
              ),
            ),
          ],
        ),

        // Standalone Pages
        GoRoute(
          path: AppRoutes.carBazaar,
          builder: (context, state) => const CarBazaarPage(),
        ),

        // Vehicle Auction Detail
        GoRoute(
          path: AppRoutes.vehicleAuctionDetail,
          builder: (context, state) {
            final auctionId = state.pathParameters['id'] ?? '';
            return AuctionDetailPage(auctionId: auctionId);
          },
        ),

        // More Section Sub-Routes
        GoRoute(
          path: AppRoutes.editProfile,
          builder: (context, state) => const EditProfilePage(),
        ),
        GoRoute(
          path: AppRoutes.kyc,
          builder: (context, state) => const KycPage(),
        ),
        GoRoute(
          path: AppRoutes.bankDetails,
          builder: (context, state) => const BankDetailsPage(),
        ),
        GoRoute(
          path: AppRoutes.membership,
          builder: (context, state) => const MembershipPage(),
        ),
        GoRoute(
          path: AppRoutes.membershipRegister,
          builder: (context, state) => const ComingSoonPage(
            title: 'Membership Registration',
            description: 'Premium membership registration will be available soon.',
            icon: Icons.card_membership_rounded,
          ),
        ),
        GoRoute(
          path: AppRoutes.auctionDashboard,
          builder: (context, state) => const ComingSoonPage(
            title: 'Auction Dashboard',
            description: 'Your personalized auction dashboard is coming soon.',
            icon: Icons.dashboard_rounded,
          ),
        ),
        GoRoute(
          path: AppRoutes.sellerListing,
          builder: (context, state) => const ComingSoonPage(
            title: 'Seller Listing',
            description: 'List your items for auction. Coming soon!',
            icon: Icons.sell_rounded,
          ),
        ),
        GoRoute(
          path: AppRoutes.buyerListing,
          builder: (context, state) => const ComingSoonPage(
            title: 'Buyer Listing',
            description: 'Browse items to buy. Coming soon!',
            icon: Icons.shopping_bag_rounded,
          ),
        ),
        GoRoute(
          path: AppRoutes.about,
          builder: (context, state) => const AboutPage(),
        ),
        GoRoute(
          path: AppRoutes.help,
          builder: (context, state) => const ComingSoonPage(
            title: 'Help & Support',
            description: 'Get help with your queries. Coming soon!',
            icon: Icons.help_rounded,
          ),
        ),
        GoRoute(
          path: AppRoutes.complaint,
          builder: (context, state) => const ComingSoonPage(
            title: 'Complaint Box',
            description: 'Report issues and complaints. Coming soon!',
            icon: Icons.feedback_rounded,
          ),
        ),
        GoRoute(
          path: AppRoutes.policyRefund,
          builder: (context, state) => const PolicyPage(
            title: 'Refund Policy',
            policyType: PolicyType.refund,
          ),
        ),
        GoRoute(
          path: AppRoutes.policyPrivacy,
          builder: (context, state) => const PolicyPage(
            title: 'Privacy Policy',
            policyType: PolicyType.privacy,
          ),
        ),
        GoRoute(
          path: AppRoutes.policyTerms,
          builder: (context, state) => const PolicyPage(
            title: 'Terms & Conditions',
            policyType: PolicyType.terms,
          ),
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
