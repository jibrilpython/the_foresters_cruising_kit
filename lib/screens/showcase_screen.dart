import 'dart:math' as math;
import 'package:flutter/scheduler.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_foresters_cruising_kit/enum/my_enums.dart';
import 'package:the_foresters_cruising_kit/models/project_model.dart';
import 'package:the_foresters_cruising_kit/providers/image_provider.dart';
import 'package:the_foresters_cruising_kit/providers/project_provider.dart';
import 'package:the_foresters_cruising_kit/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Physics node ─────────────────────────────────────────────────────────────
class _RingNode {
  final ToolType type;
  final int count;
  double x, y, vx, vy;
  double radius;
  double targetX, targetY;

  _RingNode({
    required this.type,
    required this.count,
    required this.x,
    required this.y,
    required this.radius,
  })  : vx = (math.Random().nextDouble() - 0.5) * 0.5,
        vy = (math.Random().nextDouble() - 0.5) * 0.5,
        targetX = x,
        targetY = y;
}

class ShowcaseScreen extends ConsumerStatefulWidget {
  const ShowcaseScreen({super.key});
  @override
  ConsumerState<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends ConsumerState<ShowcaseScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  List<_RingNode> _nodes = [];
  _RingNode? _focusedNode;
  // focused items derived live from entries on demand
  Offset? _dragOffset;
  int _lastVersion = -1;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    final entries = ref.read(projectProvider).entries;
    final version = ref.read(projectProvider).stateVersion;
    if (version != _lastVersion) {
      _lastVersion = version;
      _rebuildNodes(entries);
    }
    if (!mounted) return;
    setState(() => _updatePhysics());
  }

  void _rebuildNodes(List<ForestryInstrumentModel> entries) {
    final counts = <ToolType, int>{};
    for (final e in entries) {
      counts[e.toolType] = (counts[e.toolType] ?? 0) + 1;
    }
    if (counts.isEmpty) { _nodes = []; return; }

    final rng = math.Random(42);
    final cx = 195.0;
    final cy = 400.0;
    final existing = {for (final n in _nodes) n.type: n};

    _nodes = counts.entries.map((kv) {
      final r = 28.0 + kv.value * 12.0;
      final ex = existing[kv.key];
      return _RingNode(
        type: kv.key,
        count: kv.value,
        x: ex?.x ?? (cx + (rng.nextDouble() - 0.5) * 200),
        y: ex?.y ?? (cy + (rng.nextDouble() - 0.5) * 200),
        radius: r.clamp(28.0, 72.0),
      );
    }).toList();

    // If focused node no longer exists, clear focus
    if (_focusedNode != null) {
      final match = _nodes.where((n) => n.type == _focusedNode!.type);
      _focusedNode = match.isEmpty ? null : match.first;
    }
  }

  void _updatePhysics() {
    if (_nodes.isEmpty) return;
    final size = Size(390.w, 844.h);
    const friction = 0.92;
    const attract = 0.018;
    const repulse = 2200.0;
    const bounce = 0.45;

    final cx = size.width / 2;
    final cy = _focusedNode == null ? size.height * 0.42 : size.height * 0.28;

    for (int i = 0; i < _nodes.length; i++) {
      final n = _nodes[i];
      if (_dragOffset != null && n == _focusedNode) continue;

      // Gravity toward centre
      n.vx += (cx - n.x) * attract;
      n.vy += (cy - n.y) * attract;

      // Node–node repulsion
      for (int j = i + 1; j < _nodes.length; j++) {
        final o = _nodes[j];
        final dx = n.x - o.x;
        final dy = n.y - o.y;
        final dist2 = dx * dx + dy * dy + 0.1;
        final minDist = n.radius + o.radius + 12;
        if (dist2 < minDist * minDist) {
          final f = repulse / dist2;
          n.vx += dx * f;
          n.vy += dy * f;
          o.vx -= dx * f;
          o.vy -= dy * f;
        }
      }

      n.vx *= friction;
      n.vy *= friction;
      n.x += n.vx;
      n.y += n.vy;

      // Wall bounce
      if (n.x - n.radius < 0) { n.x = n.radius; n.vx = n.vx.abs() * bounce; }
      if (n.x + n.radius > size.width) { n.x = size.width - n.radius; n.vx = -n.vx.abs() * bounce; }
      if (n.y - n.radius < 80) { n.y = 80 + n.radius; n.vy = n.vy.abs() * bounce; }
      if (n.y + n.radius > size.height * 0.72) { n.y = size.height * 0.72 - n.radius; n.vy = -n.vy.abs() * bounce; }
    }
  }

  void _onTapNode(_RingNode node) {
    setState(() {
      if (_focusedNode?.type == node.type) {
        _focusedNode = null;
      } else {
        _focusedNode = node;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(projectProvider).entries;
    final imageProv = ref.watch(imageProvider);

    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          // ── Canvas background (growth ring field) ──────────────────────
          Positioned.fill(
            child: CustomPaint(painter: _ForestFloorPainter()),
          ),

          // ── Header ─────────────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('FOREST STAND',
                      style: GoogleFonts.jetBrainsMono(
                          color: kAccent, fontSize: 9.sp, fontWeight: FontWeight.w700, letterSpacing: 2.0)),
                  SizedBox(height: 2.h),
                  Text('Tool Type Distribution',
                      style: GoogleFonts.sora(
                          color: kPrimaryText, fontSize: 22.sp, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ),

          // ── Physics canvas ─────────────────────────────────────────────
          entries.isEmpty
              ? _buildEmptyState()
              : GestureDetector(
                  onPanUpdate: (d) {
                    if (_focusedNode != null) {
                      setState(() {
                        _focusedNode!.x += d.delta.dx;
                        _focusedNode!.y += d.delta.dy;
                        _focusedNode!.vx = d.delta.dx;
                        _focusedNode!.vy = d.delta.dy;
                      });
                    }
                  },
                  child: CustomPaint(
                    size: Size(double.infinity, double.infinity),
                    painter: _NodesPainter(nodes: _nodes, focusedNode: _focusedNode),
                    child: Stack(
                      children: _nodes.map((n) => _buildNodeWidget(n)).toList(),
                    ),
                  ),
                ),

          // ── Focused panel ──────────────────────────────────────────────
          if (_focusedNode != null)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _buildFocusPanel(imageProv),
            ),
        ],
      ),
    );
  }

  Widget _buildNodeWidget(_RingNode node) {
    final isFocused = _focusedNode?.type == node.type;
    return Positioned(
      left: node.x - node.radius,
      top: node.y - node.radius,
      child: GestureDetector(
        onTap: () => _onTapNode(node),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          width: node.radius * 2,
          height: node.radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFocused
                ? getToolTypeColor(node.type)
                : getToolTypeColor(node.type).withAlpha(220),
            border: Border.all(
              color: isFocused ? Colors.white : getToolTypeColor(node.type).withAlpha(80),
              width: isFocused ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: getToolTypeColor(node.type).withAlpha(isFocused ? 100 : 40),
                blurRadius: isFocused ? 24 : 8,
              ),
            ],
          ),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                node.count.toString(),
                style: GoogleFonts.sora(
                  color: Colors.white,
                  fontSize: node.radius * 0.52,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              if (node.radius > 34.w)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Text(
                    node.type.label,
                    style: GoogleFonts.inter(
                      color: Colors.white.withAlpha(200),
                      fontSize: node.radius * 0.19,
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildFocusPanel(ImageNotifier imageProv) {
    final node = _focusedNode!;
    final items = ref.read(projectProvider).entries.where((e) => e.toolType == node.type).toList();
    return Container(
      constraints: BoxConstraints(maxHeight: 340.h),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadiusMedium)),
        border: const Border(top: BorderSide(color: kOutline, width: 1)),
        boxShadow: const [kShadowFloat],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Padding(
          padding: EdgeInsets.only(top: 12.h),
          child: Container(
            width: 36.w, height: 4.h,
            decoration: BoxDecoration(color: kOutline, borderRadius: BorderRadius.circular(kRadiusPill)),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 0),
          child: Row(children: [
            Container(
              width: 8.w, height: 8.w,
              decoration: BoxDecoration(color: getToolTypeColor(node.type), shape: BoxShape.circle),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(node.type.label,
                  style: GoogleFonts.sora(color: kPrimaryText, fontSize: 18.sp, fontWeight: FontWeight.w700)),
            ),
            GestureDetector(
              onTap: () => setState(() { _focusedNode = null; }),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(color: kBackground, borderRadius: BorderRadius.circular(kRadiusSubtle), border: Border.all(color: kOutline)),
                child: Icon(Icons.close, size: 16.sp, color: kPrimaryText),
              ),
            ),
          ]),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 220.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            itemCount: items.length,
            itemBuilder: (context, idx) {
              final item = items[idx];
              final globalIndex = ref.read(projectProvider).entries.indexWhere((e) => e.id == item.id);
              if (globalIndex == -1) return const SizedBox.shrink();
              final imagePath = imageProv.getImagePath(item.photoPath);
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/info_screen', arguments: {'index': globalIndex}),
                child: Container(
                  width: 160.w,
                  margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: kBackground,
                    borderRadius: BorderRadius.circular(kRadiusSubtle),
                    border: Border.all(color: kOutline, width: 1),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      flex: 3,
                      child: (imagePath != null && item.photoPath.isNotEmpty && File(imagePath).existsSync())
                          ? Image.file(File(imagePath), fit: BoxFit.cover, width: double.infinity)
                          : Container(
                              color: kBackground,
                              child: Center(child: Icon(Icons.landscape_outlined, color: kOutline, size: 28.sp)),
                            ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.all(10.w),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(
                            item.manufacturer.isNotEmpty ? item.manufacturer : 'Unknown',
                            style: GoogleFonts.sora(color: kPrimaryText, fontSize: 12.sp, fontWeight: FontWeight.w600),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            item.scaleSystem.label,
                            style: GoogleFonts.jetBrainsMono(color: kGold, fontSize: 9.sp),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ]),
                      ),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
      ]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        CustomPaint(size: Size(80.w, 80.w), painter: _EmptyRingsPainter()),
        SizedBox(height: 24.h),
        Text('NO INSTRUMENTS IN THE STAND YET.',
            style: GoogleFonts.jetBrainsMono(
                color: kSecondaryText, fontSize: 11.sp, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        SizedBox(height: 8.h),
        Text('Log instruments to see them appear here.',
            style: GoogleFonts.inter(color: kSecondaryText.withAlpha(140), fontSize: 13.sp)),
      ]),
    );
  }
}

// ─── Forest floor background painter (faint growth rings) ────────────────────
class _ForestFloorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kOutline.withAlpha(60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Three scattered ring clusters
    final centers = [
      Offset(size.width * 0.15, size.height * 0.1),
      Offset(size.width * 0.9, size.height * 0.08),
      Offset(size.width * 0.5, size.height * 0.85),
    ];
    for (final c in centers) {
      for (int i = 1; i <= 5; i++) {
        canvas.drawCircle(c, i * 32.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── Nodes painter (shadows between nodes) ────────────────────────────────────
class _NodesPainter extends CustomPainter {
  final List<_RingNode> nodes;
  final _RingNode? focusedNode;

  const _NodesPainter({required this.nodes, required this.focusedNode});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw connecting lines between overlapping nodes (subtle)
    final linePaint = Paint()
      ..color = kOutline.withAlpha(60)
      ..strokeWidth = 0.8;
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final dx = nodes[i].x - nodes[j].x;
        final dy = nodes[i].y - nodes[j].y;
        final dist = math.sqrt(dx * dx + dy * dy);
        if (dist < 180) {
          canvas.drawLine(Offset(nodes[i].x, nodes[i].y), Offset(nodes[j].x, nodes[j].y), linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NodesPainter old) => true;
}

// ─── Empty state rings painter ────────────────────────────────────────────────
class _EmptyRingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()
      ..color = kOutline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(Offset(cx, cy), size.width / 2 * (i / 4), paint);
    }
    canvas.drawCircle(Offset(cx, cy), 3, Paint()..color = kSecondaryText.withAlpha(80));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
