import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFF6C63FF);
const kSecondaryColor = Color(0xFFF3F3FF);
const kAccentColor = Color(0xFFFF7E5F);
const kTextColor = Color(0xFF2D2D2D);
const kLightTextColor = Color(0xFF757575);
const kBackgroundColor = Color(0xFFFAFAFA);
const kCardColor = Colors.white;

const kDefaultPadding = 20.0;
const kSmallPadding = 12.0;

final kBorderRadius = BorderRadius.circular(16);
final kCardShadow = [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.05),
    blurRadius: 10,
    offset: const Offset(0, 4),
  ),
];

// Text Styles
const kTitleStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: kTextColor,
);

const kSubtitleStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: kTextColor,
);

const kBodyStyle = TextStyle(
  fontSize: 16,
  color: kTextColor,
  height: 1.5,
);

const kCaptionStyle = TextStyle(
  fontSize: 14,
  color: kLightTextColor,
);
