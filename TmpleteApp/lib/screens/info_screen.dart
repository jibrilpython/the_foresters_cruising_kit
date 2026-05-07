import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:coopering_croze_barrel/models/project_model.dart';
import 'package:coopering_croze_barrel/providers/image_provider.dart';
import 'package:coopering_croze_barrel/providers/project_provider.dart';
import 'package:coopering_croze_barrel/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoScreen extends ConsumerWidget {
  final int index;
  const InfoScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectProv = ref.watch(projectProvider);
    if (index < 0 || index >= projectProv.entries.length) {
      return const Scaffold(body: Center(child: Text('TOOL NOT FOUND')));
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
        leading: Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: _glassNavAction(
            context,
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
        ),
        actions: [
          _glassNavAction(
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
          SizedBox(width: 8.w),
          _glassNavAction(
            context,
            icon: Icons.delete_outline,
            iconColor: kError,
            onTap: () => _showDeleteDialog(context, projectProv, index),
          ),
          SizedBox(width: 16.w),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(child: _buildHeroArtifact(imagePath, entry)),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 32.h, 20.w, 120.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildDossierHeader(entry),
                SizedBox(height: 32.h),
                _buildPrecisionMatrix(entry),
                SizedBox(height: 32.h),
                _buildObservationPanels(entry),
                if (entry.tags.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  _buildScientificTags(entry),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroArtifact(String? imagePath, CrozeModel entry) {
    return Container(
      width: double.infinity,
      height: 420.h,
      decoration: BoxDecoration(
        color: kPanelBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 40,
            offset: const Offset(0, 20),
          )
        ],
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(kRadiusXLarge)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          (entry.photoPath.isNotEmpty &&
                  imagePath != null &&
                  File(imagePath).existsSync())
              ? Image.file(File(imagePath), fit: BoxFit.cover)
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.hardware_outlined,
                          size: 64.sp, color: kOutline),
                      SizedBox(height: 16.h),
                      Text('PHOTOGRAPH UNASSIGNED',
                          style: GoogleFonts.firaCode(
                              color: kSecondaryText,
                              fontSize: 10.sp,
                              letterSpacing: 2.0)),
                    ],
                  ),
                ),
          // Subtle Vignette
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(40),
                  Colors.transparent,
                  Colors.black.withAlpha(60),
                ],
              ),
            ),
          ),
          // Era Badge Floating
          if (entry.presumedEra.isNotEmpty)
            Positioned(
              bottom: 24.h,
              right: 24.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(kRadiusPill),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    color: Colors.white.withAlpha(200),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history, size: 14.sp, color: kPrimaryText),
                        SizedBox(width: 8.w),
                        Text(
                          entry.presumedEra,
                          style: GoogleFonts.firaCode(
                              color: kPrimaryText,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDossierHeader(CrozeModel entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'REGISTRY // ${entry.cooperageIdentifier.isNotEmpty ? entry.cooperageIdentifier : "UNKNOWN-ID"}',
                style: GoogleFonts.firaCode(
                    color: kAccent,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.w),
            _statusPill(entry),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          entry.manufacturer.isNotEmpty
              ? entry.manufacturer.toUpperCase()
              : 'UNKNOWN COOPREAGE',
          style: GoogleFonts.archivo(
            color: kPrimaryText,
            fontSize: 28.sp,
            fontWeight: FontWeight.w900,
            height: 1.0,
            letterSpacing: -1.0,
          ),
        ),
        if (entry.countryOfManufacture.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 14.sp, color: kSecondaryText),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  entry.countryOfManufacture.toUpperCase(),
                  style: GoogleFonts.dmSans(
                      color: kSecondaryText,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _statusPill(CrozeModel entry) {
    final color = getConditionColor(entry.conditionState);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Text(
        entry.conditionState.label.split('—').first.toUpperCase(),
        style: GoogleFonts.firaCode(
            color: color, fontSize: 9.sp, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildPrecisionMatrix(CrozeModel entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('GEOMETRIC & MATERIAL SPECS',
            style: GoogleFonts.firaCode(
                color: kSecondaryText,
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2)),
        SizedBox(height: 24.h),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          mainAxisSpacing: 8.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 2.8,
          children: [
            _matrixCell('TOOL TYPE', entry.crozeType.label, Icons.hardware),
            _matrixCell(
                'MATERIAL', entry.manufacturingMaterial.label, Icons.layers,
                color: getMaterialColor(entry.manufacturingMaterial)),
            _matrixCell('VESSEL', entry.barrelType.label, Icons.liquor,
                color: getBarrelTypeColor(entry.barrelType)),
            if (entry.barrelVolume.isNotEmpty)
              _matrixCell('VOLUME', entry.barrelVolume, Icons.straighten),
            if (entry.grooveWidth.isNotEmpty)
              _matrixCell('WIDTH', '${entry.grooveWidth} MM', Icons.width_full),
            if (entry.grooveDepth.isNotEmpty)
              _matrixCell('DEPTH', '${entry.grooveDepth} MM', Icons.height),
          ],
        ),
      ],
    );
  }

  Widget _matrixCell(String label, String value, IconData icon,
      {Color? color}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusStandard),
        border: Border.all(color: kOutline.withAlpha(50)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
                color: (color ?? kAccent).withAlpha(15),
                shape: BoxShape.circle),
            child: Icon(icon, size: 14.sp, color: color ?? kAccent),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: GoogleFonts.firaCode(
                        color: kSecondaryText,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w600)),
                Text(value.toUpperCase(),
                    style: GoogleFonts.archivo(
                        color: kPrimaryText,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObservationPanels(CrozeModel entry) {
    final panels = <Widget>[];
    if (entry.specialization.isNotEmpty) {
      panels.add(_observationCard(
          'FIELD SPECIALIZATION', entry.specialization, Icons.psychology));
    }
    if (entry.bladeShape.isNotEmpty) {
      panels.add(_observationCard(
          'BLADE GEOMETRY', entry.bladeShape, Icons.architecture));
    }
    if (entry.adjustments.isNotEmpty) {
      panels.add(_observationCard(
          'ADJUSTMENT MODES', entry.adjustments, Icons.settings_suggest));
    }
    if (entry.stampsAndMarkings.isNotEmpty) {
      panels.add(_observationCard(
          'STAMPS & AUTHENTICATION', entry.stampsAndMarkings, Icons.verified));
    }
    if (entry.regionalFeatures.isNotEmpty) {
      panels.add(_observationCard(
          'REGIONAL CHARACTERISTICS', entry.regionalFeatures, Icons.public));
    }
    if (entry.provenance.isNotEmpty) {
      panels.add(_observationCard(
          'PROVENANCE RECORD', entry.provenance, Icons.history_edu));
    }
    if (entry.notes.isNotEmpty) {
      panels.add(_observationCard(
          'ARCHIVAL FIELD NOTES', entry.notes, Icons.description));
    }

    return Column(children: panels);
  }

  Widget _observationCard(String label, String text, IconData icon) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusStandard),
        border: Border.all(color: kOutline.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.sp, color: kAccent),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(label,
                    style: GoogleFonts.firaCode(
                        color: kAccent,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(text,
              style: GoogleFonts.dmSans(
                  color: kPrimaryText,
                  fontSize: 14.sp,
                  height: 1.6,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildScientificTags(CrozeModel entry) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: entry.tags
          .map((tag) => Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: kBackground,
                  borderRadius: BorderRadius.circular(kRadiusSubtle),
                  border: Border.all(color: kOutline),
                ),
                child: Text('#${tag.toUpperCase()}',
                    style: GoogleFonts.firaCode(
                        color: kSecondaryText,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600)),
              ))
          .toList(),
    );
  }

  Widget _glassNavAction(BuildContext context,
      {required IconData icon,
      required VoidCallback onTap,
      Color iconColor = kPrimaryText}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kRadiusPill),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                  color: Colors.white.withAlpha(160), shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20.sp),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, ProjectNotifier projectProv, int idx) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kRadiusMedium),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: EdgeInsets.all(32.w),
              color: kPanelBg.withAlpha(230),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded, color: kError, size: 48.sp),
                  SizedBox(height: 20.h),
                  Text('PURGE RECORD?',
                      style: GoogleFonts.archivo(
                          color: kPrimaryText,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5)),
                  SizedBox(height: 12.h),
                  Text(
                    'This action will permanently delete the current croze registry from the database.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                        color: kSecondaryText, fontSize: 13.sp, height: 1.5),
                  ),
                  SizedBox(height: 32.h),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            height: 54.h,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: kBackground,
                                borderRadius:
                                    BorderRadius.circular(kRadiusPill),
                                border: Border.all(color: kOutline)),
                            child: Text('ABORT',
                                style: GoogleFonts.firaCode(
                                    color: kPrimaryText,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            projectProv.deleteEntry(idx);
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 54.h,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: kError,
                                borderRadius:
                                    BorderRadius.circular(kRadiusPill),
                                boxShadow: [
                                  BoxShadow(
                                      color: kError.withAlpha(60),
                                      blurRadius: 16)
                                ]),
                            child: Text('PURGE',
                                style: GoogleFonts.firaCode(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700)),
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
