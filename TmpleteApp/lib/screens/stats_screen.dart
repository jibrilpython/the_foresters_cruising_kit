import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:coopering_croze_barrel/enum/my_enums.dart';
import 'package:coopering_croze_barrel/models/project_model.dart';
import 'package:coopering_croze_barrel/providers/project_provider.dart';
import 'package:coopering_croze_barrel/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  int? _selectedDecadeIndex;

  static const List<String> _eras = [
    '1820s', '1840s', '1860s', '1880s', '1900s', '1920s', '1940s'
  ];

  String? _decadeFromEra(String era) {
    if (era.isEmpty) return null;
    if (RegExp(r'^\d{3}0s$').hasMatch(era)) return era;
    final clean = era.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length < 4) return null;
    final year = int.tryParse(clean.substring(0, 4));
    if (year != null) return '${(year ~/ 10) * 10}s';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final projectProv = ref.watch(projectProvider);
    final allEntries = projectProv.entries;

    final selectedEra = _selectedDecadeIndex != null ? _eras[_selectedDecadeIndex!] : null;
    final displayEntries = selectedEra == null
        ? allEntries
        : allEntries.where((e) => _decadeFromEra(e.presumedEra) == selectedEra).toList();

    return Scaffold(
      backgroundColor: kBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: kBackground.withAlpha(200)),
          ),
        ),
        title: Text(
          'METRICS // VAULT',
          style: GoogleFonts.firaCode(fontSize: 14.sp, fontWeight: FontWeight.w800, letterSpacing: 2.0, color: kAccent),
        ),
        centerTitle: true,
      ),
      body: allEntries.isEmpty
          ? _buildEmptyState()
          : CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, MediaQuery.of(context).padding.top + 70.h, 20.w, 140.h),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildRegistryStatus(allEntries),
                      SizedBox(height: 32.h),
                      _sectionHeader('GEODETIC ERA CHRONOLOGY'),
                      _buildBlueprintTimeline(allEntries),
                      SizedBox(height: 32.h),
                      _sectionHeader('DISTRIBUTION ANALYSIS'),
                      _buildBarrelTypeMetrics(displayEntries),
                      SizedBox(height: 24.h),
                      Row(
                        children: [
                          Expanded(child: _buildGaugeNode<ManufacturingMaterial>(
                            title: 'MATERIAL',
                            counts: _getCounts<ManufacturingMaterial>(displayEntries, (e) => e.manufacturingMaterial),
                            total: displayEntries.length,
                            colorFn: getMaterialColor,
                            labelFn: (m) => m.label,
                          )),
                          SizedBox(width: 16.w),
                          Expanded(child: _buildGaugeNode<CrozeCondition>(
                            title: 'CONDITION',
                            counts: _getCounts<CrozeCondition>(displayEntries, (e) => e.conditionState),
                            total: displayEntries.length,
                            colorFn: getConditionColor,
                            labelFn: (c) => c.label.split('—').first,
                          )),
                        ],
                      ),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }

  Map<T, int> _getCounts<T>(List<CrozeModel> entries, T Function(CrozeModel) selector) {
    final Map<T, int> counts = {};
    for (var e in entries) {
      final val = selector(e);
      counts[val] = (counts[val] ?? 0) + 1;
    }
    return counts;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.analytics_outlined, color: kAccent.withAlpha(100), size: 64.sp),
          SizedBox(height: 24.h),
          Text('VAULT DATA OFFLINE', style: GoogleFonts.firaCode(color: kPrimaryText, fontSize: 13.sp, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
          SizedBox(height: 8.h),
          Text('Log tools to generate cooperage metrics.', style: GoogleFonts.dmSans(color: kSecondaryText, fontSize: 14.sp)),
        ],
      ),
    );
  }

  Widget _buildRegistryStatus(List<CrozeModel> entries) {
    final topMaker = () {
      final counts = <String, int>{};
      for (var e in entries) {
        if (e.manufacturer.trim().isNotEmpty) {
          counts[e.manufacturer] = (counts[e.manufacturer] ?? 0) + 1;
        }
      }      return counts.isEmpty ? 'N/A' : counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    }();

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: kPrimaryText,
        borderRadius: BorderRadius.circular(kRadiusLarge),
        boxShadow: const [kShadowFloat],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('REGISTRY.STATUS', style: GoogleFonts.firaCode(color: Colors.white.withAlpha(120), fontSize: 9.sp, letterSpacing: 2.0)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(kRadiusSubtle)),
                child: Text('LIVE', style: GoogleFonts.firaCode(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${entries.length}'.padLeft(2, '0'), style: GoogleFonts.archivo(color: Colors.white, fontSize: 56.sp, fontWeight: FontWeight.w900, height: 1.0)),
              SizedBox(width: 12.w),
              Text('INDEXED ARTIFACTS', style: GoogleFonts.firaCode(color: Colors.white.withAlpha(160), fontSize: 12.sp, fontWeight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 24.h),
          Divider(color: Colors.white.withAlpha(30), height: 1),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(child: _metricRow('DOMINANT SOURCE', topMaker)),
              Container(width: 1, height: 32.h, color: Colors.white.withAlpha(30)),
              SizedBox(width: 20.w),
              Expanded(child: _metricRow('ACTIVE ERA', entries.last.presumedEra.toUpperCase())),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.firaCode(color: Colors.white.withAlpha(100), fontSize: 8.sp, fontWeight: FontWeight.w600, letterSpacing: 1.0)),
        SizedBox(height: 4.h),
        Text(value, style: GoogleFonts.archivo(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Text(title, style: GoogleFonts.firaCode(color: kSecondaryText, fontSize: 9.sp, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
    );
  }

  Widget _buildBlueprintTimeline(List<CrozeModel> entries) {
    final Map<String, int> eraCounts = {};
    for (var e in entries) {
      final d = _decadeFromEra(e.presumedEra);
      if (d != null) eraCounts[d] = (eraCounts[d] ?? 0) + 1;
    }
    if (eraCounts.isEmpty) return const SizedBox.shrink();
    final maxCount = eraCounts.values.reduce(math.max);

    return Container(
      height: 200.h,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusMedium),
        border: Border.all(color: kAccent, width: 1.5),
      ),
      child: Stack(
        children: [
          // Background Tech Grid
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(7, (i) => VerticalDivider(color: kOutline.withAlpha(30), width: 1))),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _eras.map((era) {
              final count = eraCounts[era] ?? 0;
              final h = (count / maxCount) * 100.h;
              final idx = _eras.indexOf(era);
              final isSel = _selectedDecadeIndex == idx;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedDecadeIndex = (isSel ? null : idx));
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (count > 0) Text('$count', style: GoogleFonts.firaCode(color: isSel ? kAccent : kSecondaryText, fontSize: 10.sp, fontWeight: FontWeight.w700)),
                    SizedBox(height: 8.h),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 24.w,
                      height: h + 2.h,
                      decoration: BoxDecoration(
                        color: isSel ? kAccent : kOutline.withAlpha(120),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: isSel ? [BoxShadow(color: kAccent.withAlpha(60), blurRadius: 10)] : null,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(era, style: GoogleFonts.firaCode(color: isSel ? kAccent : kSecondaryText, fontSize: 8.sp, fontWeight: isSel ? FontWeight.w800 : FontWeight.w500)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBarrelTypeMetrics(List<CrozeModel> entries) {
    final counts = _getCounts<BarrelType>(entries, (e) => e.barrelType);
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = counts.values.isEmpty ? 1 : counts.values.reduce(math.max);

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusMedium),
        border: Border.all(color: kAccent, width: 1.5),
      ),
      child: Column(
        children: sorted.map((e) {
          final barColor = getBarrelTypeColor(e.key);
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key.label.toUpperCase(), style: GoogleFonts.archivo(color: kPrimaryText, fontSize: 11.sp, fontWeight: FontWeight.w800)),
                    Text('${e.value}', style: GoogleFonts.firaCode(color: barColor, fontSize: 12.sp, fontWeight: FontWeight.w800)),
                  ],
                ),
                SizedBox(height: 8.h),
                Stack(
                  children: [
                    Container(height: 4.h, decoration: BoxDecoration(color: kBackground, borderRadius: BorderRadius.circular(2))),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      width: 1.sw * 0.75 * (e.value / maxVal),
                      height: 4.h,
                      decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(2), boxShadow: [BoxShadow(color: barColor.withAlpha(80), blurRadius: 6)]),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGaugeNode<T>({
    required String title,
    required Map<T, int> counts,
    required int total,
    required Color Function(T) colorFn,
    required String Function(T) labelFn,
  }) {
    final entries = counts.entries.where((e) => e.value > 0).toList();
    
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusMedium),
        border: Border.all(color: kAccent, width: 1.5),
      ),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.firaCode(color: kSecondaryText, fontSize: 9.sp, fontWeight: FontWeight.w800)),
          SizedBox(height: 20.h),
          SizedBox(
            height: 100.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(100.w, 100.w),
                  painter: _GaugePainter(
                    counts: counts,
                    total: total,
                    colorFn: (dynamic k) => colorFn(k as T),
                  ),
                ),
                Text('$total', style: GoogleFonts.archivo(color: kPrimaryText, fontSize: 20.sp, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Column(
            children: entries.take(3).map((e) => Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                children: [
                  Container(width: 6.w, height: 6.w, decoration: BoxDecoration(color: colorFn(e.key), shape: BoxShape.circle)),
                  SizedBox(width: 8.w),
                  Expanded(child: Text(labelFn(e.key).toUpperCase(), style: GoogleFonts.dmSans(color: kSecondaryText, fontSize: 9.sp, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final Map<dynamic, int> counts;
  final int total;
  final Color Function(dynamic) colorFn;
  _GaugePainter({required this.counts, required this.total, required this.colorFn});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    final bgPaint = Paint()..color = kBackground..style = PaintingStyle.stroke..strokeWidth = 10..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0.75 * math.pi, 1.5 * math.pi, false, bgPaint);

    double startAngle = 0.75 * math.pi;
    final sweepTotal = 1.5 * math.pi;

    counts.forEach((key, val) {
      final sweep = (val / (total == 0 ? 1 : total)) * sweepTotal;
      final paint = Paint()..color = colorFn(key)..style = PaintingStyle.stroke..strokeWidth = 10..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
