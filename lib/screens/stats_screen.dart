import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_foresters_cruising_kit/enum/my_enums.dart';
import 'package:the_foresters_cruising_kit/providers/project_provider.dart';
import 'package:the_foresters_cruising_kit/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});
  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(projectProvider).entries;
    final total = entries.length;

    if (total == 0) {
      return Scaffold(backgroundColor: kBackground, body: _buildEmpty());
    }

    final toolCounts = <ToolType, int>{};
    final scaleCounts = <ScaleSystem, int>{};
    final condCounts = <ConditionGrade, int>{};
    final eraCounts = <String, int>{};

    for (final e in entries) {
      toolCounts[e.toolType] = (toolCounts[e.toolType] ?? 0) + 1;
      scaleCounts[e.scaleSystem] = (scaleCounts[e.scaleSystem] ?? 0) + 1;
      condCounts[e.conditionGrade] = (condCounts[e.conditionGrade] ?? 0) + 1;
      if (e.eraOfProduction.isNotEmpty) {
        eraCounts[e.eraOfProduction] = (eraCounts[e.eraOfProduction] ?? 0) + 1;
      }
    }

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──
          SliverAppBar(
            expandedHeight: 120.h,
            pinned: true,
            backgroundColor: kBackground,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 20.w, bottom: 16.h),
              centerTitle: false,
              title: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'FIELD LOGBOOK // METRICS',
                      style: GoogleFonts.jetBrainsMono(
                        color: kAccent,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Analytics',
                      style: GoogleFonts.sora(
                        color: kPrimaryText,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 140.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. Interactive Summary Strip
                _SummaryStrip(
                  total: total,
                  typeCount: toolCounts.length,
                  scaleCount: scaleCounts.length,
                ),
                SizedBox(height: 36.h),

                // 2. Interactive Precision Dial (Condition)
                _sectionLabel('CONDITION GRADE DISTRIBUTION'),
                SizedBox(height: 16.h),
                _InteractivePrecisionDial(data: condCounts, total: total),
                SizedBox(height: 36.h),

                // 3. Interactive Tool Type Bars
                _sectionLabel('INSTRUMENT CLASSIFICATION'),
                SizedBox(height: 16.h),
                _InteractiveBarList(
                  title: 'Tool Types',
                  data: toolCounts
                      .map(
                        (key, value) => MapEntry(
                          key.label,
                          _BarData(value, getToolTypeColor(key)),
                        ),
                      )
                      .entries,
                  total: total,
                ),
                SizedBox(height: 36.h),

                // 4. Scale System Coverage
                _sectionLabel('LOG SCALE SYSTEM CALIBRATIONS'),
                SizedBox(height: 16.h),
                _InteractiveBarList(
                  title: 'Scale Systems',
                  data: scaleCounts
                      .map(
                        (key, value) => MapEntry(
                          key.label,
                          _BarData(value, getScaleSystemColor(key)),
                        ),
                      )
                      .entries,
                  total: total,
                ),
                SizedBox(height: 36.h),

                // 5. Era Timeline (Measuring Tape)
                if (eraCounts.isNotEmpty) ...[
                  _sectionLabel('ERA OF PRODUCTION'),
                  SizedBox(height: 16.h),
                  _EraTimeline(eraCounts: eraCounts, total: total),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(width: 4.w, height: 12.h, color: kAccent),
        SizedBox(width: 8.w),
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            color: kSecondaryText,
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart_outlined, size: 48.sp, color: kOutline),
          SizedBox(height: 16.h),
          Text(
            'NO DATA YET.',
            style: GoogleFonts.jetBrainsMono(
              color: kSecondaryText,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Log instruments to see metrics here.',
            style: GoogleFonts.inter(
              color: kSecondaryText.withAlpha(140),
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 1. Summary Strip ──────────────────────────────────────────────────────────
class _SummaryStrip extends StatelessWidget {
  final int total;
  final int typeCount;
  final int scaleCount;

  const _SummaryStrip({
    required this.total,
    required this.typeCount,
    required this.scaleCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _statCard('INSTRUMENTS', total, kAccent),
        SizedBox(width: 10.w),
        _statCard('TOOL TYPES', typeCount, kGold),
        SizedBox(width: 10.w),
        _statCard('SCALES', scaleCount, kMatSteel),
      ],
    );
  }

  Widget _statCard(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(color: kOutline, width: 1),
          boxShadow: const [kShadowSubtle],
        ),
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1400),
              curve: Curves.easeOutExpo,
              tween: Tween(begin: 0, end: value.toDouble()),
              builder: (context, val, child) {
                return Text(
                  val.toInt().toString(),
                  style: GoogleFonts.jetBrainsMono(
                    color: color,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                  ),
                );
              },
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: GoogleFonts.inter(
                color: kSecondaryText,
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 2. Interactive Precision Dial ───────────────────────────────────────────
class _InteractivePrecisionDial extends StatefulWidget {
  final Map<ConditionGrade, int> data;
  final int total;
  const _InteractivePrecisionDial({required this.data, required this.total});

  @override
  State<_InteractivePrecisionDial> createState() =>
      _InteractivePrecisionDialState();
}

class _InteractivePrecisionDialState extends State<_InteractivePrecisionDial> {
  ConditionGrade? _selected;

  @override
  Widget build(BuildContext context) {
    final entries = widget.data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kOutline, width: 1),
        boxShadow: const [kShadowSubtle],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 220.h,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cx = constraints.maxWidth / 2;
                final cy = constraints.maxHeight / 2;

                return GestureDetector(
                  onTapUp: (details) {
                    final dx = details.localPosition.dx - cx;
                    final dy = details.localPosition.dy - cy;
                    final dist = math.sqrt(dx * dx + dy * dy);

                    final outerR = math.min(cx, cy) * 0.95;
                    final innerR = outerR * 0.55;

                    if (dist >= innerR - 10 && dist <= outerR + 20) {
                      double tapAngle =
                          (math.atan2(dy, dx) + math.pi / 2) % (2 * math.pi);
                      if (tapAngle < 0) {
                        tapAngle += 2 * math.pi;
                      }

                      double currentAngle = 0;
                      bool found = false;
                      for (final e in entries) {
                        final sweep = (e.value / widget.total) * 2 * math.pi;
                        if (tapAngle >= currentAngle &&
                            tapAngle <= currentAngle + sweep) {
                          setState(() {
                            if (_selected == e.key) {
                              _selected = null;
                            } else {
                              _selected = e.key;
                              HapticFeedback.selectionClick();
                            }
                          });
                          found = true;
                          break;
                        }
                        currentAngle += sweep;
                      }
                      if (!found) {
                        setState(() => _selected = null);
                      }
                    } else {
                      setState(() => _selected = null);
                    }
                  },
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, anim, child) {
                      return CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: _DialPainter(
                          entries: entries,
                          total: widget.total,
                          selected: _selected,
                          animation: anim,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 24.h),
          _buildReadout(entries),
        ],
      ),
    );
  }

  Widget _buildReadout(List<MapEntry<ConditionGrade, int>> entries) {
    if (_selected == null) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: kBackground,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(color: kOutline),
        ),
        child: Center(
          child: Text(
            'TAP A SECTOR FOR DETAILS',
            style: GoogleFonts.jetBrainsMono(
              color: kSecondaryText,
              fontSize: 11.sp,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final count = widget.data[_selected]!;
    final pct = (count / widget.total * 100).toStringAsFixed(1);
    final color = getConditionColor(_selected!);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selected!.label.toUpperCase(),
                        style: GoogleFonts.sora(
                          color: kPrimaryText,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '$count INSTRUMENT${count == 1 ? '' : 'S'}',
                        style: GoogleFonts.jetBrainsMono(
                          color: kSecondaryText,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$pct%',
            style: GoogleFonts.jetBrainsMono(
              color: color,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  final List<MapEntry<ConditionGrade, int>> entries;
  final int total;
  final ConditionGrade? selected;
  final double animation;

  _DialPainter({
    required this.entries,
    required this.total,
    required this.selected,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = math.min(cx, cy) * 0.9;
    final innerR = outerR * 0.55;

    // Draw background precision dial ticks
    final tickPaint = Paint()
      ..color = kOutline
      ..strokeWidth = 1.0;
    for (int i = 0; i < 72; i++) {
      final angle = i * (2 * math.pi / 72);
      final isMajor = i % 18 == 0;
      final tickOuter = outerR + (isMajor ? 8 : 4);
      canvas.drawLine(
        Offset(cx + math.cos(angle) * outerR, cy + math.sin(angle) * outerR),
        Offset(
          cx + math.cos(angle) * tickOuter,
          cy + math.sin(angle) * tickOuter,
        ),
        tickPaint..color = isMajor ? kSecondaryText.withAlpha(150) : kOutline,
      );
    }

    double startAngle = -math.pi / 2;
    for (final e in entries) {
      final sweep = (e.value / total) * 2 * math.pi * animation;
      final isSelected = selected == e.key;

      final segOuterR = outerR + (isSelected ? 10.0 : 0.0);

      final paint = Paint()
        ..color = getConditionColor(
          e.key,
        ).withAlpha(selected == null || isSelected ? 255 : 100)
        ..style = PaintingStyle.stroke
        ..strokeWidth = segOuterR - innerR
        ..strokeCap = StrokeCap.butt;

      if (isSelected) {
        final shadowPaint = Paint()
          ..color = getConditionColor(e.key).withAlpha(60)
          ..style = PaintingStyle.stroke
          ..strokeWidth = segOuterR - innerR + 6
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
        canvas.drawArc(
          Rect.fromCircle(
            center: Offset(cx, cy),
            radius: (segOuterR + innerR) / 2,
          ),
          startAngle,
          math.max(0.001, sweep),
          false,
          shadowPaint,
        );
      }

      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(cx, cy),
          radius: (segOuterR + innerR) / 2,
        ),
        startAngle,
        math.max(0.001, sweep),
        false,
        paint,
      );

      startAngle += sweep;
    }

    // Draw center reticle
    canvas.drawCircle(
      Offset(cx, cy),
      3,
      Paint()
        ..color = kSecondaryText
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx, cy),
      innerR - 12,
      Paint()
        ..color = kOutline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) => true;
}

// ─── 3. Interactive Bar Lists ────────────────────────────────────────────────
class _BarData {
  final int count;
  final Color color;
  _BarData(this.count, this.color);
}

class _InteractiveBarList extends StatefulWidget {
  final String title;
  final Iterable<MapEntry<String, _BarData>> data;
  final int total;
  const _InteractiveBarList({
    required this.title,
    required this.data,
    required this.total,
  });

  @override
  State<_InteractiveBarList> createState() => _InteractiveBarListState();
}

class _InteractiveBarListState extends State<_InteractiveBarList> {
  String? _expandedKey;

  @override
  Widget build(BuildContext context) {
    final sorted = widget.data.toList()
      ..sort((a, b) => b.value.count.compareTo(a.value.count));

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kOutline, width: 1),
        boxShadow: const [kShadowSubtle],
      ),
      child: Column(
        children: sorted
            .map((e) => _buildBar(e.key, e.value.count, e.value.color))
            .toList(),
      ),
    );
  }

  Widget _buildBar(String label, int count, Color color) {
    final isExpanded = _expandedKey == label;
    final frac = widget.total > 0 ? count / widget.total : 0.0;
    final pct = (frac * 100).toStringAsFixed(1);

    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedKey = isExpanded ? null : label;
        });
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(isExpanded ? 12.w : 0),
        decoration: BoxDecoration(
          color: isExpanded ? kBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: isExpanded
              ? Border.all(color: kOutline)
              : Border.all(color: Colors.transparent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    label.toUpperCase(),
                    style: GoogleFonts.sora(
                      color: isExpanded ? color : kPrimaryText,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '$count',
                  style: GoogleFonts.jetBrainsMono(
                    color: isExpanded ? color : kSecondaryText,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Container(
                      height: 8.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: kOutline.withAlpha(150),
                        borderRadius: BorderRadius.circular(kRadiusPill),
                      ),
                    ),
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutExpo,
                      tween: Tween(begin: 0, end: frac),
                      builder: (context, anim, child) {
                        return Container(
                          height: 8.h,
                          width: constraints.maxWidth * anim,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(kRadiusPill),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),

            // Expanded Detail
            if (isExpanded) ...[
              SizedBox(height: 12.h),
              Divider(color: kOutline, height: 1),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PORTION OF INVENTORY',
                    style: GoogleFonts.inter(
                      color: kSecondaryText,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$pct%',
                    style: GoogleFonts.jetBrainsMono(
                      color: kPrimaryText,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── 4. Era Timeline (Measuring Tape) ────────────────────────────────────────
class _EraTimeline extends StatelessWidget {
  final Map<String, int> eraCounts;
  final int total;

  const _EraTimeline({required this.eraCounts, required this.total});

  @override
  Widget build(BuildContext context) {
    final sorted = eraCounts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kGold, // Yellow steel measuring tape
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: const Color(0xFF8B5E1A), width: 1.5),
        boxShadow: const [kShadowSubtle],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
            child: Text(
              'PRODUCTION TIMELINE',
              style: GoogleFonts.jetBrainsMono(
                color: const Color(0xFF4A3510),
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
          SizedBox(
            height: 90.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final kv = sorted[index];
                return _buildTapeMarker(kv.key, kv.value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTapeMarker(String era, int count) {
    return Container(
      margin: EdgeInsets.only(right: 48.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                era.toUpperCase(),
                style: GoogleFonts.jetBrainsMono(
                  color: kPrimaryText,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: kPrimaryText,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.jetBrainsMono(
                    color: kGold,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Tape ticks mimicking an actual steel measuring tape
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(width: 2.5.w, height: 24.h, color: kPrimaryText),
              SizedBox(width: 8.w),
              Container(
                width: 1.5.w,
                height: 12.h,
                color: const Color(0xFF6B4A15),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 1.5.w,
                height: 16.h,
                color: const Color(0xFF6B4A15),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 1.5.w,
                height: 12.h,
                color: const Color(0xFF6B4A15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
