import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_foresters_cruising_kit/utils/const.dart';

final appTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: kAccent,
  scaffoldBackgroundColor: kBackground,
  colorScheme: const ColorScheme.light(
    primary: kAccent,
    secondary: kGold,
    surface: kPanelBg,
    onSurface: kPrimaryText,
    onPrimary: kPanelBg,
    error: kError,
    outline: kOutline,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: kBackground,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
    titleTextStyle: GoogleFonts.sora(
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      color: kPrimaryText,
    ),
    iconTheme: const IconThemeData(color: kPrimaryText),
  ),
  textTheme: TextTheme(
    // ── Display — Sora (only at 20sp+) ───────────────────────────────────────
    displayLarge: GoogleFonts.sora(
      fontSize: 52.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
      height: 1.0,
      letterSpacing: -1.5,
    ),
    displayMedium: GoogleFonts.sora(
      fontSize: 40.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
      height: 1.05,
      letterSpacing: -1.0,
    ),
    displaySmall: GoogleFonts.sora(
      fontSize: 30.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
      height: 1.1,
    ),
    headlineLarge: GoogleFonts.sora(
      fontSize: 26.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
    ),
    headlineMedium: GoogleFonts.sora(
      fontSize: 22.sp,
      fontWeight: FontWeight.w600,
      color: kPrimaryText,
    ),
    headlineSmall: GoogleFonts.sora(
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      color: kPrimaryText,
    ),
    // ── Title — Inter ─────────────────────────────────────────────────────────
    titleLarge: GoogleFonts.inter(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: kPrimaryText,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 15.sp,
      fontWeight: FontWeight.w500,
      color: kPrimaryText,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      color: kSecondaryText,
    ),
    // ── Body — Inter ──────────────────────────────────────────────────────────
    bodyLarge: GoogleFonts.inter(
      fontSize: 15.sp,
      fontWeight: FontWeight.w400,
      color: kPrimaryText,
      height: 1.6,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: kPrimaryText,
      height: 1.6,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: kSecondaryText,
    ),
    // ── Labels — JetBrains Mono for identifiers ───────────────────────────────
    labelLarge: GoogleFonts.jetBrainsMono(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      color: kPrimaryText,
    ),
    labelMedium: GoogleFonts.jetBrainsMono(
      fontSize: 11.sp,
      fontWeight: FontWeight.w500,
      color: kSecondaryText,
    ),
    labelSmall: GoogleFonts.jetBrainsMono(
      fontSize: 10.sp,
      fontWeight: FontWeight.w400,
      color: kSecondaryText,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kBackground,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusSubtle),
      borderSide: const BorderSide(color: kOutline, width: kStrokeWeight),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusSubtle),
      borderSide: const BorderSide(color: kOutline, width: kStrokeWeight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusSubtle),
      borderSide: const BorderSide(color: kAccent, width: kStrokeWeightMedium),
    ),
    hintStyle: GoogleFonts.inter(
      color: kSecondaryText,
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
    ),
    labelStyle: GoogleFonts.inter(
      color: kSecondaryText,
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
    ),
    floatingLabelStyle: GoogleFonts.inter(
      color: kAccent,
      fontSize: 13.sp,
      fontWeight: FontWeight.w600,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kAccent,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 32.w),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(kRadiusPill)),
      ),
      textStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 15.sp,
        letterSpacing: 0.3,
      ),
    ),
  ),
  cardTheme: const CardThemeData(
    color: kPanelBg,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(kRadiusSubtle)),
      side: BorderSide(color: kOutline, width: kStrokeWeight),
    ),
    margin: EdgeInsets.zero,
  ),
  dividerTheme: const DividerThemeData(
    color: kOutline,
    thickness: 1.0,
    space: 0,
  ),
  useMaterial3: true,
);
