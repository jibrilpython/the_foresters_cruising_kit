import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:coopering_croze_barrel/providers/user_provider.dart';
import 'package:coopering_croze_barrel/utils/const.dart';
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
          // ── Decorative groove cross-section backdrop ──────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: _GrooveCrossSectionPainter(),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(
              32.w,
              MediaQuery.of(context).padding.top + 48.h,
              32.w,
              MediaQuery.of(context).padding.bottom + 48.h,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Mono logotype ─────────────────────────────────────────
                Text(
                  'CCA.',
                  style: GoogleFonts.firaCode(
                    fontSize: 20.sp,
                    color: kAccent,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                  ),
                ),

                // ── Hero typography ───────────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coopering\nCroze\nArchive.',
                      style: GoogleFonts.archivo(
                        color: kPrimaryText,
                        fontSize: 58.sp,
                        fontWeight: FontWeight.w700,
                        height: 0.95,
                        letterSpacing: -1.0,
                      ),
                    ),
                    SizedBox(height: 28.h),
                    Container(
                      width: 48.w,
                      height: 3.h,
                      color: kAccent,
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'A digital catalogue of forgotten cooperage instruments — the blades that sealed barrels of whiskey, wine, and history.',
                      style: GoogleFonts.dmSans(
                        color: kSecondaryText,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),

                // ── CTA pill ─────────────────────────────────────────────
                GestureDetector(
                  onTap: () {
                    userProv.setFirstTimeUser(false);
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: Container(
                    width: double.infinity,
                    height: 60.h,
                    decoration: BoxDecoration(
                      color: kAccent,
                      borderRadius: BorderRadius.circular(kRadiusPill),
                      boxShadow: const [kShadowGreen],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Open archive',
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
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
        ],
      ),
    );
  }
}

/// Draws a faint cooperage groove cross-section in the background.
/// Depicts layers of a barrel stave cross-section with a channel groove.
class _GrooveCrossSectionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kOutline.withAlpha(120)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final cx = size.width * 0.82;
    final cy = size.height * 0.32;

    // Concentric arcs suggesting stave layers
    for (int i = 1; i <= 5; i++) {
      final r = 60.0 + i * 50.0;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        math.pi * 0.4,
        math.pi * 1.1,
        false,
        paint,
      );
    }

    // Small groove tick marks
    final groovePaint = Paint()
      ..color = kAccent.withAlpha(30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < 4; i++) {
      final angle = math.pi * 0.55 + i * math.pi * 0.15;
      final innerR = 110.0;
      final outerR = 140.0;
      final a =
          Offset(cx + innerR * math.cos(angle), cy + innerR * math.sin(angle));
      final b =
          Offset(cx + outerR * math.cos(angle), cy + outerR * math.sin(angle));
      canvas.drawLine(a, b, groovePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
