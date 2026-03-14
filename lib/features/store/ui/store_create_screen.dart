import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/store_models.dart';
import '../state/store_create_controller.dart';

class StoreCreateScreen extends ConsumerStatefulWidget {
  const StoreCreateScreen({super.key});

  @override
  ConsumerState<StoreCreateScreen> createState() => _StoreCreateScreenState();
}

class _StoreCreateScreenState extends ConsumerState<StoreCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _addressShort = TextEditingController();
  final _address = TextEditingController();
  final _workFrom = TextEditingController();
  final _workTo = TextEditingController();
  final _phone = TextEditingController();
  final _phone2 = TextEditingController();
  final _phone3 = TextEditingController();
  final _description = TextEditingController();

  final _picker = ImagePicker();

  int? _cityId;
  XFile? _logo;
  XFile? _cover;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(storeCreateControllerProvider.notifier).loadMeta();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _addressShort.dispose();
    _address.dispose();
    _workFrom.dispose();
    _workTo.dispose();
    _phone.dispose();
    _phone2.dispose();
    _phone3.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (!mounted || file == null) return;
    setState(() => _logo = file);
  }

  Future<void> _pickCover() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
    );
    if (!mounted || file == null) return;
    setState(() => _cover = file);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    ref.read(storeCreateControllerProvider.notifier).clearErrors();

    if (!_formKey.currentState!.validate()) return;

    final payload = StoreCreatePayload(
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      cityId: _cityId,
      addressShort: _addressShort.text.trim(),
      address: _address.text.trim(),
      workHoursFrom: _workFrom.text.trim(),
      workHoursTo: _workTo.text.trim(),
      phone2: _phone2.text.trim(),
      phone3: _phone3.text.trim(),
      description: _description.text.trim(),
      logoPath: _logo?.path,
      coverPath: _cover?.path,
    );

    final store = await ref
        .read(storeCreateControllerProvider.notifier)
        .submit(payload);

    if (!mounted) return;

    if (store != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mağaza müraciətiniz göndərildi. Təsdiqdən sonra aktiv olacaq.',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(storeCreateControllerProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Mağaza yaradın'),
        elevation: 0,
      ),
      body: SafeArea(
        child: st.metaLoading && st.cities.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 44),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x140F172A),
                            blurRadius: 26,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.storefront, color: cs.primary),
                                const SizedBox(width: 10),
                                const Text(
                                  'Mağaza yaradın',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),

                            if ((st.error ?? '').isNotEmpty) ...[
                              const SizedBox(height: 14),
                              _ErrorBox(text: st.error!),
                            ],

                            const SizedBox(height: 16),

                            _FieldLabel('Mağazanın adı', requiredField: true),
                            _AppTextField(
                              controller: _name,
                              hint: 'Məs: Moda Geyim',
                              errorText: st.fieldErrors['name'],
                              validator: (v) {
                                if ((v ?? '').trim().isEmpty) {
                                  return 'Mağazanın adı mütləqdir';
                                }
                                if ((v ?? '').trim().length < 3) {
                                  return 'Ən azı 3 simvol yazın';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 14),

                            const _FieldLabel('Loqo və cover'),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _UploadCard(
                                    title: 'Vendor Logo',
                                    subtitle: _logo?.name ?? 'Fayl seçilməyib',
                                    previewPath: _logo?.path,
                                    placeholderTitle: 'Loqo (1:1)',
                                    placeholderSub: 'JPG/PNG/WEBP · max 2MB',
                                    isCover: false,
                                    onPick: _pickLogo,
                                    onClear: _logo == null
                                        ? null
                                        : () => setState(() => _logo = null),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _UploadCard(
                                    title: 'Vendor Cover',
                                    subtitle: _cover?.name ?? 'Fayl seçilməyib',
                                    previewPath: _cover?.path,
                                    placeholderTitle: 'Cover (3:1)',
                                    placeholderSub: 'JPG/PNG/WEBP · max 4MB',
                                    isCover: true,
                                    onPick: _pickCover,
                                    onClear: _cover == null
                                        ? null
                                        : () => setState(() => _cover = null),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Loqo kvadrat (1:1), cover isə enli (3:1) olsa daha yaxşı görünəcək.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B7280),
                                height: 1.35,
                              ),
                            ),

                            const SizedBox(height: 16),

                            const _FieldLabel('Mağaza fiziki ünvanı'),
                            Wrap(
                              runSpacing: 10,
                              spacing: 10,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width > 520
                                      ? 330
                                      : double.infinity,
                                  child: DropdownButtonFormField<int>(
                                    value: _cityId,
                                    decoration: _inputDecoration(
                                      hint: 'Şəhər seçin',
                                    ),
                                    items: st.cities
                                        .map(
                                          (c) => DropdownMenuItem<int>(
                                            value: c.id,
                                            child: Text(c.name),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) => setState(() => _cityId = v),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width > 520
                                      ? 330
                                      : double.infinity,
                                  child: _AppTextField(
                                    controller: _addressShort,
                                    hint: 'Məs: Nərimanov r-nu (optional)',
                                    errorText: st.fieldErrors['address_short'],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _AppTextField(
                              controller: _address,
                              hint: 'Ətraflı ünvan (küçə, bina, mərtəbə...)',
                              errorText: st.fieldErrors['address'],
                              minLines: 4,
                              maxLines: 6,
                            ),

                            const SizedBox(height: 16),

                            const _FieldLabel('İş saatları'),
                            Wrap(
                              runSpacing: 10,
                              spacing: 10,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width > 520
                                      ? 330
                                      : double.infinity,
                                  child: _AppTextField(
                                    controller: _workFrom,
                                    hint: 'Məs: 09:00',
                                    errorText: st.fieldErrors['work_hours_from'],
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width > 520
                                      ? 330
                                      : double.infinity,
                                  child: _AppTextField(
                                    controller: _workTo,
                                    hint: 'Məs: 19:00',
                                    errorText: st.fieldErrors['work_hours_to'],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'İstəsən sadəcə “Hər gün 09:00–19:00” məntiqində giriş edə bilərsən.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B7280),
                              ),
                            ),

                            const SizedBox(height: 16),

                            _FieldLabel('Telefon', requiredField: true),
                            _AppTextField(
                              controller: _phone,
                              hint: '+994 XX XXX XX XX',
                              errorText: st.fieldErrors['phone'],
                              validator: (v) {
                                if ((v ?? '').trim().isEmpty) {
                                  return 'Telefon mütləqdir';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 14),

                            const _FieldLabel('Əlavə telefon (optional)'),
                            _AppTextField(
                              controller: _phone2,
                              hint: '+994 XX XXX XX XX',
                              errorText: st.fieldErrors['phone2'],
                            ),

                            const SizedBox(height: 14),

                            const _FieldLabel('Əlavə telefon 2 (optional)'),
                            _AppTextField(
                              controller: _phone3,
                              hint: '+994 XX XXX XX XX',
                              errorText: st.fieldErrors['phone3'],
                            ),

                            const SizedBox(height: 14),

                            const _FieldLabel('Mağaza haqqında məlumat'),
                            _AppTextField(
                              controller: _description,
                              hint: 'Məs: Biz 2010-cu ildən etibarən ...',
                              errorText: st.fieldErrors['description'],
                              minLines: 4,
                              maxLines: 8,
                            ),

                            const SizedBox(height: 14),

                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFBBF7D0),
                                ),
                              ),
                              child: const Text(
                                'Müraciət göndərildikdən sonra admin təsdiqləyənə qədər mağazanız gözləmədə olacaq.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF14532D),
                                  height: 1.35,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                FilledButton(
                                  onPressed: st.submitting ? null : _submit,
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 22,
                                      vertical: 12,
                                    ),
                                    shape: const StadiumBorder(),
                                  ),
                                  child: st.submitting
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Təsdiqə göndər',
                                          style: TextStyle(
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
                  ),
                ),
              ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF10B981)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.requiredField = false});

  final String text;
  final bool requiredField;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: Color(0xFF111827),
            ),
          ),
          if (requiredField) ...[
            const SizedBox(width: 6),
            const Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  const _AppTextField({
    required this.controller,
    required this.hint,
    this.errorText,
    this.validator,
    this.minLines,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final String? errorText;
  final String? Function(String?)? validator;
  final int? minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF10B981)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.title,
    required this.subtitle,
    required this.previewPath,
    required this.placeholderTitle,
    required this.placeholderSub,
    required this.isCover,
    required this.onPick,
    required this.onClear,
  });

  final String title;
  final String subtitle;
  final String? previewPath;
  final String placeholderTitle;
  final String placeholderSub;
  final bool isCover;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final hasFile = (previewPath ?? '').isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: isCover ? 3 / 1 : 1 / 1,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                color: const Color(0xFFEEF2F7),
                child: hasFile
                    ? Image.file(
                        File(previewPath!),
                        fit: BoxFit.cover,
                      )
                    : _UploadPlaceholder(
                        title: placeholderTitle,
                        sub: placeholderSub,
                        isCover: isCover,
                      ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onClear,
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Sil'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onPick,
                  style: FilledButton.styleFrom(
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Seç'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadPlaceholder extends StatelessWidget {
  const _UploadPlaceholder({
    required this.title,
    required this.sub,
    required this.isCover,
  });

  final String title;
  final String sub;
  final bool isCover;

  @override
  Widget build(BuildContext context) {
    if (isCover) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: const Icon(
                  Icons.photo_size_select_large,
                  color: Color(0xFF111827),
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Icon(
                Icons.image_outlined,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF111827),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF991B1B),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}