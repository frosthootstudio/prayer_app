import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/prayer_model.dart';
import '../services/prayer_calculation_service.dart';
import '../services/share_service.dart';
import '../utils/app_theme.dart';
import 'share_card.dart';

class ShareBottomSheet extends StatefulWidget {
  final List<PrayerInfo> prayers;
  final String cityName;
  final String gregorianDate;
  final String hijriDate;
  final DateTime? imsakTime;
  final AppLanguage language;

  const ShareBottomSheet({
    super.key,
    required this.prayers,
    required this.cityName,
    required this.gregorianDate,
    required this.hijriDate,
    this.imsakTime,
    this.language = AppLanguage.id,
  });

  @override
  State<ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet> {
  bool _sharing = false;
  bool _saving  = false;

  static String _t(AppLanguage l,
      {required String ar, required String en, required String id}) =>
      l == AppLanguage.ar ? ar : l == AppLanguage.en ? en : id;

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      await ShareService.shareScheduleImage(
        context:       context,
        prayers:       widget.prayers,
        cityName:      widget.cityName,
        gregorianDate: widget.gregorianDate,
        hijriDate:     widget.hijriDate,
        imsakTime:     widget.imsakTime,
        language:      widget.language,
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _saveToGallery() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final ok = await ShareService.saveToGallery(
        context:       context,
        prayers:       widget.prayers,
        cityName:      widget.cityName,
        gregorianDate: widget.gregorianDate,
        hijriDate:     widget.hijriDate,
        imsakTime:     widget.imsakTime,
        language:      widget.language,
      );
      if (mounted) {
        final msg = ok
            ? _t(widget.language,
                ar: 'تم الحفظ في المعرض ✓',
                en: 'Saved to gallery ✓',
                id: 'Tersimpan di galeri ✓')
            : _t(widget.language,
                ar: 'فشل الحفظ',
                en: 'Could not save',
                id: 'Gagal menyimpan');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _copyText() {
    final text = ShareService.buildCopyText(
      prayers:       widget.prayers,
      cityName:      widget.cityName,
      gregorianDate: widget.gregorianDate,
      hijriDate:     widget.hijriDate,
      imsakTime:     widget.imsakTime,
      language:      widget.language,
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_t(widget.language,
          ar: 'تم نسخ الجدول ✓',
          en: 'Schedule copied ✓',
          id: 'Jadwal disalin ✓',
        )),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appCardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.appDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            _t(widget.language,
              ar: 'مشاركة مواقيت الصلاة',
              en: 'Share Prayer Schedule',
              id: 'Bagikan Jadwal Shalat',
            ),
            style: GoogleFonts.poppins(
              color: context.appTextPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          // Preview (scaled down)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.contain,
                child: ShareCard(
                  prayers:       widget.prayers,
                  cityName:      widget.cityName,
                  gregorianDate: widget.gregorianDate,
                  hijriDate:     widget.hijriDate,
                  imsakTime:     widget.imsakTime,
                  language:      widget.language,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _ActionButton(
                  icon: Icons.share_rounded,
                  label: _t(widget.language,
                    ar: 'شارك',
                    en: 'Share',
                    id: 'Bagikan',
                  ),
                  loading: _sharing,
                  primary: true,
                  onTap: _share,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _ActionButton(
                  icon: Icons.download_rounded,
                  label: _t(widget.language,
                    ar: 'احفظ',
                    en: 'Save',
                    id: 'Simpan',
                  ),
                  loading: _saving,
                  primary: false,
                  onTap: _saveToGallery,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _ActionButton(
                  icon: Icons.copy_rounded,
                  label: _t(widget.language,
                    ar: 'نسخ',
                    en: 'Copy',
                    id: 'Salin',
                  ),
                  loading: false,
                  primary: false,
                  onTap: _copyText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool loading;
  final bool primary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.loading,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = primary ? context.appAccent : context.appCardBg;
    final fg = primary ? Colors.white : context.appTextPrimary;
    final border = primary ? null : Border.all(color: context.appDivider);

    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: border,
        ),
        child: loading
            ? Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: fg,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 16, color: fg),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: fg,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
