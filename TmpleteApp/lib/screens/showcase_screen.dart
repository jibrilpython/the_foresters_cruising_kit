import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:coopering_croze_barrel/enum/my_enums.dart';
import 'package:coopering_croze_barrel/models/project_model.dart';
import 'package:coopering_croze_barrel/providers/image_provider.dart';
import 'package:coopering_croze_barrel/providers/project_provider.dart';
import 'package:coopering_croze_barrel/utils/const.dart';

// ─── Constants for Centrifuge Aesthetic ──────────────────────────────────────
const Color kOakBg = Color(0xFF1E110A); // Deep Oak
const Color kOakDeep = Color(0xFF0C0704); // Core shadow
const Color kIronRim = Color(0xFF2A2C2F);
const Color kRawSteel = Color(0xFF8D949A);
const Color kLeatherBg = Color(0xFF191310);

class SawdustParticle {
  double x, y;
  double dx, dy;
  int life, maxLife;
  double size;

  SawdustParticle({
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.life,
    required this.size,
  }) : maxLife = life;
}

class ToolWedge {
  final CrozeType type;
  final int count;
  final List<CrozeModel> items;

  double angle;
  double radius;
  double radialVelocity;
  bool isGrabbed = false;
  double wedgeSize;

  ToolWedge({
    required this.type,
    required this.count,
    required this.items,
    required this.angle,
    required this.radius,
    required this.wedgeSize,
  }) : radialVelocity = 0;
}

class ShowcaseScreen extends ConsumerStatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  ConsumerState<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends ConsumerState<ShowcaseScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  List<ToolWedge> _wedges = [];
  final List<SawdustParticle> _particles = [];

  bool _isInitialized = false;
  int _lastEntriesHash = -1;
  ToolWedge? _focusedWedge;

  double _systemSpinVelocity = 0.0;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  int _computeHash(WidgetRef ref, List<CrozeModel> entries, double width) {
    // Robust hash combining data version, count, and layout width
    return Object.hash(
      ref.read(projectProvider).stateVersion,
      entries.length,
      width.toInt(),
    );
  }

  void _initializeWedges(
      WidgetRef ref, List<CrozeModel> entries, Size screenSize) {
    if (screenSize.width == 0 || entries.isEmpty) return;

    final currentHash = _computeHash(ref, entries, screenSize.width);
    if (_isInitialized && _lastEntriesHash == currentHash) return;

    _isInitialized = true;
    _lastEntriesHash = currentHash;
    _particles.clear();

    // Preserve spin if we are just updating data, don't reset to 0
    // _systemSpinVelocity = 0.0;

    // Capture the type of the currently focused wedge to restore it after re-init
    final CrozeType? previouslyFocusedType = _focusedWedge?.type;

    final counts = <CrozeType, int>{};
    for (var e in entries) {
      counts[e.crozeType] = (counts[e.crozeType] ?? 0) + 1;
    }

    final maxCount = counts.values.reduce(math.max);

    // Distribute wedges evenly in polar coordinates
    final int wedgeSystemCount = counts.keys.length;
    double currentAngle = 0;

    _wedges = counts.keys.map((type) {
      final count = counts[type]!;
      final factor = (count / maxCount).clamp(0.5, 1.0);
      final size = 52.w * factor;

      final wedge = ToolWedge(
        type: type,
        count: count,
        items: entries.where((e) => e.crozeType == type).toList(),
        angle: currentAngle,
        radius: 100.0, // Start slightly off center
        wedgeSize: size,
      );

      currentAngle += (2 * math.pi) / wedgeSystemCount;
      return wedge;
    }).toList();

    // Re-sync the focused wedge reference from the new list
    if (previouslyFocusedType != null) {
      try {
        _focusedWedge =
            _wedges.firstWhere((w) => w.type == previouslyFocusedType);
      } catch (_) {
        _focusedWedge = null;
      }
    }
  }

  void _onTick(Duration elapsed) {
    if (_wedges.isEmpty || !mounted) return;

    final Size size = MediaQuery.of(context).size;
    final double centerX = size.width / 2;
    // Shift center up when focus panel is active
    final double centerY =
        _focusedWedge == null ? size.height / 2 : size.height * 0.25;

    final double maxRadius = math.min(size.width, size.height) * 0.35;

    // Apply friction to the global spinner
    _systemSpinVelocity *= 0.95;

    // Force rigid bounds
    bool playedGlobalThud = false;

    // Process Wedges
    for (var w in _wedges) {
      if (w.isGrabbed) {
        w.radialVelocity = 0;
      } else {
        // Rotate with the system
        w.angle += _systemSpinVelocity;

        // Centrifugal Acceleration (outward push) + strong baseline push
        double outwardForce = 1.2 + (_systemSpinVelocity.abs() * 20.0);
        w.radialVelocity += outwardForce;
        w.radius += w.radialVelocity;

        // Collision with the Iron Hoop boundary
        if (w.radius >= maxRadius) {
          if (w.radialVelocity > 10.0 && !playedGlobalThud) {
            HapticFeedback.heavyImpact();
            playedGlobalThud = true;
          }
          w.radius = maxRadius;
          w.radialVelocity = 0;

          // Grinding sawdust particles if spinning fast and pressed against rim
          if (_systemSpinVelocity.abs() > 0.02 && _random.nextDouble() < 0.3) {
            _spawnSawdust(w.angle, w.radius, centerX, centerY);
          }
        }
      }
    }

    // Process Particles
    for (int i = _particles.length - 1; i >= 0; i--) {
      final p = _particles[i];
      p.x += p.dx;
      p.y += p.dy;
      p.life--;
      if (p.life <= 0) {
        _particles.removeAt(i);
      }
    }

    setState(() {});
  }

  void _spawnSawdust(
      double angle, double radius, double centerX, double centerY) {
    final x = centerX + radius * math.cos(angle);
    final y = centerY + radius * math.sin(angle);

    // Particles fly tangentially backwards opposite to the spin
    final direction = _systemSpinVelocity > 0 ? -1 : 1;
    final tangentAngle =
        angle + (math.pi / 2 * direction) + (_random.nextDouble() - 0.5) * 0.5;
    final speed = 4.0 + _random.nextDouble() * 6.0;

    _particles.add(SawdustParticle(
      x: x,
      y: y,
      dx: speed * math.cos(tangentAngle),
      dy: speed * math.sin(tangentAngle),
      life: 20 + _random.nextInt(30),
      size: 2.0 + _random.nextDouble() * 4.0,
    ));
  }

  void _onSpin(DragUpdateDetails details, double centerX, double centerY) {
    if (_focusedWedge != null) return; // Prevent spin while in focus mode

    // Calculate angular delta via cross product
    final rx = details.localPosition.dx - centerX;
    final ry = details.localPosition.dy - centerY;
    final vx = details.delta.dx;
    final vy = details.delta.dy;

    final cross = (rx * vy) - (ry * vx);
    // Add to system spin
    _systemSpinVelocity += cross * 0.00005;
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(projectProvider).entries;
    final size = MediaQuery.of(context).size;
    _initializeWedges(ref, entries, size);

    final double centerX = size.width / 2;
    final double centerY =
        _focusedWedge == null ? size.height / 2 : size.height * 0.25;

    return Scaffold(
      backgroundColor: kOakBg,
      body: entries.isEmpty
          ? _buildEmptyState()
          : GestureDetector(
              onPanUpdate: (d) => _onSpin(d, centerX, centerY),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Oak Centrifuge Background & Particles
                  _buildEnvironment(centerX, centerY),

                  // 2. Iron Wedges
                  ..._wedges.map((w) => _buildWedge(w, centerX, centerY)),

                  // 3. Raw Steel HUD Overlay
                  _buildHUD(entries.length),

                  // 3. Raw Steel Focus Slider
                  if (_focusedWedge != null) _buildFocusPanel(),
                ],
              ),
            ),
    );
  }

  Widget _buildEnvironment(double centerX, double centerY) {
    final Size size = MediaQuery.of(context).size;
    final double maxRadius = math.min(size.width, size.height) * 0.35;

    return RepaintBoundary(
      child: CustomPaint(
        painter: _CentrifugePainter(
          centerX: centerX,
          centerY: centerY,
          maxRadius: maxRadius,
          particles: _particles,
        ),
      ),
    );
  }

  Widget _buildWedge(ToolWedge w, double centerX, double centerY) {
    final bool isFocused = _focusedWedge == w;
    final color = getCrozeTypeColor(w.type);

    final x = centerX + w.radius * math.cos(w.angle);
    final y = centerY + w.radius * math.sin(w.angle);

    return Positioned(
      left: x - w.wedgeSize,
      top: y - w.wedgeSize,
      width: w.wedgeSize * 2,
      height: w.wedgeSize * 2,
      child: GestureDetector(
        onPanDown: (_) => w.isGrabbed = true,
        onPanUpdate: (d) {
          // Convert global touch delta to polar coordinate transformation
          // Approximation for radial dragging
          final nx = (x + d.delta.dx) - centerX;
          final ny = (y + d.delta.dy) - centerY;
          w.radius = math.sqrt(nx * nx + ny * ny);
          w.angle = math.atan2(ny, nx);
        },
        onPanEnd: (_) {
          w.isGrabbed = false;
        },
        onPanCancel: () => w.isGrabbed = false,
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _focusedWedge = isFocused ? null : w;
            if (_focusedWedge != null) {
              _systemSpinVelocity = 0; // The Clank (halt spin)
            }
          });
        },
        child: Transform.rotate(
          angle: w.angle + math.pi / 2, // Face outward
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color:
                  isFocused ? color : const Color(0xFF32353A), // Raw Steel Look
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(w.wedgeSize * 0.6),
                topRight: Radius.circular(w.wedgeSize * 0.6),
                bottomLeft: const Radius.circular(6),
                bottomRight: const Radius.circular(6),
              ),
              border: Border.all(
                  color: isFocused ? Colors.white : const Color(0xFF535860),
                  width: isFocused ? 3 : 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(200),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: color.withAlpha(isFocused ? 150 : 30),
                  blurRadius: 30,
                  spreadRadius: isFocused ? 10 : 0,
                ),
              ],
              gradient: isFocused
                  ? null
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF4A4E54), Color(0xFF1D1F23)],
                    ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${w.count}',
                  style: GoogleFonts.archivo(
                    color: Colors.white,
                    fontSize: w.wedgeSize * 0.6,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (w.wedgeSize > 35)
                  Container(
                    width: w.wedgeSize * 0.8,
                    height: 2,
                    color: isFocused
                        ? Colors.white.withAlpha(100)
                        : kRawSteel.withAlpha(50),
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFocusPanel() {
    final w = _focusedWedge!;
    final items = w.items;
    final color = getCrozeTypeColor(w.type);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 480.h,
      child: Container(
        decoration: const BoxDecoration(
          color: kLeatherBg,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(0)), // Sharp, raw design
          border: Border(top: BorderSide(color: kRawSteel, width: 4)),
        ),
        child: Column(
          children: [
            // Structural Header
            Container(
              padding: EdgeInsets.fromLTRB(24.w, 20.h, 16.w, 20.h),
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Color(0xFF332924), width: 2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          w.type.label.toUpperCase(),
                          style: GoogleFonts.archivo(
                              color: Colors.white,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'TOOL CLASSIFICATION . REGISTRY',
                          style: GoogleFonts.firaCode(
                              color: kRawSteel,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      _focusedWedge = null;
                    }),
                    icon: Icon(Icons.close, color: kRawSteel, size: 28.sp),
                    style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withAlpha(10)),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Horizontal Artifact Cards
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 120.h),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final item = items[i];
                  final globalIdx =
                      ref.read(projectProvider).entries.indexOf(item);
                  final imgPath =
                      ref.watch(imageProvider).getImagePath(item.photoPath);

                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/info_screen',
                        arguments: globalIdx),
                    child: Container(
                      width: 200.w,
                      margin: EdgeInsets.only(right: 20.w),
                      decoration: BoxDecoration(
                        color: const Color(
                            0xFF110D0A), // Darker well inside leather
                        border: Border.all(
                            color: const Color(0xFF332924), width: 2),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withAlpha(150),
                              blurRadius: 20,
                              offset: const Offset(4, 8))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 4,
                            child: (imgPath != null &&
                                    File(imgPath).existsSync())
                                ? Image.file(File(imgPath), fit: BoxFit.cover)
                                : Container(
                                    color: kOakDeep,
                                    child: Icon(Icons.hardware,
                                        color: kRawSteel, size: 40.sp)),
                          ),
                          Container(
                              height: 2, color: kRawSteel), // Sharp divider
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding:
                                  EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    item.cooperageIdentifier.toUpperCase(),
                                    style: GoogleFonts.firaCode(
                                        color: color,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w800),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    item.manufacturer.toUpperCase(),
                                    style: GoogleFonts.archivo(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        height: 1.1,
                                        fontWeight: FontWeight.w800),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    item.presumedEra,
                                    style: GoogleFonts.dmSans(
                                        color: kRawSteel,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cyclone, color: kRawSteel, size: 64.sp),
          SizedBox(height: 20.h),
          Text('CENTRIFUGE EMPTY',
              style: GoogleFonts.firaCode(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0)),
          SizedBox(height: 8.h),
          Text('Add tools to engage cooperage physics.',
              style: GoogleFonts.dmSans(color: kRawSteel, fontSize: 15.sp)),
        ],
      ),
    );
  }

  Widget _buildHUD(int count) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
            20.w, MediaQuery.of(context).padding.top + 16.h, 20.w, 16.h),
        decoration: const BoxDecoration(
          color: kOakBg,
          border:
              Border(bottom: BorderSide(color: Color(0xFF332924), width: 2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CENTRIFUGAL SIMULATION',
                  style: GoogleFonts.firaCode(
                    color: kRawSteel,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                  ),
                ),
                Text(
                  'PHYSICS VAULT',
                  style: GoogleFonts.archivo(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: kOakDeep,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF332924), width: 2),
              ),
              child: Row(
                children: [
                  Text(
                    'NODES',
                    style: GoogleFonts.firaCode(
                        color: kRawSteel,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    count.toString().padLeft(2, '0'),
                    style: GoogleFonts.firaCode(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CentrifugePainter extends CustomPainter {
  final double centerX;
  final double centerY;
  final double maxRadius;
  final List<SawdustParticle> particles;

  _CentrifugePainter({
    required this.centerX,
    required this.centerY,
    required this.maxRadius,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(centerX, centerY);

    // 1. Barrel Interior (Aged Oak Gradient)
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [kOakBg, kOakDeep],
        stops: const [0.3, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Heavy Iron Hoop (Boundary)
    final hoopPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: maxRadius));

    canvas.drawPath(
        hoopPath,
        Paint()
          ..color = kOakDeep
          ..style = PaintingStyle.fill);

    canvas.drawPath(
        hoopPath,
        Paint()
          ..color = kIronRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14.0);

    // Industrial rivets on the hoop
    final rivetPaint = Paint()..color = const Color(0xFF1E1E20);
    for (int i = 0; i < 12; i++) {
      final angle = i * (math.pi / 6);
      canvas.drawCircle(
          Offset(center.dx + maxRadius * math.cos(angle),
              center.dy + maxRadius * math.sin(angle)),
          4.0,
          rivetPaint);
    }

    // 3. Sawdust Particles
    for (var p in particles) {
      final opacity = (p.life / p.maxLife).clamp(0.0, 1.0);
      final opacityVal = (opacity * 255).toInt();
      final pColor =
          const Color(0xFFD4B895).withAlpha(opacityVal); // Light wood color

      // Draw rectangular wood chips instead of circles
      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.dx * 0.1); // Spin based on velocity
      canvas.drawRect(
        Rect.fromCenter(
            center: Offset.zero, width: p.size, height: p.size * 0.4),
        Paint()..color = pColor,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CentrifugePainter oldDelegate) => true;
}
