import 'package:flutter/material.dart';
import 'package:coopering_croze_barrel/enum/my_enums.dart';

// ─── COLOR PALETTE — "Workshop Precision" ────────────────────────────────────
const Color kBackground   = Color(0xFFF9F9F8); // Silky off-white
const Color kPrimaryText  = Color(0xFF141414); // Near-black
const Color kPanelBg      = Color(0xFFFFFFFF); // Pure white cards
const Color kSecondaryText = Color(0xFF9A9A96); // Muted labels
const Color kAccent       = Color(0xFF2D6A4F); // Cooper's Moss green
const Color kOutline      = Color(0xFFE8E8E5); // Dividers / strokes
const Color kError        = Color(0xFFC0392B); // Errors only

// ─── DERIVED COLORS ──────────────────────────────────────────────────────────
const Color kAccentLight    = Color(0xFF3D8C69);
const Color kAccentSurface  = Color(0xFFF0F7F4); // Green-tinted light surface
const Color kGlassBackground = Color(0xB3FFFFFF); // 70% White

// ─── MATERIAL SWATCH COLORS ───────────────────────────────────────────────────
const Color kCastIron    = Color(0xFF4A4A4A); // Dark grey
const Color kForgedSteel = Color(0xFF7A8A95); // Blue-steel
const Color kBrass       = Color(0xFFB07D3A); // Warm gold
const Color kHardwood    = Color(0xFF8B5E3C); // Brown
const Color kMixedMat    = Color(0xFF6A6A6A); // Mixed

// ─── SPACING ─────────────────────────────────────────────────────────────────
const double kSpacingXXS  = 4.0;
const double kSpacingXS   = 8.0;
const double kSpacingS    = 12.0;
const double kSpacingM    = 16.0;
const double kSpacingL    = 20.0;
const double kSpacingXL   = 24.0;
const double kSpacingXXL  = 32.0;
const double kSpacingXXXL = 48.0;

// ─── BORDER RADIUS ───────────────────────────────────────────────────────────
const double kRadiusZero     = 0.0;
const double kRadiusSubtle   = 16.0; // Increased for slickness
const double kRadiusStandard = 24.0;
const double kRadiusMedium   = 32.0;
const double kRadiusLarge    = 40.0;
const double kRadiusXLarge   = 40.0;
const double kRadiusPill     = 999.0;

// ─── SHADOWS ─────────────────────────────────────────────────────────────────
const BoxShadow kShadowSubtle = BoxShadow(
  offset: Offset(0, 12),
  blurRadius: 36,
  spreadRadius: -8,
  color: Color(0x14000000),
);

const BoxShadow kShadowFloat = BoxShadow(
  offset: Offset(0, 24),
  blurRadius: 48,
  spreadRadius: -12,
  color: Color(0x20000000),
);

const BoxShadow kShadowGreen = BoxShadow(
  offset: Offset(0, 8),
  blurRadius: 24,
  spreadRadius: -4,
  color: Color(0x302D6A4F),
);

const double kStrokeWeight       = 1.0;
const double kStrokeWeightMedium = 1.5;

// ─── CROZE TYPE COLORS ────────────────────────────────────────────────────────
Color getCrozeTypeColor(CrozeType type) {
  switch (type) {
    case CrozeType.handCroze:
      return kAccent;
    case CrozeType.castIronCrozePlane:
      return kCastIron;
    case CrozeType.foldingCroze:
      return kForgedSteel;
    case CrozeType.headGroover:
      return kBrass;
    case CrozeType.chimeCroze:
      return kHardwood;
    case CrozeType.other:
      return kSecondaryText;
  }
}

// ─── CONDITION COLORS ────────────────────────────────────────────────────────
Color getConditionColor(CrozeCondition state) {
  switch (state) {
    case CrozeCondition.pristine:
      return kAccent;
    case CrozeCondition.functional:
      return const Color(0xFF4A8C6A);
    case CrozeCondition.corroded:
      return kError;
    case CrozeCondition.dulled:
      return kBrass;
    case CrozeCondition.incomplete:
      return const Color(0xFF8C6B3A);
    case CrozeCondition.unknown:
      return kSecondaryText;
  }
}

// ─── MATERIAL COLORS ─────────────────────────────────────────────────────────
Color getMaterialColor(ManufacturingMaterial mat) {
  switch (mat) {
    case ManufacturingMaterial.castIron:
      return kCastIron;
    case ManufacturingMaterial.wroughtSteel:
      return kForgedSteel;
    case ManufacturingMaterial.brass:
      return kBrass;
    case ManufacturingMaterial.hardwood:
      return kHardwood;
    case ManufacturingMaterial.mixed:
      return kMixedMat;
  }
}

// ─── BARREL TYPE COLORS ───────────────────────────────────────────────────────
Color getBarrelTypeColor(BarrelType type) {
  switch (type) {
    case BarrelType.whiskey:
      return const Color(0xFF8C5A2A);
    case BarrelType.wine:
      return const Color(0xFF7A2D4A);
    case BarrelType.beer:
      return const Color(0xFFB07D2A);
    case BarrelType.oil:
      return const Color(0xFF4A4A6A);
    case BarrelType.fish:
      return const Color(0xFF2A5A7A);
    case BarrelType.pickles:
      return kAccent;
    case BarrelType.gunpowder:
      return const Color(0xFF3A3A3A);
    case BarrelType.other:
      return kSecondaryText;
  }
}
