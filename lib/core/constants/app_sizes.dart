import 'package:flutter/material.dart';

/// App size constants - Optimized for Readability
/// Larger sizes for better touch targets and visibility
class AppSizes {
  AppSizes._();

  // Spacing - Generous for clarity
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Screen Padding - Comfortable margins
  static const EdgeInsets screenPadding = EdgeInsets.all(20);
  static const EdgeInsets screenPaddingHorizontal =
      EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets screenPaddingVertical =
      EdgeInsets.symmetric(vertical: 20);

  // Card Padding - Spacious content
  static const EdgeInsets cardPadding = EdgeInsets.all(20);
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(16);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(24);

  // Border Radius - Modern rounded corners
  static const double radiusXs = 6.0;
  static const double radiusSm = 10.0;
  static const double radiusMd = 14.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 28.0;
  static const double radiusRound = 100.0;

  static const BorderRadius borderRadiusSm =
      BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusMd =
      BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg =
      BorderRadius.all(Radius.circular(radiusLg));

  // Icon Sizes - Clear visibility
  static const double iconXs = 18.0;
  static const double iconSm = 22.0;
  static const double iconMd = 26.0;
  static const double iconLg = 34.0;
  static const double iconXl = 48.0;

  // Button Heights - Easy to tap
  static const double buttonHeightSm = 44.0;
  static const double buttonHeightMd = 54.0;
  static const double buttonHeightLg = 60.0;

  // Minimum touch target size (accessibility)
  static const double minTouchTarget = 48.0;

  // Input Heights
  static const double inputHeight = 58.0;

  // App Bar Height
  static const double appBarHeight = 64.0;

  // Bottom Nav Height
  static const double bottomNavHeight = 88.0;

  // Card Sizes
  static const double cardElevation = 0;

  // Image Sizes
  static const double avatarSm = 40.0;
  static const double avatarMd = 56.0;
  static const double avatarLg = 72.0;
  static const double avatarXl = 100.0;

  // Auction Card - Prominent display
  static const double auctionCardImageHeight = 200.0;
  static const double auctionCardWidth = 300.0;
  static const double auctionCardCompactHeight = 140.0;

  // Vehicle Card
  static const double vehicleCardImageHeight = 180.0;

  // Font Sizes - Large & Readable
  static const double fontXs = 12.0;
  static const double fontSm = 14.0;
  static const double fontMd = 16.0;
  static const double fontLg = 18.0;
  static const double fontXl = 22.0;
  static const double fontXxl = 28.0;
  static const double fontDisplay = 36.0;

  // Line Heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;

  // Max Widths
  static const double maxContentWidth = 600.0;
  static const double maxFormWidth = 440.0;
}
