import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_foresters_cruising_kit/common/photo_bottom_sheet.dart';
import 'package:the_foresters_cruising_kit/enum/my_enums.dart';
import 'package:the_foresters_cruising_kit/providers/image_provider.dart';
import 'package:the_foresters_cruising_kit/providers/input_provider.dart';
import 'package:the_foresters_cruising_kit/providers/project_provider.dart';
import 'package:the_foresters_cruising_kit/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class AddScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final int currentIndex;
  const AddScreen({super.key, this.isEdit = false, this.currentIndex = 0});

  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddScreen> {
  late PageController _pageCtrl;
  int _currentPage = 0;

  late TextEditingController _idCtrl;
  late TextEditingController _manCtrl;
  late TextEditingController _countryCtrl;
  late TextEditingController _eraCtrl;
  late TextEditingController _funcCtrl;
  late TextEditingController _dimCtrl;
  late TextEditingController _accCtrl;
  late TextEditingController _stampsCtrl;
  late TextEditingController _provCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _tagsCtrl;

  static const _pageTitles = ['Identity', 'Classification', 'Physical', 'Provenance'];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    final p = ref.read(inputProvider);
    _idCtrl = TextEditingController(text: p.cruiserIdentifier);
    _manCtrl = TextEditingController(text: p.manufacturer);
    _countryCtrl = TextEditingController(text: p.countryOfOrigin);
    _eraCtrl = TextEditingController(text: p.eraOfProduction);
    _funcCtrl = TextEditingController(text: p.specificFunction);
    _dimCtrl = TextEditingController(text: p.dimensionsAndWeight);
    _accCtrl = TextEditingController(text: p.includedAccessories);
    _stampsCtrl = TextEditingController(text: p.markingsAndStamps);
    _provCtrl = TextEditingController(text: p.provenance);
    _notesCtrl = TextEditingController(text: p.notes);
    _tagsCtrl = TextEditingController(text: p.tags.join(', '));
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    for (final c in [
      _idCtrl, _manCtrl, _countryCtrl, _eraCtrl, _funcCtrl,
      _dimCtrl, _accCtrl, _stampsCtrl, _provCtrl, _notesCtrl, _tagsCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  void _save() async {
    final p = ref.read(inputProvider);
    if (p.cruiserIdentifier.trim().isEmpty || p.manufacturer.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Cruiser ID and Manufacturer are required.',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500)),
        backgroundColor: kError,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusSubtle)),
      ));
      return;
    }
    showDialog(context: context, barrierDismissible: false, builder: (_) => const _SavingDialog());
    await Future.delayed(const Duration(milliseconds: 900));
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
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        leadingWidth: 68.w,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 20.w),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40.r, height: 40.r,
                decoration: BoxDecoration(
                  color: kPanelBg,
                  borderRadius: BorderRadius.circular(kRadiusSubtle),
                  border: Border.all(color: kOutline, width: 1),
                ),
                child: Icon(Icons.close, color: kPrimaryText, size: 20.sp),
              ),
            ),
          ),
        ),
        title: Text(
          widget.isEdit ? 'Edit Instrument' : 'Record Instrument',
          style: GoogleFonts.sora(fontSize: 16.sp, fontWeight: FontWeight.w600, color: kPrimaryText),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _buildStepperBar(),
                SizedBox(height: 8.h),
                Expanded(
                  child: PageView(
                    controller: _pageCtrl,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildPage1Identity(),
                      _buildPage2Classification(),
                      _buildPage3Physical(),
                      _buildPage4Provenance(),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomNav()),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
      child: Row(
        children: List.generate(_pageTitles.length, (i) {
          final isActive = i == _currentPage;
          final isDone = i < _currentPage;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < _pageTitles.length - 1 ? 6.w : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 3.h,
                    decoration: BoxDecoration(
                      color: isActive ? kAccent : isDone ? kAccent.withAlpha(60) : kOutline,
                      borderRadius: BorderRadius.circular(kRadiusPill),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _pageTitles[i],
                    style: GoogleFonts.inter(
                      color: isActive ? kAccent : isDone ? kSecondaryText : kOutline,
                      fontSize: 10.sp,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPage1Identity() {
    final p = ref.watch(inputProvider);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 120.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPhotoSection(),
          SizedBox(height: 20.h),
          _sectionHeader('01 — IDENTIFICATION', Icons.fingerprint),
          SizedBox(height: 16.h),
          _field(label: 'CRUISER IDENTIFIER *', ctrl: _idCtrl,
              hint: 'e.g. TFCK-KEUFFEL-1940-OREGON-047',
              onChanged: (v) => p.cruiserIdentifier = v),
          SizedBox(height: 14.h),
          _field(label: 'MANUFACTURER *', ctrl: _manCtrl,
              hint: 'e.g. Keuffel & Esser, Suunto, Lufkin',
              onChanged: (v) => p.manufacturer = v),
          SizedBox(height: 14.h),
          _field(label: 'COUNTRY OF ORIGIN', ctrl: _countryCtrl,
              hint: 'e.g. USA, Sweden, Finland, Germany',
              onChanged: (v) => p.countryOfOrigin = v),
          SizedBox(height: 20.h),
          _subLabel('TOOL TYPE'),
          SizedBox(height: 8.h),
          _enumChips<ToolType>(
            values: ToolType.values,
            current: p.toolType,
            onSelected: (t) => ref.read(inputProvider).toolType = t,
            label: (t) => t.label,
            color: (t) => getToolTypeColor(t),
          ),
        ],
      ),
    );
  }

  Widget _buildPage2Classification() {
    final p = ref.watch(inputProvider);
    final eras = ['1880s','1900s','1920s','1940s','1960s','1980s'];
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 120.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('02 — CLASSIFICATION', Icons.category_outlined),
          SizedBox(height: 16.h),
          _subLabel('SCALE SYSTEM'),
          SizedBox(height: 8.h),
          _enumChips<ScaleSystem>(
            values: ScaleSystem.values,
            current: p.scaleSystem,
            onSelected: (s) => ref.read(inputProvider).scaleSystem = s,
            label: (s) => s.label,
            color: (s) => getScaleSystemColor(s),
          ),
          SizedBox(height: 20.h),
          _subLabel('ERA OF PRODUCTION'),
          SizedBox(height: 8.h),
          _enumChips<String>(
            values: eras,
            current: p.eraOfProduction,
            onSelected: (v) { _eraCtrl.text = v; ref.read(inputProvider).eraOfProduction = v; },
            label: (v) => v,
            color: (_) => kGold,
          ),
          SizedBox(height: 10.h),
          _field(label: 'CUSTOM ERA', ctrl: _eraCtrl, hint: 'e.g. 1937',
              onChanged: (v) => ref.read(inputProvider).eraOfProduction = v),
          SizedBox(height: 20.h),
          _subLabel('OPERATING PRINCIPLE'),
          SizedBox(height: 8.h),
          ...OperatingPrinciple.values.map((op) {
            final isSel = p.operatingPrinciple == op;
            return GestureDetector(
              onTap: () => ref.read(inputProvider).operatingPrinciple = op,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: isSel ? kAccentSurface : kPanelBg,
                  borderRadius: BorderRadius.circular(kRadiusSubtle),
                  border: Border.all(color: isSel ? kAccent : kOutline, width: isSel ? 1.5 : 1),
                ),
                child: Row(
                  children: [
                    Icon(isSel ? Icons.check_circle_rounded : Icons.radio_button_off,
                        color: isSel ? kAccent : kSecondaryText.withAlpha(100), size: 20.sp),
                    SizedBox(width: 12.w),
                    Text(op.label,
                        style: GoogleFonts.inter(
                          color: isSel ? kPrimaryText : kSecondaryText,
                          fontSize: 14.sp,
                          fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                        )),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: 20.h),
          _subLabel('PRIMARY MATERIAL'),
          SizedBox(height: 8.h),
          _enumChips<PrimaryMaterial>(
            values: PrimaryMaterial.values,
            current: p.primaryMaterial,
            onSelected: (m) => ref.read(inputProvider).primaryMaterial = m,
            label: (m) => m.label,
            color: (m) => getMaterialColor(m),
          ),
        ],
      ),
    );
  }

  Widget _buildPage3Physical() {
    final p = ref.watch(inputProvider);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 120.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('03 — PHYSICAL RECORD', Icons.straighten),
          SizedBox(height: 16.h),
          _field(label: 'SPECIFIC FUNCTION', ctrl: _funcCtrl,
              hint: 'e.g. Total tree height, DBH measurement, annual ring count',
              maxLines: 2, onChanged: (v) => p.specificFunction = v),
          SizedBox(height: 14.h),
          _field(label: 'DIMENSIONS & WEIGHT', ctrl: _dimCtrl,
              hint: 'e.g. 42 cm borer, 320 g; 30 m tape, canvas',
              onChanged: (v) => p.dimensionsAndWeight = v),
          SizedBox(height: 14.h),
          _field(label: 'INCLUDED ACCESSORIES', ctrl: _accCtrl,
              hint: 'e.g. Original leather scabbard, cleaning rods, sharpening stone',
              maxLines: 2, onChanged: (v) => p.includedAccessories = v),
          SizedBox(height: 20.h),
          _subLabel('CONDITION GRADE'),
          SizedBox(height: 8.h),
          ...ConditionGrade.values.map((cg) {
            final isSel = p.conditionGrade == cg;
            final color = getConditionColor(cg);
            return GestureDetector(
              onTap: () => ref.read(inputProvider).conditionGrade = cg,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSel ? color.withAlpha(18) : kPanelBg,
                  borderRadius: BorderRadius.circular(kRadiusSubtle),
                  border: Border.all(color: isSel ? color.withAlpha(120) : kOutline, width: isSel ? 1.5 : 1),
                ),
                child: Row(
                  children: [
                    Container(width: 8.w, height: 8.w,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    SizedBox(width: 12.w),
                    Text(cg.label,
                        style: GoogleFonts.inter(
                          color: isSel ? kPrimaryText : kSecondaryText,
                          fontSize: 14.sp,
                          fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                        )),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: 20.h),
          _subLabel('TIMBER REGION'),
          SizedBox(height: 8.h),
          _enumChips<TimberRegion>(
            values: TimberRegion.values,
            current: p.timberRegion,
            onSelected: (r) => ref.read(inputProvider).timberRegion = r,
            label: (r) => r.label,
            color: (_) => kAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildPage4Provenance() {
    final p = ref.watch(inputProvider);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 120.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('04 — ARCHIVAL RECORD', Icons.history_edu),
          SizedBox(height: 16.h),
          _field(label: 'MARKINGS & STAMPS', ctrl: _stampsCtrl,
              hint: 'e.g. U.S.F.S. stamp, lumber co. initials, patent date',
              maxLines: 2, onChanged: (v) => p.markingsAndStamps = v),
          SizedBox(height: 14.h),
          _field(label: 'PROVENANCE / SOURCE', ctrl: _provCtrl,
              hint: 'e.g. Abandoned ranger station, Pacific NW coastal shop',
              maxLines: 2, onChanged: (v) => p.provenance = v),
          SizedBox(height: 14.h),
          _field(label: 'FIELD NOTES', ctrl: _notesCtrl,
              hint: 'e.g. Scale still legible; original blade intact…',
              maxLines: 3, onChanged: (v) => p.notes = v),
          SizedBox(height: 14.h),
          _field(label: 'TAGS (comma separated)', ctrl: _tagsCtrl,
              hint: 'brass, keuffel, oregon, rare…',
              onChanged: (v) => p.tags = v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    final imgPath = ref.watch(imageProvider).getImagePath(ref.watch(imageProvider).resultImage);
    return GestureDetector(
      onTap: () => photoBottomSheet(context, ref.read(imageProvider), 0, ref),
      child: Container(
        width: double.infinity, height: 220.h,
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusMedium),
          border: Border.all(color: kOutline, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: imgPath != null && File(imgPath).existsSync()
            ? Stack(fit: StackFit.expand, children: [
                Image.file(File(imgPath), fit: BoxFit.cover),
                Positioned(top: 12.h, right: 12.w,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(Icons.edit, size: 14.sp, color: kPrimaryText),
                  )),
              ])
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.add_a_photo_outlined, color: kSecondaryText, size: 28.sp),
                SizedBox(height: 10.h),
                Text('Upload instrument photograph',
                    style: GoogleFonts.inter(color: kSecondaryText, fontSize: 13.sp)),
                SizedBox(height: 4.h),
                Text('Scale face, markings, and manufacturer text',
                    style: GoogleFonts.inter(color: kSecondaryText.withAlpha(120), fontSize: 11.sp)),
              ]),
      ),
    );
  }

  Widget _buildBottomNav() {
    final isLastPage = _currentPage == _pageTitles.length - 1;
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
      decoration: BoxDecoration(
        color: kBackground.withAlpha(230),
        border: Border(top: BorderSide(color: kOutline.withAlpha(80))),
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            GestureDetector(
              onTap: () => _pageCtrl.previousPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic),
              child: Container(
                height: 52.h, width: 52.h,
                margin: EdgeInsets.only(right: 12.w),
                decoration: BoxDecoration(
                  color: kPanelBg,
                  borderRadius: BorderRadius.circular(kRadiusSubtle),
                  border: Border.all(color: kOutline, width: 1),
                ),
                child: Icon(Icons.arrow_back_rounded, color: kPrimaryText, size: 22.sp),
              ),
            ),
          Expanded(
            child: GestureDetector(
              onTap: isLastPage ? _save
                  : () => _pageCtrl.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic),
              child: Container(
                height: 52.h,
                decoration: BoxDecoration(
                  color: isLastPage ? kAccent : kPrimaryText,
                  borderRadius: BorderRadius.circular(kRadiusSubtle),
                  boxShadow: isLastPage ? const [kShadowGreen] : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  isLastPage ? (widget.isEdit ? 'Update Archive Record' : 'Commit to Archive') : 'Continue',
                  style: GoogleFonts.sora(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: kAccent),
        SizedBox(width: 8.w),
        Text(title,
            style: GoogleFonts.jetBrainsMono(
                color: kPrimaryText, fontSize: 11.sp, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _subLabel(String label) {
    return Text(label,
        style: GoogleFonts.jetBrainsMono(
            color: kSecondaryText, fontSize: 9.sp, fontWeight: FontWeight.w600, letterSpacing: 1.2));
  }

  Widget _field({
    required String label,
    required TextEditingController ctrl,
    required Function(String) onChanged,
    String? hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _subLabel(label),
        SizedBox(height: 6.h),
        TextField(
          controller: ctrl,
          onChanged: onChanged,
          maxLines: maxLines,
          style: GoogleFonts.inter(color: kPrimaryText, fontSize: 14.sp, fontWeight: FontWeight.w400),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _enumChips<T>({
    required List<T> values,
    required T current,
    required void Function(T) onSelected,
    required String Function(T) label,
    required Color Function(T) color,
  }) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: values.map((v) {
        final isSel = v == current;
        final c = color(v);
        return GestureDetector(
          onTap: () => onSelected(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSel ? c : kPanelBg,
              borderRadius: BorderRadius.circular(kRadiusPill),
              border: Border.all(color: isSel ? c : kOutline, width: 1),
              boxShadow: isSel ? [BoxShadow(color: c.withAlpha(60), blurRadius: 8, offset: const Offset(0, 2))] : null,
            ),
            child: Text(
              label(v),
              style: GoogleFonts.inter(
                color: isSel ? Colors.white : kSecondaryText,
                fontSize: 12.sp,
                fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
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
        padding: EdgeInsets.all(36.w),
        decoration: BoxDecoration(color: kPanelBg, borderRadius: BorderRadius.circular(kRadiusMedium)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(color: kAccent, strokeWidth: 2.5),
          SizedBox(height: 20.h),
          Text('ARCHIVING…',
              style: GoogleFonts.jetBrainsMono(color: kPrimaryText, fontSize: 12.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 4.h),
          Text('Indexing field record',
              style: GoogleFonts.inter(color: kSecondaryText, fontSize: 13.sp)),
        ]),
      ),
    );
  }
}
