import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:coopering_croze_barrel/enum/my_enums.dart';
import 'package:coopering_croze_barrel/models/project_model.dart';
import 'package:coopering_croze_barrel/providers/image_provider.dart';
import 'package:coopering_croze_barrel/providers/project_provider.dart';
import 'package:coopering_croze_barrel/providers/search_provider.dart';
import 'package:coopering_croze_barrel/providers/input_provider.dart';
import 'package:coopering_croze_barrel/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  BarrelType? _selectedBarrelFilter;
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

    final filteredByBarrel = _selectedBarrelFilter == null
        ? allEntries
        : allEntries
            .where((e) => e.barrelType == _selectedBarrelFilter)
            .toList();
    final entries = searchProv.filteredList(filteredByBarrel);

    return Scaffold(
      backgroundColor: kBackground,
      extendBodyBehindAppBar: true,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 90.h),
        child: FloatingActionButton.extended(
          onPressed: () {
            ref.read(inputProvider).clearAll();
            ref.read(imageProvider).clearImage();
            Navigator.pushNamed(context, '/add_screen');
          },
          backgroundColor: kAccent,
          elevation: 0,
          highlightElevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kRadiusPill)),
          icon: Icon(Icons.add, color: Colors.white, size: 20.sp),
          label: Text(
            'New Entry',
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          _buildGlassAppBar(allEntries.length),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 12.h),
                  _buildSearchBar(),
                  SizedBox(height: 16.h),
                  _buildBarrelFilterChips(),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
          entries.isEmpty
              ? SliverToBoxAdapter(
                  child: _buildEmptyState(),
                )
              : SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 140.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = entries[index];
                        final mainIndex =
                            ref.read(projectProvider).entries.indexOf(entry);
                        return _buildModernToolCard(context, entry, mainIndex);
                      },
                      childCount: entries.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildGlassAppBar(int count) {
    return SliverAppBar(
      expandedHeight: 150.h,
      stretch: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.blurBackground,
          StretchMode.zoomBackground
        ],
        background: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: kBackground.withAlpha(200),
            ),
          ),
        ),
        titlePadding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 16.h),
        centerTitle: false,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'SYSTEM // ARCHIVE.REGISTRY',
                style: GoogleFonts.firaCode(
                  color: kAccent,
                  fontSize: 7.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'CATALOGUE',
                    style: GoogleFonts.archivo(
                      color: kPrimaryText,
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: kPrimaryText,
                      borderRadius: BorderRadius.circular(kRadiusSubtle),
                    ),
                    child: Text(
                      count.toString().padLeft(2, '0'),
                      style: GoogleFonts.firaCode(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
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
      duration: const Duration(milliseconds: 250),
      height: 54.h,
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusStandard),
        boxShadow: const [kShadowSubtle],
      ),
      child: Row(
        children: [
          SizedBox(width: 16.w),
          Icon(
            Icons.search,
            color: isFocused ? kAccent : kSecondaryText,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (v) =>
                  ref.read(searchProvider.notifier).setSearchQuery(v),
              style: GoogleFonts.dmSans(
                color: kPrimaryText,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search makers, origins...',
                hintStyle: GoogleFonts.dmSans(
                  color: kSecondaryText.withAlpha(150),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
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
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Icon(Icons.close, color: kSecondaryText, size: 18.sp),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBarrelFilterChips() {
    return SizedBox(
      height: 38.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        children: [
          _buildChip('All', null),
          ...BarrelType.values.map((t) => _buildChip(t.label, t)),
        ],
      ),
    );
  }

  Widget _buildChip(String label, BarrelType? type) {
    final isSelected = _selectedBarrelFilter == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedBarrelFilter = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: EdgeInsets.only(right: 10.w),
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryText : kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusPill),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: kPrimaryText.withAlpha(50),
                      blurRadius: 16,
                      offset: const Offset(0, 4))
                ]
              : const [kShadowSubtle],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            color: isSelected ? Colors.white : kSecondaryText,
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildModernToolCard(
      BuildContext context, CrozeModel entry, int index) {
    final imageProv = ref.watch(imageProvider);
    final imagePath = imageProv.getImagePath(entry.photoPath);
    final matColor = getMaterialColor(entry.manufacturingMaterial);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/info_screen',
        arguments: {'index': index},
      ),
      child: Container(
        height: 260.h,
        margin: EdgeInsets.only(bottom: 24.h),
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusStandard),
          boxShadow: const [kShadowFloat],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image Layer
            (entry.photoPath.isNotEmpty &&
                    imagePath != null &&
                    File(imagePath).existsSync())
                ? Image.file(File(imagePath), fit: BoxFit.cover)
                : Container(
                    color: kBackground,
                    child: Icon(Icons.hardware_outlined,
                        color: kOutline, size: 64.sp),
                  ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withAlpha(220)],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),

            // Material Tag
            Positioned(
              top: 16.h,
              right: 16.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(kRadiusPill),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    color: matColor.withAlpha(220),
                    child: Text(
                      entry.manufacturingMaterial.label,
                      style: GoogleFonts.firaCode(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Content
            Positioned(
              bottom: 20.h,
              left: 20.w,
              right: 20.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.cooperageIdentifier.isNotEmpty
                        ? entry.cooperageIdentifier
                        : 'NO-ID',
                    style: GoogleFonts.firaCode(
                      color: kAccentLight,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    entry.manufacturer.isNotEmpty
                        ? entry.manufacturer
                        : 'Unknown Maker',
                    style: GoogleFonts.archivo(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(kRadiusSubtle),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 6.h),
                            color: Colors.white.withAlpha(30),
                            child: Text(
                              entry.crozeType.label,
                              style: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (entry.presumedEra.isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(kRadiusSubtle),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 6.h),
                              color: Colors.white.withAlpha(30),
                              child: Text(
                                entry.presumedEra,
                                style: GoogleFonts.firaCode(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 48.h, horizontal: 24.w),
            decoration: BoxDecoration(
              color: kPanelBg,
              borderRadius: BorderRadius.circular(kRadiusStandard),
              boxShadow: const [kShadowSubtle],
            ),
            child: Column(
              children: [
                Icon(Icons.collections_bookmark_outlined,
                    size: 48.sp, color: kSecondaryText.withAlpha(100)),
                SizedBox(height: 16.h),
                Text(
                  'No Tools in Archive',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.archivo(
                    color: kPrimaryText,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Your collection is currently empty. Tap the entry button below to begin logging.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    color: kSecondaryText,
                    fontSize: 14.sp,
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
