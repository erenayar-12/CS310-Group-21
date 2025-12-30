import 'package:flutter/material.dart';

/// Utility class for app-wide spacing constants
class AppSpacing {
  AppSpacing._(); // Private constructor to prevent instantiation

  // Standard spacing values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;

  // Common padding values
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);

  // Horizontal padding
  static const EdgeInsets paddingHorizontalXS = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(horizontal: xl);

  // Vertical padding
  static const EdgeInsets paddingVerticalXS = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVerticalXL = EdgeInsets.symmetric(vertical: xl);

  // Symmetric padding
  static const EdgeInsets paddingSymmetricSM = EdgeInsets.symmetric(horizontal: sm, vertical: sm);
  static const EdgeInsets paddingSymmetricMD = EdgeInsets.symmetric(horizontal: md, vertical: md);
  static const EdgeInsets paddingSymmetricLG = EdgeInsets.symmetric(horizontal: lg, vertical: lg);
  static const EdgeInsets paddingSymmetricXL = EdgeInsets.symmetric(horizontal: xl, vertical: xl);

  // Common margin values
  static const EdgeInsets marginXS = EdgeInsets.all(xs);
  static const EdgeInsets marginSM = EdgeInsets.all(sm);
  static const EdgeInsets marginMD = EdgeInsets.all(md);
  static const EdgeInsets marginLG = EdgeInsets.all(lg);
  static const EdgeInsets marginXL = EdgeInsets.all(xl);

  // Horizontal margin
  static const EdgeInsets marginHorizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets marginHorizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets marginHorizontalLG = EdgeInsets.symmetric(horizontal: lg);

  // Vertical margin
  static const EdgeInsets marginVerticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets marginVerticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets marginVerticalLG = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets marginVerticalXL = EdgeInsets.symmetric(vertical: xl);

  // Specific spacing values used in the app
  static const EdgeInsets cardPadding = EdgeInsets.all(14.0);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(20.0);
  static const EdgeInsets screenPadding = EdgeInsets.all(24.0);
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(horizontal: 24.0);
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  static const EdgeInsets inputPaddingLarge = EdgeInsets.symmetric(horizontal: 12, vertical: 12);
  static const EdgeInsets headerPadding = EdgeInsets.fromLTRB(24, 60, 24, 32);
  static const EdgeInsets bottomNavPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 8);
}

