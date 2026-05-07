import 'package:flutter/material.dart';
import 'package:the_foresters_cruising_kit/enum/my_enums.dart';

// ─── COLOR PALETTE — "Timber Inventory" ──────────────────────────────────────
const Color kBackground    = Color(0xFFF4F3EF); // Survey paper — warm off-white
const Color kPrimaryText   = Color(0xFF1C1A16); // Heartwood black — warm deep
const Color kPanelBg       = Color(0xFFFFFFFF); // Pure white cards
const Color kSecondaryText = Color(0xFF7A7670); // Weathered ink — warm grey
const Color kAccent        = Color(0xFF3D6B45); // Cruiser green — USFS green
const Color kOutline       = Color(0xFFE8E5DE); // Field notebook rule lines
const Color kGold          = Color(0xFF9C6B1E); // Timber gold — heartwood brass
const Color kError         = Color(0xFFC0392B); // Critical errors only

// ─── DERIVED COLORS ───────────────────────────────────────────────────────────
const Color kAccentLight   = Color(0xFF5A9068); // Lighter green
const Color kAccentSurface = Color(0xFFF0F6F1); // 10% green tint surface
const Color kGoldSurface   = Color(0xFFFAF5EC); // 10% gold tint surface

// ─── MATERIAL PALETTE ─────────────────────────────────────────────────────────
const Color kMatBrass      = Color(0xFF9C6B1E); // Timber gold
const Color kMatSteel      = Color(0xFF6B7A8A); // Blue-steel grey
const Color kMatAluminum   = Color(0xFF8C9AA8); // Silver-grey
const Color kMatBoxwood    = Color(0xFF8B6340); // Rich brown
const Color kMatHickory    = Color(0xFF7A5530); // Darker hickory
const Color kMatCanvas     = Color(0xFF9A8A72); // Canvas tan
const Color kMatMixed      = Color(0xFF6A6A6A); // Neutral mixed

// ─── SPACING ──────────────────────────────────────────────────────────────────
const double kSpacingXXS  = 4.0;
const double kSpacingXS   = 8.0;
const double kSpacingS    = 12.0;
const double kSpacingM    = 16.0;
const double kSpacingL    = 20.0;
const double kSpacingXL   = 24.0;
const double kSpacingXXL  = 32.0;
const double kSpacingXXXL = 48.0;

// ─── BORDER RADIUS ────────────────────────────────────────────────────────────
const double kRadiusZero     = 0.0;
const double kRadiusSubtle   = 10.0; // Card corners — field data cards
const double kRadiusStandard = 16.0;
const double kRadiusMedium   = 20.0;
const double kRadiusLarge    = 28.0;
const double kRadiusPill     = 999.0;

// ─── SHADOWS ──────────────────────────────────────────────────────────────────
const BoxShadow kShadowSubtle = BoxShadow(
  offset: Offset(0, 2),
  blurRadius: 12,
  spreadRadius: -2,
  color: Color(0x0E1C1A16),
);

const BoxShadow kShadowFloat = BoxShadow(
  offset: Offset(0, 8),
  blurRadius: 28,
  spreadRadius: -6,
  color: Color(0x161C1A16),
);

const BoxShadow kShadowGreen = BoxShadow(
  offset: Offset(0, 6),
  blurRadius: 20,
  spreadRadius: -4,
  color: Color(0x303D6B45),
);

const double kStrokeWeight       = 1.0;
const double kStrokeWeightMedium = 1.5;

// ─── TOOL TYPE COLORS ─────────────────────────────────────────────────────────
Color getToolTypeColor(ToolType type) {
  switch (type) {
    case ToolType.clinometer:
      return kAccent;
    case ToolType.abneyLevel:
      return const Color(0xFF2D5A3D);
    case ToolType.diameterTape:
      return kGold;
    case ToolType.biltmoreStick:
      return const Color(0xFF8B6340);
    case ToolType.incrementBorer:
      return kMatSteel;
    case ToolType.logRule:
      return const Color(0xFF6B4A2A);
    case ToolType.timberScribe:
      return const Color(0xFF4A3520);
  }
}

// ─── CONDITION COLORS ─────────────────────────────────────────────────────────
Color getConditionColor(ConditionGrade grade) {
  switch (grade) {
    case ConditionGrade.museumQuality:
      return kAccent;
    case ConditionGrade.operational:
      return const Color(0xFF4A8C5A);
    case ConditionGrade.wornFunctional:
      return kGold;
    case ConditionGrade.corroded:
      return kError;
    case ConditionGrade.incomplete:
      return const Color(0xFF8C6B3A);
    case ConditionGrade.unknown:
      return kSecondaryText;
  }
}

// ─── MATERIAL COLORS ──────────────────────────────────────────────────────────
Color getMaterialColor(PrimaryMaterial mat) {
  switch (mat) {
    case PrimaryMaterial.brass:
      return kMatBrass;
    case PrimaryMaterial.forgedSteel:
      return kMatSteel;
    case PrimaryMaterial.aluminum:
      return kMatAluminum;
    case PrimaryMaterial.boxwood:
      return kMatBoxwood;
    case PrimaryMaterial.hickory:
      return kMatHickory;
    case PrimaryMaterial.canvasTape:
      return kMatCanvas;
    case PrimaryMaterial.mixed:
      return kMatMixed;
  }
}

// ─── SCALE SYSTEM COLORS ──────────────────────────────────────────────────────
Color getScaleSystemColor(ScaleSystem scale) {
  switch (scale) {
    case ScaleSystem.international:
      return kAccent;
    case ScaleSystem.doyle:
      return kGold;
    case ScaleSystem.scribner:
      return const Color(0xFF5A6B7A);
    case ScaleSystem.hoppus:
      return const Color(0xFF7A5A30);
    case ScaleSystem.biltmore:
      return const Color(0xFF4A6A3A);
    case ScaleSystem.metric:
      return kSecondaryText;
  }
}
