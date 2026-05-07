import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_foresters_cruising_kit/models/project_model.dart';
import 'package:the_foresters_cruising_kit/providers/image_provider.dart';
import 'package:the_foresters_cruising_kit/providers/project_provider.dart';
import 'package:the_foresters_cruising_kit/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoScreen extends ConsumerWidget {
  final int index;
  const InfoScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectProv = ref.watch(projectProvider);
    if (index < 0 || index >= projectProv.entries.length) {
      return const Scaffold(body: Center(child: Text('INSTRUMENT NOT FOUND')));
    }
    final entry = projectProv.entries[index];
    final imageProv = ref.watch(imageProvider);
    final imagePath = imageProv.getImagePath(entry.photoPath);

    return Scaffold(
      backgroundColor: kBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 80.w,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 20.w),
            child: _glassAction(
              context,
              icon: Icons.arrow_back,
              onTap: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Align(
            alignment: Alignment.center,
            child: _glassAction(
              context,
              icon: Icons.edit_outlined,
              onTap: () {
                projectProv.fillInput(ref, index);
                Navigator.pushNamed(
                  context,
                  '/add_screen',
                  arguments: {'isEdit': true, 'currentIndex': index},
                );
              },
            ),
          ),
          SizedBox(width: 8.w),
          Align(
            alignment: Alignment.center,
            child: _glassAction(
              context,
              icon: Icons.delete_outline,
              iconColor: kError,
              onTap: () => _showDeleteDialog(context, projectProv, index),
            ),
          ),
          SizedBox(width: 20.w),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(child: _buildHero(imagePath, entry)),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 120.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeader(entry),
                SizedBox(height: 28.h),
                _buildSpecGrid(entry),
                SizedBox(height: 28.h),
                _buildObservations(entry),
                if (entry.tags.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  _buildTags(entry),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(String? imagePath, ForestryInstrumentModel entry) {
    return Container(
      width: double.infinity,
      height: 400.h,
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(kRadiusMedium),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          (entry.photoPath.isNotEmpty &&
                  imagePath != null &&
                  File(imagePath).existsSync())
              ? Image.file(File(imagePath), fit: BoxFit.cover)
              : Container(
                  color: kBackground,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.landscape_outlined,
                          size: 56.sp,
                          color: kOutline,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'PHOTOGRAPH UNASSIGNED',
                          style: GoogleFonts.jetBrainsMono(
                            color: kSecondaryText,
                            fontSize: 10.sp,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          // Vignette
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(30),
                  Colors.transparent,
                  Colors.black.withAlpha(50),
                ],
              ),
            ),
          ),
          // Era floating badge
          if (entry.eraOfProduction.isNotEmpty)
            Positioned(
              bottom: 20.h,
              right: 20.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(kRadiusPill),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    color: Colors.white.withAlpha(210),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_outlined,
                          size: 13.sp,
                          color: kGold,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          entry.eraOfProduction,
                          style: GoogleFonts.jetBrainsMono(
                            color: kPrimaryText,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Scale system badge
          Positioned(
            bottom: 20.h,
            left: 20.w,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(kRadiusPill),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  color: kGold.withAlpha(200),
                  child: Text(
                    entry.scaleSystem.label,
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ForestryInstrumentModel entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                entry.cruiserIdentifier.isNotEmpty
                    ? entry.cruiserIdentifier
                    : 'NO-ID',
                style: GoogleFonts.jetBrainsMono(
                  color: kAccent,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.w),
            _conditionPill(entry),
          ],
        ),
        SizedBox(height: 10.h),
        Text(
          entry.manufacturer.isNotEmpty
              ? entry.manufacturer.toUpperCase()
              : 'UNKNOWN MAKER',
          style: GoogleFonts.sora(
            color: kPrimaryText,
            fontSize: 26.sp,
            fontWeight: FontWeight.w700,
            height: 1.0,
            letterSpacing: -0.5,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Text(
              entry.toolType.label,
              style: GoogleFonts.inter(
                color: kSecondaryText,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (entry.countryOfOrigin.isNotEmpty) ...[
              Text(
                '  ·  ',
                style: GoogleFonts.inter(color: kOutline, fontSize: 13.sp),
              ),
              Icon(
                Icons.location_on_outlined,
                size: 13.sp,
                color: kSecondaryText,
              ),
              SizedBox(width: 3.w),
              Flexible(
                child: Text(
                  entry.countryOfOrigin,
                  style: GoogleFonts.inter(
                    color: kSecondaryText,
                    fontSize: 13.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        if (entry.timberRegion.label.isNotEmpty) ...[
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: kAccent.withAlpha(20),
              borderRadius: BorderRadius.circular(kRadiusPill),
            ),
            child: Text(
              entry.timberRegion.label,
              style: GoogleFonts.inter(
                color: kAccent,
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _conditionPill(ForestryInstrumentModel entry) {
    final color = getConditionColor(entry.conditionGrade);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Text(
            entry.conditionGrade.label,
            style: GoogleFonts.jetBrainsMono(
              color: color,
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecGrid(ForestryInstrumentModel entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INSTRUMENT SPECIFICATIONS',
          style: GoogleFonts.jetBrainsMono(
            color: kSecondaryText,
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 16.h),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          mainAxisSpacing: 8.h,
          crossAxisSpacing: 10.w,
          childAspectRatio: 2.6,
          children: [
            _specCell(
              'TOOL TYPE',
              entry.toolType.label,
              Icons.hardware_outlined,
              getToolTypeColor(entry.toolType),
            ),
            _specCell(
              'MATERIAL',
              entry.primaryMaterial.label,
              Icons.texture,
              getMaterialColor(entry.primaryMaterial),
            ),
            _specCell(
              'SCALE SYSTEM',
              entry.scaleSystem.label,
              Icons.straighten,
              kGold,
            ),
            _specCell(
              'PRINCIPLE',
              entry.operatingPrinciple.label,
              Icons.settings_input_component_outlined,
              kAccent,
            ),
            if (entry.dimensionsAndWeight.isNotEmpty)
              _specCell(
                'DIMENSIONS',
                entry.dimensionsAndWeight,
                Icons.height,
                kSecondaryText,
              ),
            if (entry.eraOfProduction.isNotEmpty)
              _specCell(
                'ERA',
                entry.eraOfProduction,
                Icons.access_time_outlined,
                kGold,
              ),
          ],
        ),
      ],
    );
  }

  Widget _specCell(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kOutline.withAlpha(80)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 13.sp, color: color),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.jetBrainsMono(
                    color: kSecondaryText,
                    fontSize: 7.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    color: kPrimaryText,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObservations(ForestryInstrumentModel entry) {
    final panels = <Widget>[];
    void add(String lbl, String val, IconData ico) {
      if (val.isNotEmpty) panels.add(_obsCard(lbl, val, ico));
    }

    add(
      'SPECIFIC FUNCTION',
      entry.specificFunction,
      Icons.track_changes_outlined,
    );
    add(
      'INCLUDED ACCESSORIES',
      entry.includedAccessories,
      Icons.backpack_outlined,
    );
    add('MARKINGS & STAMPS', entry.markingsAndStamps, Icons.verified_outlined);
    add('PROVENANCE RECORD', entry.provenance, Icons.history_edu_outlined);
    add('FIELD NOTES', entry.notes, Icons.notes);
    return Column(children: panels);
  }

  Widget _obsCard(String label, String text, IconData icon) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kOutline.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13.sp, color: kAccent),
              SizedBox(width: 8.w),
              Text(
                label,
                style: GoogleFonts.jetBrainsMono(
                  color: kAccent,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            text,
            style: GoogleFonts.inter(
              color: kPrimaryText,
              fontSize: 14.sp,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags(ForestryInstrumentModel entry) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: entry.tags
          .map(
            (tag) => Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: kBackground,
                borderRadius: BorderRadius.circular(kRadiusSubtle),
                border: Border.all(color: kOutline),
              ),
              child: Text(
                '#${tag.toUpperCase()}',
                style: GoogleFonts.jetBrainsMono(
                  color: kSecondaryText,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _glassAction(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = kPrimaryText,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 40.r,
            height: 40.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(180),
              borderRadius: BorderRadius.circular(kRadiusSubtle),
              border: Border.all(color: kOutline.withAlpha(80), width: 1),
            ),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    ProjectNotifier projectProv,
    int idx,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kRadiusMedium),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: EdgeInsets.all(28.w),
              color: kPanelBg.withAlpha(240),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded, color: kError, size: 44.sp),
                  SizedBox(height: 16.h),
                  Text(
                    'REMOVE RECORD?',
                    style: GoogleFonts.sora(
                      color: kPrimaryText,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'This will permanently remove the instrument from the archive.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: kSecondaryText,
                      fontSize: 13.sp,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 28.h),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            height: 50.h,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: kBackground,
                              borderRadius: BorderRadius.circular(
                                kRadiusSubtle,
                              ),
                              border: Border.all(color: kOutline),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.inter(
                                color: kPrimaryText,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            projectProv.deleteEntry(idx);
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 50.h,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: kError,
                              borderRadius: BorderRadius.circular(
                                kRadiusSubtle,
                              ),
                            ),
                            child: Text(
                              'Remove',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
