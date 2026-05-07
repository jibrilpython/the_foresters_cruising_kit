import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:the_foresters_cruising_kit/enum/my_enums.dart';
import 'package:the_foresters_cruising_kit/models/project_model.dart';
import 'package:the_foresters_cruising_kit/providers/image_provider.dart';
import 'package:the_foresters_cruising_kit/providers/project_provider.dart';
import 'package:the_foresters_cruising_kit/utils/const.dart';

// Requested specific aesthetic colors for the Dendrochronology Core
const Color kHeartwoodRed = Color(0xFF5C2C16);
const Color kAgedBrass = Color(0xFFC5A059);
const Color kRawSteel = Color(0xFF54565B);
const Color kCanvasKhaki = Color(0xFFD3C5A3);

class _ItemNode {
  ForestryInstrumentModel item;
  final double angle; // resting angle on the log
  final double baseRadius; // resting radius (growth ring)

  double currentRadius;

  // Dragging state
  bool isDragging = false;
  Offset? dragOffset;

  _ItemNode({required this.item, required this.angle, required this.baseRadius})
    : currentRadius = baseRadius;
}

class ShowcaseScreen extends ConsumerStatefulWidget {
  const ShowcaseScreen({super.key});
  @override
  ConsumerState<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends ConsumerState<ShowcaseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _physicsController;

  List<_ItemNode> _nodes = [];
  _ItemNode? _focusedNode;

  double _logRotation = 0.0;
  double _angularVelocity = 0.0;

  double _lastHapticRotation = 0.0;

  double _blurSigma = 0.0;

  int _lastVersion = -1;
  Offset? _lastDragOffset;

  @override
  void initState() {
    super.initState();
    // Use an animation controller to drive the physics tick indefinitely
    _physicsController = AnimationController(
      vsync: this,
      duration: const Duration(days: 365),
    )..addListener(_tick);
    _physicsController.forward();
  }

  @override
  void dispose() {
    _physicsController.dispose();
    super.dispose();
  }

  void _tick() {
    final entries = ref.read(projectProvider).entries;
    final version = ref.read(projectProvider).stateVersion;
    if (version != _lastVersion) {
      _lastVersion = version;
      _rebuildNodes(entries);
    }

    if (!mounted) return;

    setState(() {
      // 1. High friction for log rotation
      if (_angularVelocity.abs() > 0.0) {
        _logRotation += _angularVelocity;

        // Haptic detent feedback based on distance rotated
        if ((_logRotation - _lastHapticRotation).abs() > 0.15) {
          HapticFeedback.selectionClick();
          _lastHapticRotation = _logRotation;
        }

        _angularVelocity *= 0.94; // high friction
        if (_angularVelocity.abs() < 0.001) {
          _angularVelocity = 0.0;
        }
      }

      // 2. Centrifugal force pushes nodes outward
      double speed = _angularVelocity.abs();
      double centrifugalPush = speed * 1500.0; // scales to velocity

      for (var node in _nodes) {
        if (node.isDragging || node == _focusedNode) continue;

        double targetRadius = node.baseRadius + centrifugalPush;

        if (targetRadius > node.currentRadius) {
          // Push outward quickly due to centrifugal force
          node.currentRadius += (targetRadius - node.currentRadius) * 0.3;
        } else {
          // Slide heavily back with low-frequency friction
          node.currentRadius += (node.baseRadius - node.currentRadius) * 0.08;
        }
      }

      // 3. Blur animation transition
      double targetBlur = _focusedNode != null ? 8.0 : 0.0;
      _blurSigma += (targetBlur - _blurSigma) * 0.15;
    });
  }

  void _rebuildNodes(List<ForestryInstrumentModel> entries) {
    if (entries.isEmpty) {
      _nodes = [];
      return;
    }

    final rng = math.Random(42);
    final existing = {for (final n in _nodes) n.item.id: n};

    _nodes = entries.asMap().entries.map((kv) {
      final index = kv.key;
      final e = kv.value;

      final ex = existing[e.id];
      if (ex != null) {
        ex.item = e; // Sync latest state
        return ex;
      }

      // Distribute nodes organically along growth rings outward from the pith
      double angle = rng.nextDouble() * 2 * math.pi;
      double radius = 90.0 + (index * 35.0 % 220.0) + (rng.nextDouble() * 25);

      return _ItemNode(item: e, angle: angle, baseRadius: radius);
    }).toList();

    if (_focusedNode != null &&
        !entries.any((e) => e.id == _focusedNode!.item.id)) {
      _focusedNode = null;
    }
  }

  // --- Log Gestures ---

  void _onPanStart(DragStartDetails details) {
    if (_focusedNode != null) return;
    final center = Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height / 2,
    );
    _lastDragOffset = details.localPosition - center;
    _angularVelocity = 0.0; // Stop immediately upon touch
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_focusedNode != null) return;

    final center = Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height / 2,
    );
    final offset = details.localPosition - center;
    final delta = details.delta;

    double crossProduct = offset.dx * delta.dy - offset.dy * delta.dx;
    double dTheta = crossProduct / (offset.distanceSquared + 1.0);

    setState(() {
      _logRotation += dTheta;
      _lastDragOffset = offset;

      // Haptic grinding as it turns manually
      if ((_logRotation - _lastHapticRotation).abs() > 0.1) {
        HapticFeedback.selectionClick();
        _lastHapticRotation = _logRotation;
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_focusedNode != null) return;

    if (_lastDragOffset != null) {
      final offset = _lastDragOffset!;
      final vel = details.velocity.pixelsPerSecond;
      double crossProduct = offset.dx * vel.dy - offset.dy * vel.dx;
      double angularVelSec = crossProduct / (offset.distanceSquared + 1.0);

      setState(() {
        _angularVelocity = angularVelSec / 60.0; // Convert to rad per frame
      });
    }
  }

  // --- Node Gestures ---

  void _onNodePanStart(_ItemNode node, DragStartDetails details) {
    if (_focusedNode != null) return;
    setState(() {
      node.isDragging = true;
      node.dragOffset = details.globalPosition;
    });
    HapticFeedback.heavyImpact(); // Deep thud picking it up
  }

  void _onNodePanUpdate(_ItemNode node, DragUpdateDetails details) {
    if (!node.isDragging) return;
    setState(() {
      node.dragOffset = details.globalPosition;
    });
  }

  void _onNodePanEnd(_ItemNode node, DragEndDetails details) {
    if (!node.isDragging) return;

    final center = Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height / 2,
    );
    final distanceToCenter = (node.dragOffset! - center).distance;

    setState(() {
      node.isDragging = false;
      if (distanceToCenter < 70.0) {
        // Locked into center (pith)
        _focusedNode = node;
        HapticFeedback.heavyImpact(); // Loud CRUNCH haptic snap
      } else {
        node.dragOffset = null;
        HapticFeedback.mediumImpact(); // Dropped back down
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageProv = ref.watch(imageProvider);
    final size = MediaQuery.of(context).size;
    final center = Offset(size.width / 2, size.height / 2);

    return Scaffold(
      backgroundColor: const Color(0xFFC7A27C), // Base wood color behind blur
      body: Stack(
        children: [
          // ── The massive high-friction timber log ──
          Positioned.fill(
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: ClipRect(
                child: ImageFiltered(
                  // Safe minimum sigma to avoid rendering assertions
                  imageFilter: ui.ImageFilter.blur(
                    sigmaX: math.max(0.001, _blurSigma),
                    sigmaY: math.max(0.001, _blurSigma),
                  ),
                  child: Transform.rotate(
                    angle: _logRotation,
                    child: CustomPaint(
                      size: size,
                      painter: _TimberLogPainter(),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Dark Overlay (Dims the log when focused) ──
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.black.withOpacity(
                  (_blurSigma / 8.0).clamp(0.0, 1.0) * 0.65,
                ),
              ),
            ),
          ),

          // ── Instrument Nodes ──
          ..._nodes.map((n) => _buildNodeWidget(n, center)),

          // ── Empty State ──
          if (_nodes.isEmpty)
            Center(
              child: IgnorePointer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.park_outlined,
                      size: 64.sp,
                      color: kHeartwoodRed.withAlpha(100),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'NO INSTRUMENTS LOGGED',
                      style: GoogleFonts.jetBrainsMono(
                        color: kHeartwoodRed.withAlpha(200),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Header (fades out when focused) ──
          if (_focusedNode == null && _nodes.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: IgnorePointer(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DENDROCHRONOLOGY CORE',
                          style: GoogleFonts.jetBrainsMono(
                            color: kHeartwoodRed,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.5,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Drag to center to focus.',
                          style: GoogleFonts.sora(
                            color: kPrimaryText,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ── Focus Panel (Flexible steel/waxed canvas unspool) ──
          if (_focusedNode != null)
            Positioned.fill(
              child: SafeArea(
                child: Center(child: _buildFocusPanel(imageProv)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNodeWidget(_ItemNode node, Offset center) {
    bool isFocused = _focusedNode == node;

    double x, y;
    if (isFocused) {
      x = center.dx;
      y = center.dy;
    } else if (node.isDragging && node.dragOffset != null) {
      x = node.dragOffset!.dx;
      y = node.dragOffset!.dy;
    } else {
      // Position based on log rotation and specific growth ring
      double finalAngle = node.angle + _logRotation;
      x = center.dx + math.cos(finalAngle) * node.currentRadius;
      y = center.dy + math.sin(finalAngle) * node.currentRadius;
    }

    final double nodeSize = 56.w;

    return Positioned(
      key: ValueKey(node.item.id),
      left: x - nodeSize / 2,
      top: y - nodeSize / 2,
      child: GestureDetector(
        onPanStart: (d) => _onNodePanStart(node, d),
        onPanUpdate: (d) => _onNodePanUpdate(node, d),
        onPanEnd: (d) => _onNodePanEnd(node, d),
        child: AnimatedScale(
          scale: isFocused ? 1.25 : (node.isDragging ? 1.15 : 1.0),
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutBack,
          child: Container(
            width: nodeSize,
            height: nodeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getToolColor(node.item.toolType),
              border: Border.all(
                color: isFocused ? Colors.white : kHeartwoodRed.withAlpha(120),
                width: isFocused ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(
                    isFocused || node.isDragging ? 100 : 40,
                  ),
                  blurRadius: isFocused || node.isDragging ? 16 : 8,
                  offset: Offset(0, isFocused || node.isDragging ? 8 : 4),
                ),
                // Harsh shadows for physical objects
                BoxShadow(
                  color: Colors.black.withAlpha(80),
                  blurRadius: 4,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                _getToolIcon(node.item.toolType),
                color: Colors.white,
                size: 24.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getToolColor(ToolType type) {
    switch (type) {
      case ToolType.clinometer:
        return kAgedBrass;
      case ToolType.abneyLevel:
        return kAgedBrass;
      case ToolType.diameterTape:
        return kAgedBrass;
      case ToolType.biltmoreStick:
        return kCanvasKhaki;
      case ToolType.logRule:
        return kCanvasKhaki;
      case ToolType.incrementBorer:
        return kRawSteel;
      case ToolType.timberScribe:
        return kRawSteel;
    }
  }

  IconData _getToolIcon(ToolType type) {
    switch (type) {
      case ToolType.clinometer:
        return Icons.explore;
      case ToolType.abneyLevel:
        return Icons.straighten;
      case ToolType.diameterTape:
        return Icons.all_inclusive;
      case ToolType.biltmoreStick:
        return Icons.square_foot;
      case ToolType.logRule:
        return Icons.linear_scale;
      case ToolType.incrementBorer:
        return Icons.build;
      case ToolType.timberScribe:
        return Icons.edit;
    }
  }

  Widget _buildFocusPanel(ImageNotifier imageProv) {
    final item = _focusedNode!.item;
    final imagePath = imageProv.getImagePath(item.photoPath);
    final hasImage =
        imagePath != null &&
        item.photoPath.isNotEmpty &&
        File(imagePath).existsSync();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 0.0), // Slides up unspooling
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        return Transform.translate(offset: Offset(0, val * 400), child: child);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: kCanvasKhaki, // Waxed canvas look
          borderRadius: BorderRadius.circular(kRadiusMedium),
          border: Border.all(color: kHeartwoodRed, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(120),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Inner padding and tone shift for realism
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: kBackground.withAlpha(220),
                borderRadius: BorderRadius.circular(kRadiusMedium - 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.toolType.label.toUpperCase(),
                          style: GoogleFonts.sora(
                            color: kHeartwoodRed,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _focusedNode = null;
                          });
                          HapticFeedback.mediumImpact();
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: kRawSteel.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: kHeartwoodRed,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  if (hasImage)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(kRadiusSubtle),
                      child: Image.file(
                        File(imagePath),
                        width: double.infinity,
                        height: 180.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (hasImage) SizedBox(height: 16.h),

                  // Metadata styled like an engraved diameter tape
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 12.h,
                      horizontal: 8.w,
                    ),
                    decoration: BoxDecoration(
                      color: kAgedBrass.withAlpha(40),
                      border: Border.all(color: kAgedBrass, width: 1.5),
                      borderRadius: BorderRadius.circular(kRadiusSubtle),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: _buildStatCol('SCALE', item.scaleSystem.label),
                        ),
                        Container(width: 1.5, height: 32.h, color: kAgedBrass),
                        Expanded(
                          child: _buildStatCol('ERA', item.eraOfProduction),
                        ),
                        Container(width: 1.5, height: 32.h, color: kAgedBrass),
                        Expanded(
                          child: _buildStatCol('ORIGIN', item.countryOfOrigin),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kHeartwoodRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(kRadiusSubtle),
                        ),
                      ),
                      onPressed: () {
                        final globalIndex = ref
                            .read(projectProvider)
                            .entries
                            .indexWhere((e) => e.id == item.id);
                        if (globalIndex != -1) {
                          Navigator.pushNamed(
                            context,
                            '/info_screen',
                            arguments: {'index': globalIndex},
                          );
                        }
                      },
                      child: Text(
                        'INSPECT INSTRUMENT',
                        style: GoogleFonts.sora(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCol(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            color: kHeartwoodRed.withAlpha(180),
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value.isNotEmpty ? value : '--',
          style: GoogleFonts.sora(
            color: kPrimaryText,
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Procedural vector rendering of tree rings ──
class _TimberLogPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Draw far beyond the screen so corners are never exposed when rotating
    final radiusMax = math.max(size.width, size.height) * 1.5;

    // Solid base wood
    final bgPaint = Paint()..color = const Color(0xFFC7A27C);
    canvas.drawRect(
      Rect.fromLTWH(-radiusMax, -radiusMax, radiusMax * 3, radiusMax * 3),
      bgPaint,
    );

    // Rings
    final ringPaint = Paint()..style = PaintingStyle.stroke;

    final rng = math.Random(12345);

    // Number of rings to draw
    int numRings = (radiusMax / 15.0).ceil();

    for (int i = 1; i <= numRings; i++) {
      ringPaint.strokeWidth = 1.0 + rng.nextDouble() * 1.5;
      ringPaint.color = kHeartwoodRed.withAlpha(15 + rng.nextInt(35));

      double r = i * 15.0;

      Path path = Path();
      for (int a = 0; a <= 360; a += 5) {
        double rad = a * math.pi / 180;
        // Perturbation to simulate organic wood grain
        double noise =
            math.sin(rad * 3) * 2.5 +
            math.cos(rad * 5) * 1.5 +
            math.sin(rad * 11) * 0.5;
        double radiusOffset =
            noise * (i / 10.0); // Rings get wobblier further out

        double x = center.dx + math.cos(rad) * (r + radiusOffset);
        double y = center.dy + math.sin(rad) * (r + radiusOffset);

        if (a == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, ringPaint);
    }

    // Pith (The very center of the log)
    final pithPaint = Paint()
      ..color = kHeartwoodRed.withAlpha(200)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 10, pithPaint);
    canvas.drawCircle(
      center,
      30,
      Paint()
        ..color = kHeartwoodRed.withAlpha(30)
        ..style = PaintingStyle.fill,
    );

    // Dark radial gradient around the pith to draw the eye to the center
    final gradientPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        100,
        [kHeartwoodRed.withAlpha(80), Colors.transparent],
        [0.0, 1.0],
      );
    canvas.drawCircle(center, 100, gradientPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
