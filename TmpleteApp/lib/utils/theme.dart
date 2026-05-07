import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:coopering_croze_barrel/utils/const.dart';

final appTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: kAccent,
  scaffoldBackgroundColor: kBackground,
  colorScheme: const ColorScheme.light(
    primary: kAccent,
    secondary: kSecondaryText,
    surface: kPanelBg,
    onSurface: kPrimaryText,
    onPrimary: kPanelBg,
    error: kError,
    outline: kOutline,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
    titleTextStyle: GoogleFonts.archivo(
      fontSize: 22.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
    ),
    iconTheme: const IconThemeData(color: kPrimaryText),
  ),
  textTheme: TextTheme(
    // ── Display — Archivo ────────────────────────────────────────────────────
    displayLarge: GoogleFonts.archivo(
      fontSize: 48.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
      height: 1.0,
    ),
    displayMedium: GoogleFonts.archivo(
      fontSize: 36.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
      height: 1.05,
    ),
    displaySmall: GoogleFonts.archivo(
      fontSize: 28.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
    ),
    headlineLarge: GoogleFonts.archivo(
      fontSize: 24.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
    ),
    headlineMedium: GoogleFonts.archivo(
      fontSize: 20.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
    ),
    headlineSmall: GoogleFonts.archivo(
      fontSize: 18.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
    ),
    // ── Title — DM Sans ──────────────────────────────────────────────────────
    titleLarge: GoogleFonts.dmSans(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: kPrimaryText,
    ),
    titleMedium: GoogleFonts.dmSans(
      fontSize: 15.sp,
      fontWeight: FontWeight.w500,
      color: kPrimaryText,
    ),
    titleSmall: GoogleFonts.dmSans(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      color: kSecondaryText,
    ),
    // ── Body — DM Sans ───────────────────────────────────────────────────────
    bodyLarge: GoogleFonts.dmSans(
      fontSize: 15.sp,
      fontWeight: FontWeight.w400,
      color: kPrimaryText,
      height: 1.6,
    ),
    bodyMedium: GoogleFonts.dmSans(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: kPrimaryText,
      height: 1.6,
    ),
    bodySmall: GoogleFonts.dmSans(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: kSecondaryText,
    ),
    // ── Labels — DM Sans ─────────────────────────────────────────────────────
    labelLarge: GoogleFonts.dmSans(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      color: kPrimaryText,
      letterSpacing: 0.12 * 12,
    ),
    labelMedium: GoogleFonts.dmSans(
      fontSize: 11.sp,
      fontWeight: FontWeight.w500,
      color: kSecondaryText,
      letterSpacing: 0.12 * 11,
    ),
    labelSmall: GoogleFonts.firaCode(
      fontSize: 11.sp,
      fontWeight: FontWeight.w400,
      color: kSecondaryText,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kPanelBg,
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
    hintStyle: GoogleFonts.firaCode(
      color: kSecondaryText,
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
    ),
    labelStyle: GoogleFonts.dmSans(
      color: kSecondaryText,
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
    ),
    floatingLabelStyle: GoogleFonts.dmSans(
      color: kPrimaryText,
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
      textStyle: GoogleFonts.dmSans(
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
