import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_foresters_cruising_kit/enum/my_enums.dart';
import 'package:the_foresters_cruising_kit/models/project_model.dart';
import 'package:the_foresters_cruising_kit/providers/image_provider.dart';
import 'package:the_foresters_cruising_kit/providers/project_provider.dart';
import 'package:the_foresters_cruising_kit/providers/search_provider.dart';
import 'package:the_foresters_cruising_kit/providers/input_provider.dart';
import 'package:the_foresters_cruising_kit/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ScaleSystem? _selectedScaleFilter;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProv = ref.watch(searchProvider);
    final projectProv = ref.watch(projectProvider);
    final allEntries = projectProv.entries;

    final filteredByScale = _selectedScaleFilter == null
        ? allEntries
        : allEntries.where((e) => e.scaleSystem == _selectedScaleFilter).toList();
    final entries = searchProv.filteredList(filteredByScale);

    return Scaffold(
      backgroundColor: kBackground,
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          _buildAppBar(allEntries.length),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 12.h),
                  _buildSearchBar(),
                  SizedBox(height: 14.h),
                  _buildScaleFilterChips(),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
          entries.isEmpty
              ? SliverToBoxAdapter(child: _buildEmptyState())
              : SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 140.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = entries[index];
                        final mainIndex = ref
                            .read(projectProvider)
                            .entries
                            .indexWhere((e) => e.id == entry.id);
                        return _buildInstrumentCard(context, entry, mainIndex);
                      },
                      childCount: entries.length,
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 90.h),
        child: GestureDetector(
          onTap: () {
            ref.read(inputProvider).clearAll();
            ref.read(imageProvider).clearImage();
            Navigator.pushNamed(context, '/add_screen');
          },
          child: Container(
            height: 52.h,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              color: kAccent,
              borderRadius: BorderRadius.circular(kRadiusPill),
              boxShadow: const [kShadowGreen],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Log Instrument',
                  style: GoogleFonts.sora(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(int count) {
    return SliverAppBar(
      expandedHeight: 160.h,
      stretch: true,
      pinned: true,
      backgroundColor: kBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.fadeTitle],
        background: Container(color: kBackground),
        titlePadding: EdgeInsets.only(left: 20.w, bottom: 16.h),
        centerTitle: false,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CRUISING KIT // FIELD ARCHIVE',
                style: GoogleFonts.jetBrainsMono(
                  color: kAccent,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'The Kit',
                    style: GoogleFonts.sora(
                      color: kPrimaryText,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: kPrimaryText,
                      borderRadius: BorderRadius.circular(kRadiusSubtle),
                    ),
                    child: Text(
                      count.toString().padLeft(2, '0'),
                      style: GoogleFonts.jetBrainsMono(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final isFocused = _searchFocusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 50.h,
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(
          color: isFocused ? kAccent : kOutline,
          width: isFocused ? 1.5 : 1.0,
        ),
        boxShadow: const [kShadowSubtle],
      ),
      child: Row(
        children: [
          SizedBox(width: 14.w),
          Icon(
            Icons.search,
            color: isFocused ? kAccent : kSecondaryText,
            size: 18.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (v) =>
                  ref.read(searchProvider.notifier).setSearchQuery(v),
              style: GoogleFonts.inter(
                color: kPrimaryText,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: 'Search makers, scale systems, regions…',
                hintStyle: GoogleFonts.inter(
                  color: kSecondaryText.withAlpha(120),
                  fontSize: 14.sp,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                ref.read(searchProvider.notifier).clearSearchQuery();
                setState(() {});
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child:
                    Icon(Icons.close, color: kSecondaryText, size: 16.sp),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScaleFilterChips() {
    return SizedBox(
      height: 36.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        children: [
          _buildChip('All', null),
          ...ScaleSystem.values.map((s) => _buildChip(s.label, s)),
        ],
      ),
    );
  }

  Widget _buildChip(String label, ScaleSystem? scale) {
    final isSelected = _selectedScaleFilter == scale;
    return GestureDetector(
      onTap: () => setState(() => _selectedScaleFilter = scale),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryText : kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusPill),
          border: Border.all(
            color: isSelected ? kPrimaryText : kOutline,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            color: isSelected ? Colors.white : kSecondaryText,
            fontSize: 10.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildInstrumentCard(
    BuildContext context,
    ForestryInstrumentModel entry,
    int index,
  ) {
    final imageProv = ref.watch(imageProvider);
    final imagePath = imageProv.getImagePath(entry.photoPath);
    final isOperational = entry.conditionGrade == ConditionGrade.operational ||
        entry.conditionGrade == ConditionGrade.museumQuality;
    final ringColor = isOperational ? kAccent : kGold;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/info_screen',
        arguments: {'index': index},
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(color: kOutline, width: 1),
          boxShadow: const [kShadowSubtle],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: thumbnail or tree cross-section SVG
            ClipRRect(
              borderRadius: BorderRadius.circular(kRadiusSubtle - 2),
              child: SizedBox(
                width: 72.w,
                height: 72.w,
                child: (entry.photoPath.isNotEmpty &&
                        imagePath != null &&
                        File(imagePath).existsSync())
                    ? Image.file(File(imagePath), fit: BoxFit.cover)
                    : Container(
                        color: kBackground,
                        child: Center(
                          child: CustomPaint(
                            size: Size(48.w, 48.w),
                            painter:
                                _TreeRingMiniPainter(ringColor: ringColor),
                          ),
                        ),
                      ),
              ),
            ),
            SizedBox(width: 14.w),

            // Right: content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Identifier in mono
                  Text(
                    entry.cruiserIdentifier.isNotEmpty
                        ? entry.cruiserIdentifier
                        : 'NO-ID',
                    style: GoogleFonts.jetBrainsMono(
                      color: kAccent,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),

                  // Manufacturer (Sora — display size)
                  Text(
                    entry.manufacturer.isNotEmpty
                        ? entry.manufacturer
                        : 'Unknown Maker',
                    style: GoogleFonts.sora(
                      color: kPrimaryText,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),

                  // Tool type tag
                  Text(
                    entry.toolType.label,
                    style: GoogleFonts.inter(
                      color: kSecondaryText,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),

                  // Bottom row: scale system badge + region tag
                  Row(
                    children: [
                      // Scale system badge — gold pill in JetBrains Mono
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: kGoldSurface,
                          borderRadius: BorderRadius.circular(kRadiusPill),
                          border: Border.all(
                              color: kGold.withAlpha(80), width: 1),
                        ),
                        child: Text(
                          entry.scaleSystem.label,
                          style: GoogleFonts.jetBrainsMono(
                            color: kGold,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      // Region provenance tag — green pill
                      if (entry.timberRegion != TimberRegion.other)
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: kAccent.withAlpha(25),
                              borderRadius:
                                  BorderRadius.circular(kRadiusPill),
                            ),
                            child: Text(
                              entry.timberRegion.label,
                              style: GoogleFonts.inter(
                                color: kAccent,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Right edge: era + condition dot
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: getConditionColor(entry.conditionGrade),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(height: 32.h),
                if (entry.eraOfProduction.isNotEmpty)
                  Text(
                    entry.eraOfProduction,
                    style: GoogleFonts.jetBrainsMono(
                      color: kSecondaryText,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 52.h, horizontal: 24.w),
            decoration: BoxDecoration(
              color: kPanelBg,
              borderRadius: BorderRadius.circular(kRadiusSubtle),
              border: Border.all(color: kOutline, width: 1),
            ),
            child: Column(
              children: [
                CustomPaint(
                  size: Size(64.w, 64.w),
                  painter: _TreeRingMiniPainter(ringColor: kOutline, rings: 4),
                ),
                SizedBox(height: 20.h),
                Text(
                  'NO TOOLS IN THIS KIT YET.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jetBrainsMono(
                    color: kSecondaryText,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Tap "Log Instrument" to begin cataloging your collection of forestry measurement tools.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: kSecondaryText.withAlpha(160),
                    fontSize: 13.sp,
                    height: 1.5,
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

/// Minimal tree cross-section with concentric growth rings.
/// Green rings = operational instrument. Gold rings = display/collection piece.
class _TreeRingMiniPainter extends CustomPainter {
  final Color ringColor;
  final int rings;

  const _TreeRingMiniPainter({required this.ringColor, this.rings = 3});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = size.width / 2 * 0.9;

    final paint = Paint()
      ..color = ringColor.withAlpha(60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 1; i <= rings; i++) {
      canvas.drawCircle(
        Offset(cx, cy),
        maxR * (i / rings),
        paint,
      );
    }

    // Pith
    canvas.drawCircle(
      Offset(cx, cy),
      2.5,
      Paint()..color = ringColor.withAlpha(120),
    );

    // One medullary ray
    final rayPaint = Paint()
      ..color = ringColor.withAlpha(40)
      ..strokeWidth = 0.8;
    final angle = -math.pi / 4;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + maxR * math.cos(angle), cy + maxR * math.sin(angle)),
      rayPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TreeRingMiniPainter old) =>
      old.ringColor != ringColor || old.rings != rings;
}
