import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_foresters_cruising_kit/enum/my_enums.dart';
import 'package:the_foresters_cruising_kit/providers/project_provider.dart';
import 'package:the_foresters_cruising_kit/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(projectProvider).entries;

    // Compute stats
    final toolCounts = <ToolType, int>{};
    final scaleCounts = <ScaleSystem, int>{};
    final condCounts = <ConditionGrade, int>{};
    final regionCounts = <TimberRegion, int>{};
    final eraCounts = <String, int>{};

    for (final e in entries) {
      toolCounts[e.toolType] = (toolCounts[e.toolType] ?? 0) + 1;
      scaleCounts[e.scaleSystem] = (scaleCounts[e.scaleSystem] ?? 0) + 1;
      condCounts[e.conditionGrade] = (condCounts[e.conditionGrade] ?? 0) + 1;
      regionCounts[e.timberRegion] = (regionCounts[e.timberRegion] ?? 0) + 1;
      if (e.eraOfProduction.isNotEmpty) {
        eraCounts[e.eraOfProduction] = (eraCounts[e.eraOfProduction] ?? 0) + 1;
      }
    }

    final total = entries.length;

    return Scaffold(
      backgroundColor: kBackground,
      body: total == 0 ? _buildEmpty() : CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverAppBar(
            expandedHeight: 140.h,
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
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Text('FIELD LOGBOOK // METRICS',
                      style: GoogleFonts.jetBrainsMono(color: kAccent, fontSize: 8.sp, fontWeight: FontWeight.w700, letterSpacing: 1.8)),
                  SizedBox(height: 2.h),
                  Text('Logbook', style: GoogleFonts.sora(color: kPrimaryText, fontSize: 28.sp, fontWeight: FontWeight.w700, height: 1.0)),
                ]),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 140.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Summary strip ──────────────────────────────────────
                _summaryStrip(entries.length, toolCounts.length, scaleCounts.length),
                SizedBox(height: 28.h),

                // ── Condition ring chart ───────────────────────────────
                _sectionLabel('CONDITION BREAKDOWN'),
                SizedBox(height: 16.h),
                SizedBox(
                  height: 200.h,
                  child: CustomPaint(
                    painter: _RingChartPainter(
                      segments: condCounts.entries
                          .map((kv) => _Segment(
                                label: kv.key.label,
                                value: kv.value.toDouble(),
                                color: getConditionColor(kv.key),
                              ))
                          .toList(),
                      total: total.toDouble(),
                    ),
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(total.toString(),
                            style: GoogleFonts.sora(color: kPrimaryText, fontSize: 32.sp, fontWeight: FontWeight.w700)),
                        Text('instruments',
                            style: GoogleFonts.inter(color: kSecondaryText, fontSize: 12.sp)),
                      ]),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w, runSpacing: 6.h,
                  children: condCounts.entries.map((kv) => _legendChip(kv.key.label, kv.value, getConditionColor(kv.key))).toList(),
                ),
                SizedBox(height: 28.h),

                // ── Tool type bars ─────────────────────────────────────
                _sectionLabel('TOOL TYPE DISTRIBUTION'),
                SizedBox(height: 16.h),
                ...ToolType.values.map((t) {
                  final count = toolCounts[t] ?? 0;
                  if (count == 0) return const SizedBox.shrink();
                  return _horizontalBar(t.label, count, total, getToolTypeColor(t));
                }),
                SizedBox(height: 28.h),

                // ── Scale system bars ──────────────────────────────────
                _sectionLabel('SCALE SYSTEM COVERAGE'),
                SizedBox(height: 16.h),
                ...ScaleSystem.values.map((s) {
                  final count = scaleCounts[s] ?? 0;
                  if (count == 0) return const SizedBox.shrink();
                  return _horizontalBar(s.label, count, total, getScaleSystemColor(s));
                }),
                SizedBox(height: 28.h),

                // ── Timber region ─────────────────────────────────────
                if (regionCounts.isNotEmpty) ...[
                  _sectionLabel('TIMBER REGIONS'),
                  SizedBox(height: 16.h),
                  ...TimberRegion.values.map((r) {
                    final count = regionCounts[r] ?? 0;
                    if (count == 0) return const SizedBox.shrink();
                    return _horizontalBar(r.label, count, total, kAccent);
                  }),
                  SizedBox(height: 28.h),
                ],

                // ── Era timeline ──────────────────────────────────────
                if (eraCounts.isNotEmpty) ...[
                  _sectionLabel('ERA TIMELINE'),
                  SizedBox(height: 16.h),
                  _buildEraTimeline(eraCounts, total),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.bar_chart_outlined, size: 48.sp, color: kOutline),
        SizedBox(height: 16.h),
        Text('NO DATA YET.',
            style: GoogleFonts.jetBrainsMono(color: kSecondaryText, fontSize: 13.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 6.h),
        Text('Log instruments to see metrics here.',
            style: GoogleFonts.inter(color: kSecondaryText.withAlpha(140), fontSize: 13.sp)),
      ]),
    );
  }

  Widget _summaryStrip(int total, int typeCount, int scaleCount) {
    return Row(children: [
      _statCard(total.toString(), 'Instruments', kAccent),
      SizedBox(width: 10.w),
      _statCard(typeCount.toString(), 'Tool Types', kGold),
      SizedBox(width: 10.w),
      _statCard(scaleCount.toString(), 'Scale Systems', kMatSteel),
    ]);
  }

  Widget _statCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(color: kOutline, width: 1),
        ),
        child: Column(children: [
          Text(value, style: GoogleFonts.sora(color: color, fontSize: 26.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 4.h),
          Text(label, style: GoogleFonts.inter(color: kSecondaryText, fontSize: 11.sp), textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(label,
        style: GoogleFonts.jetBrainsMono(color: kSecondaryText, fontSize: 9.sp, fontWeight: FontWeight.w700, letterSpacing: 1.2));
  }

  Widget _horizontalBar(String label, int count, int total, Color color) {
    final frac = total > 0 ? count / total : 0.0;
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text(label,
              style: GoogleFonts.inter(color: kPrimaryText, fontSize: 13.sp, fontWeight: FontWeight.w500),
              maxLines: 1, overflow: TextOverflow.ellipsis)),
          Text('$count', style: GoogleFonts.jetBrainsMono(color: kSecondaryText, fontSize: 11.sp, fontWeight: FontWeight.w600)),
        ]),
        SizedBox(height: 6.h),
        LayoutBuilder(builder: (context, constraints) {
          return Stack(children: [
            Container(height: 6.h, width: double.infinity,
                decoration: BoxDecoration(color: kOutline, borderRadius: BorderRadius.circular(kRadiusPill))),
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              height: 6.h,
              width: constraints.maxWidth * frac,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(kRadiusPill)),
            ),
          ]);
        }),
      ]),
    );
  }

  Widget _legendChip(String label, int count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(kRadiusPill),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6.w, height: 6.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 6.w),
        Text('$label ($count)', style: GoogleFonts.inter(color: kPrimaryText, fontSize: 11.sp)),
      ]),
    );
  }

  Widget _buildEraTimeline(Map<String, int> eraCounts, int total) {
    final sorted = eraCounts.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kOutline, width: 1),
      ),
      child: Column(
        children: sorted.asMap().entries.map((entry) {
          final idx = entry.key;
          final kv = entry.value;
          final frac = total > 0 ? kv.value / total : 0.0;
          final isLast = idx == sorted.length - 1;
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: 52.w,
              child: Text(kv.key,
                  style: GoogleFonts.jetBrainsMono(color: kGold, fontSize: 10.sp, fontWeight: FontWeight.w600)),
            ),
            SizedBox(width: 10.w),
            Column(children: [
              Container(width: 8.w, height: 8.w,
                  decoration: BoxDecoration(color: kAccent, shape: BoxShape.circle)),
              if (!isLast)
                Container(width: 1, height: 30.h, color: kOutline),
            ]),
            SizedBox(width: 10.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 22.h),
                child: Row(children: [
                  Expanded(
                    child: Container(
                      height: 6.h,
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(color: kOutline, borderRadius: BorderRadius.circular(kRadiusPill)),
                      child: FractionallySizedBox(
                        widthFactor: frac,
                        child: Container(
                          decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(kRadiusPill)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text('${kv.value}',
                      style: GoogleFonts.jetBrainsMono(color: kSecondaryText, fontSize: 10.sp)),
                ]),
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }
}

class _Segment {
  final String label;
  final double value;
  final Color color;
  const _Segment({required this.label, required this.value, required this.color});
}

class _RingChartPainter extends CustomPainter {
  final List<_Segment> segments;
  final double total;
  const _RingChartPainter({required this.segments, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = math.min(cx, cy) * 0.9;
    final innerR = outerR * 0.62;

    double startAngle = -math.pi / 2;
    for (final seg in segments) {
      final sweep = (seg.value / total) * 2 * math.pi;
      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = outerR - innerR
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: (outerR + innerR) / 2),
        startAngle,
        sweep - 0.04,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _RingChartPainter old) =>
      old.segments != segments || old.total != total;
}
