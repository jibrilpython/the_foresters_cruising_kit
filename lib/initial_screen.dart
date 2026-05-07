import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_foresters_cruising_kit/providers/user_provider.dart';
import 'package:the_foresters_cruising_kit/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class InitialScreen extends ConsumerWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProv = ref.watch(userProvider);
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          // ── Tree cross-section backdrop ──────────────────────────────────
          Positioned.fill(
            child: CustomPaint(painter: _TreeRingBackdropPainter()),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(32.w, 24.h, 32.w, 40.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Technical Header ──────────────────────────────────────
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        color: kAccent,
                        size: 18.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'DIGITAL FIELD ARCHIVE',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11.sp,
                          color: kAccent,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: kAccent.withAlpha(20),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'INDEXED',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 8.sp,
                            color: kAccent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 40.h),
                  // ── Hero typography ─────────────────────────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "The\nForester's\nCruising\nKit.",
                        style: GoogleFonts.sora(
                          color: kPrimaryText,
                          fontSize: 52.sp,
                          fontWeight: FontWeight.w700,
                          height: 0.95,
                          letterSpacing: -1.5,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'PRECISION FORESTRY INSTRUMENTS',
                        style: GoogleFonts.jetBrainsMono(
                          color: kGold,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'A digital archive of the manual instruments that measured the great woods — from brass Abney levels to cast-iron log scaling rules.',
                        style: GoogleFonts.inter(
                          color: kSecondaryText,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      // Scale system pill row
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 6.h,
                        children:
                            [
                                  'Doyle',
                                  'Scribner',
                                  'International 1/4"',
                                  'Hoppus',
                                ]
                                .map(
                                  (s) => Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: kOutline,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        kRadiusPill,
                                      ),
                                    ),
                                    child: Text(
                                      s,
                                      style: GoogleFonts.jetBrainsMono(
                                        color: kSecondaryText,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ),

                  // ── CTA button ──────────────────────────────────────────
                  GestureDetector(
                    onTap: () {
                      userProv.setFirstTimeUser(false);
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    child: Container(
                      width: double.infinity,
                      height: 58.h,
                      decoration: BoxDecoration(
                        color: kAccent,
                        borderRadius: BorderRadius.circular(kRadiusPill),
                        boxShadow: const [kShadowGreen],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Open the Kit',
                            style: GoogleFonts.sora(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws a faint tree cross-section (growth rings) in the background.
/// More rings = older feel. Rendered in gold tones to match timber gold identity.
class _TreeRingBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ringPaint = Paint()
      ..color = kOutline.withAlpha(140)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final cx = size.width * 0.85;
    final cy = size.height * 0.28;

    // Concentric growth rings
    for (int i = 1; i <= 8; i++) {
      final r = 40.0 + i * 48.0;
      canvas.drawCircle(Offset(cx, cy), r, ringPaint);
    }

    // Ray lines (medullary rays)
    final rayPaint = Paint()
      ..color = kGold.withAlpha(18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + 430 * math.cos(angle), cy + 430 * math.sin(angle)),
        rayPaint,
      );
    }

    // Pith dot
    final pithPaint = Paint()
      ..color = kGold.withAlpha(60)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 4, pithPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
