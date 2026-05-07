import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:coopering_croze_barrel/common/photo_bottom_sheet.dart';
import 'package:coopering_croze_barrel/enum/my_enums.dart';
import 'package:coopering_croze_barrel/providers/image_provider.dart';
import 'package:coopering_croze_barrel/providers/input_provider.dart';
import 'package:coopering_croze_barrel/providers/project_provider.dart';
import 'package:coopering_croze_barrel/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class AddScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final int currentIndex;
  const AddScreen({super.key, this.isEdit = false, this.currentIndex = 0});

  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddScreen> {
  late TextEditingController _idCtrl;
  late TextEditingController _manCtrl;
  late TextEditingController _countryCtrl;
  late TextEditingController _eraCtrl;
  late TextEditingController _volumeCtrl;
  late TextEditingController _specCtrl;
  late TextEditingController _grooveWCtrl;
  late TextEditingController _grooveDCtrl;
  late TextEditingController _adjCtrl;
  late TextEditingController _bladeCtrl;
  late TextEditingController _stampsCtrl;
  late TextEditingController _regionalCtrl;
  late TextEditingController _provCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _tagsCtrl;

  @override
  void initState() {
    super.initState();
    final p = ref.read(inputProvider);
    _idCtrl = TextEditingController(text: p.cooperageIdentifier);
    _manCtrl = TextEditingController(text: p.manufacturer);
    _countryCtrl = TextEditingController(text: p.countryOfManufacture);
    _eraCtrl = TextEditingController(text: p.presumedEra);
    _volumeCtrl = TextEditingController(text: p.barrelVolume);
    _specCtrl = TextEditingController(text: p.specialization);
    _grooveWCtrl = TextEditingController(text: p.grooveWidth);
    _grooveDCtrl = TextEditingController(text: p.grooveDepth);
    _adjCtrl = TextEditingController(text: p.adjustments);
    _bladeCtrl = TextEditingController(text: p.bladeShape);
    _stampsCtrl = TextEditingController(text: p.stampsAndMarkings);
    _regionalCtrl = TextEditingController(text: p.regionalFeatures);
    _provCtrl = TextEditingController(text: p.provenance);
    _notesCtrl = TextEditingController(text: p.notes);
    _tagsCtrl = TextEditingController(text: p.tags.join(', '));
  }

  @override
  void dispose() {
    for (final c in [
      _idCtrl,
      _manCtrl,
      _countryCtrl,
      _eraCtrl,
      _volumeCtrl,
      _specCtrl,
      _grooveWCtrl,
      _grooveDCtrl,
      _adjCtrl,
      _bladeCtrl,
      _stampsCtrl,
      _regionalCtrl,
      _provCtrl,
      _notesCtrl,
      _tagsCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() async {
    final p = ref.read(inputProvider);
    final bool missingId = p.cooperageIdentifier.trim().isEmpty;
    final bool missingMan = p.manufacturer.trim().isEmpty;

    if (missingId || missingMan) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Verification failed. Primary fields missing.',
            style: GoogleFonts.firaCode(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600)),
        backgroundColor: kError,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20.w),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadiusSubtle)),
      ));
      return;
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const _SavingDialog());
    await Future.delayed(const Duration(milliseconds: 1200));

    if (widget.isEdit) {
      ref.read(projectProvider).editEntry(ref, widget.currentIndex);
    } else {
      ref.read(projectProvider).addEntry(ref);
    }

    if (mounted) {
      Navigator.pop(context);
      Navigator.pop(context);
      ref.read(inputProvider).clearAll();
      ref.read(imageProvider).clearImage();
    }
  }

  @override
  Widget build(BuildContext context) {
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
        leading: IconButton(
          icon: Icon(Icons.close, color: kPrimaryText, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEdit ? 'ARCHIVE.EDIT' : 'ARCHIVE.REGISTRY',
          style: GoogleFonts.firaCode(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: kAccent),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                  20.w,
                  MediaQuery.of(context).padding.top + kToolbarHeight + 16.h,
                  20.w,
                  40.h),
              child: Column(
                children: [
                  _buildPhotoSection(),
                  SizedBox(height: 32.h),
                  _buildSection(
                    title: '01 — IDENTIFICATION',
                    icon: Icons.fingerprint,
                    children: [
                      _premiumField(
                          label: 'COOPERAGE IDENTIFIER',
                          ctrl: _idCtrl,
                          hint: 'e.g. CCB-AMER-1887',
                          onChanged: (v) =>
                              ref.read(inputProvider).cooperageIdentifier = v),
                      SizedBox(height: 16.h),
                      _premiumField(
                          label: 'MANUFACTURER',
                          ctrl: _manCtrl,
                          hint: 'e.g. Samuel J. Wood & Co.',
                          onChanged: (v) =>
                              ref.read(inputProvider).manufacturer = v),
                      SizedBox(height: 16.h),
                      _premiumField(
                          label: 'ORIGIN REGION',
                          ctrl: _countryCtrl,
                          hint: 'e.g. Kentucky, USA',
                          onChanged: (v) =>
                              ref.read(inputProvider).countryOfManufacture = v),
                      SizedBox(height: 24.h),
                      _sectionSubtitle('CROZE CATEGORY'),
                      _segmentedEnumSelector<CrozeType>(
                        values: CrozeType.values,
                        current: ref.watch(inputProvider).crozeType,
                        onSelected: (t) =>
                            ref.read(inputProvider).crozeType = t,
                        labelBuilder: (t) => t.label,
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  _buildSection(
                    title: '02 — BARREL ARCHITECTURE',
                    icon: Icons.layers,
                    children: [
                      _sectionSubtitle('TARGET VESSEL'),
                      _segmentedEnumSelector<BarrelType>(
                        values: BarrelType.values,
                        current: ref.watch(inputProvider).barrelType,
                        onSelected: (t) =>
                            ref.read(inputProvider).barrelType = t,
                        labelBuilder: (t) => t.label,
                        accentColor: (t) => getBarrelTypeColor(t),
                      ),
                      SizedBox(height: 20.h),
                      _premiumField(
                          label: 'ESTIMATED VOLUME',
                          ctrl: _volumeCtrl,
                          hint: 'e.g. 53 Gallons',
                          onChanged: (v) =>
                              ref.read(inputProvider).barrelVolume = v),
                      SizedBox(height: 16.h),
                      _premiumField(
                          label: 'SPECIALIZATION',
                          ctrl: _specCtrl,
                          hint: 'e.g. Tightening chime grooves',
                          maxLines: 2,
                          onChanged: (v) =>
                              ref.read(inputProvider).specialization = v),
                      SizedBox(height: 24.h),
                      _sectionSubtitle('PRESUMED ERA'),
                      _eraSelector(),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  _buildSection(
                    title: '03 — GEOMETRIC SPECS',
                    icon: Icons.straighten,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: _premiumField(
                                  label: 'GROOVE WIDTH (MM)',
                                  ctrl: _grooveWCtrl,
                                  hint: '12',
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) =>
                                      ref.read(inputProvider).grooveWidth = v)),
                          SizedBox(width: 12.w),
                          Expanded(
                              child: _premiumField(
                                  label: 'GROOVE DEPTH (MM)',
                                  ctrl: _grooveDCtrl,
                                  hint: '08',
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) =>
                                      ref.read(inputProvider).grooveDepth = v)),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      _premiumField(
                          label: 'BLADE GEOMETRY',
                          ctrl: _bladeCtrl,
                          hint: 'e.g. Radiused V-Cut',
                          onChanged: (v) =>
                              ref.read(inputProvider).bladeShape = v),
                      SizedBox(height: 16.h),
                      _premiumField(
                          label: 'ADJUSTMENT MECHANISM',
                          ctrl: _adjCtrl,
                          hint: 'e.g. Brass thumb-screw',
                          maxLines: 2,
                          onChanged: (v) =>
                              ref.read(inputProvider).adjustments = v),
                      SizedBox(height: 24.h),
                      _sectionSubtitle('MATERIAL COMPOSITION'),
                      _segmentedEnumSelector<ManufacturingMaterial>(
                        values: ManufacturingMaterial.values,
                        current: ref.watch(inputProvider).manufacturingMaterial,
                        onSelected: (m) =>
                            ref.read(inputProvider).manufacturingMaterial = m,
                        labelBuilder: (m) => m.label,
                        accentColor: (m) => getMaterialColor(m),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  _buildSection(
                    title: '04 — ARCHIVAL NOTES',
                    icon: Icons.history_edu,
                    children: [
                      _sectionSubtitle('CONDITION STATE'),
                      _segmentedEnumSelector<CrozeCondition>(
                        values: CrozeCondition.values,
                        current: ref.watch(inputProvider).conditionState,
                        onSelected: (s) =>
                            ref.read(inputProvider).conditionState = s,
                        labelBuilder: (s) => s.label.split('—').first.trim(),
                        accentColor: (s) => getConditionColor(s),
                      ),
                      SizedBox(height: 20.h),
                      _premiumField(
                          label: 'STAMPS & MARKINGS',
                          ctrl: _stampsCtrl,
                          hint: 'e.g. Maker stamps...',
                          maxLines: 2,
                          onChanged: (v) =>
                              ref.read(inputProvider).stampsAndMarkings = v),
                      SizedBox(height: 16.h),
                      _premiumField(
                          label: 'PROVENANCE / SOURCE',
                          ctrl: _provCtrl,
                          hint: 'e.g. Estate sale in Maine...',
                          maxLines: 2,
                          onChanged: (v) =>
                              ref.read(inputProvider).provenance = v),
                      SizedBox(height: 16.h),
                      _premiumField(
                          label: 'ARCHIVAL OBSERVATIONS',
                          ctrl: _notesCtrl,
                          hint: 'e.g. Unusual blade pitch...',
                          maxLines: 3,
                          onChanged: (v) => ref.read(inputProvider).notes = v),
                      SizedBox(height: 16.h),
                      _premiumField(
                          label: 'SYSTEM TAGS',
                          ctrl: _tagsCtrl,
                          hint: 'cast iron, vintage, rare...',
                          onChanged: (v) => ref.read(inputProvider).tags = v
                              .split(',')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList()),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildSection(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusMedium),
        boxShadow: const [kShadowSubtle],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18.sp, color: kAccent),
              SizedBox(width: 10.w),
              Text(
                title,
                style: GoogleFonts.archivo(
                    color: kPrimaryText,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          ...children,
        ],
      ),
    );
  }

  Widget _sectionSubtitle(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Text(
        label,
        style: GoogleFonts.firaCode(
            color: kSecondaryText,
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5),
      ),
    );
  }

  Widget _premiumField({
    required String label,
    required TextEditingController ctrl,
    required Function(String) onChanged,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
              color: kSecondaryText,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: ctrl,
          onChanged: onChanged,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: GoogleFonts.dmSans(
              color: kPrimaryText,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(
                color: kSecondaryText.withAlpha(100), fontSize: 14.sp),
            filled: true,
            fillColor: kBackground.withAlpha(150),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kRadiusSubtle),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kRadiusSubtle),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kRadiusSubtle),
                borderSide: const BorderSide(color: kAccent, width: 2)),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          ),
        ),
      ],
    );
  }

  Widget _segmentedEnumSelector<T>({
    required List<T> values,
    required T current,
    required Function(T) onSelected,
    required String Function(T) labelBuilder,
    Color Function(T)? accentColor,
  }) {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: kBackground.withAlpha(150),
        borderRadius: BorderRadius.circular(kRadiusSubtle),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: values.length,
        itemBuilder: (context, i) {
          final val = values[i];
          final isSel = val == current;
          final color = accentColor != null ? accentColor(val) : kAccent;

          return GestureDetector(
            onTap: () => onSelected(val),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.all(4.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: isSel ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(kRadiusSubtle - 4),
                boxShadow: isSel
                    ? [
                        BoxShadow(
                            color: color.withAlpha(80),
                            blurRadius: 10,
                            offset: const Offset(0, 2))
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                labelBuilder(val).toUpperCase(),
                style: GoogleFonts.dmSans(
                  color: isSel ? Colors.white : kSecondaryText,
                  fontSize: 10.sp,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _eraSelector() {
    final eras = [
      '1820s',
      '1840s',
      '1860s',
      '1880s',
      '1900s',
      '1920s',
      '1940s'
    ];
    return Column(
      children: [
        _segmentedEnumSelector<String>(
          values: eras,
          current: ref.watch(inputProvider).presumedEra,
          onSelected: (v) {
            _eraCtrl.text = v;
            ref.read(inputProvider).presumedEra = v;
          },
          labelBuilder: (v) => v,
        ),
        SizedBox(height: 10.h),
        _premiumField(
            label: 'OR CUSTOM ERA',
            ctrl: _eraCtrl,
            hint: 'e.g. 1887',
            onChanged: (v) => ref.read(inputProvider).presumedEra = v),
      ],
    );
  }

  Widget _buildPhotoSection() {
    final imgPath = ref
        .watch(imageProvider)
        .getImagePath(ref.watch(imageProvider).resultImage);
    return GestureDetector(
      onTap: () => photoBottomSheet(context, ref.read(imageProvider), 0, ref),
      child: Container(
        width: double.infinity,
        height: 280.h,
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusMedium),
          boxShadow: const [kShadowFloat],
        ),
        clipBehavior: Clip.antiAlias,
        child: imgPath != null && File(imgPath).existsSync()
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(imgPath), fit: BoxFit.cover),
                  Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                        Colors.black.withAlpha(80),
                        Colors.transparent
                      ]))),
                  Positioned(
                      top: 16.h,
                      right: 16.w,
                      child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: Icon(Icons.edit,
                              size: 16.sp, color: kPrimaryText))),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                          color: kBackground,
                          shape: BoxShape.circle,
                          border: Border.all(color: kOutline, width: 1)),
                      child:
                          Icon(Icons.add_a_photo, color: kAccent, size: 32.sp)),
                  SizedBox(height: 16.h),
                  Text('UPLOAD SPECIMEN PHOTOGRAPH',
                      style: GoogleFonts.firaCode(
                          color: kPrimaryText,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0)),
                ],
              ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20.w, 12.h, 20.w, MediaQuery.of(context).padding.bottom + 20.h),
      decoration: BoxDecoration(
        color: kBackground.withAlpha(220),
        border: Border(top: BorderSide(color: kOutline.withAlpha(100))),
      ),
      child: GestureDetector(
        onTap: _save,
        child: Container(
          height: 60.h,
          decoration: BoxDecoration(
            color: kAccent,
            borderRadius: BorderRadius.circular(kRadiusPill),
            boxShadow: const [kShadowGreen],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.isEdit ? 'UPDATE ARCHIVE RECORD' : 'COMMIT TO ARCHIVE',
            style: GoogleFonts.archivo(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5),
          ),
        ),
      ),
    );
  }
}

class _SavingDialog extends StatelessWidget {
  const _SavingDialog();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(40.w),
        decoration: BoxDecoration(
            color: kPanelBg,
            borderRadius: BorderRadius.circular(kRadiusMedium),
            boxShadow: const [kShadowFloat]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: kAccent, strokeWidth: 3),
            SizedBox(height: 24.h),
            Text('PROCESSOR ACTIVE...',
                style: GoogleFonts.firaCode(
                    color: kPrimaryText,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700)),
            Text('Indexing repository entry',
                style:
                    GoogleFonts.dmSans(color: kSecondaryText, fontSize: 13.sp)),
          ],
        ),
      ),
    );
  }
}
