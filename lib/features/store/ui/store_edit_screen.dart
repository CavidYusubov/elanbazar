import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../models/store_models.dart';
import '../state/store_edit_controller.dart';

class StoreEditScreen extends ConsumerStatefulWidget {
  const StoreEditScreen({super.key});

  @override
  ConsumerState<StoreEditScreen> createState() => _StoreEditScreenState();
}

class _StoreEditScreenState extends ConsumerState<StoreEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final _name = TextEditingController();
  final _addressShort = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _workFrom = TextEditingController();
  final _workTo = TextEditingController();
  final _description = TextEditingController();

  int? _cityId;
  XFile? _logo;
  XFile? _cover;
  final List<XFile> _newGallery = [];

  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(storeEditControllerProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _addressShort.dispose();
    _address.dispose();
    _phone.dispose();
    _workFrom.dispose();
    _workTo.dispose();
    _description.dispose();
    super.dispose();
  }

  void _seed(StoreDashboard s) {
    if (_seeded) return;
    _seeded = true;

    _name.text = s.name;
    _address.text = s.address ?? '';
    _phone.text = s.phone ?? '';
    _workFrom.text = s.workHours.from ?? '';
    _workTo.text = s.workHours.to ?? '';
    _description.text = s.description ?? '';
    _cityId = s.city?.id;
  }

  Future<void> _pickLogo() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (file == null) return;
    setState(() => _logo = file);
  }

  Future<void> _pickCover() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
    );
    if (file == null) return;
    setState(() => _cover = file);
  }

  Future<void> _pickGallery() async {
    final files = await _picker.pickMultiImage(imageQuality: 92);
    if (files.isEmpty) return;
    setState(() {
      _newGallery.addAll(files);
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(storeEditControllerProvider.notifier).save(
          StoreUpdatePayload(
            name: _name.text.trim(),
            phone: _phone.text.trim(),
            cityId: _cityId,
            addressShort: _addressShort.text.trim(),
            address: _address.text.trim(),
            workHoursFrom: _workFrom.text.trim(),
            workHoursTo: _workTo.text.trim(),
            description: _description.text.trim(),
            logoPath: _logo?.path,
            coverPath: _cover?.path,
            galleryPaths: _newGallery.map((e) => e.path).toList(),
          ),
        );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mağaza məlumatları yeniləndi.'),
        ),
      );

      setState(() {
        _logo = null;
        _cover = null;
        _newGallery.clear();
        _seeded = false;
      });

      await ref.read(storeEditControllerProvider.notifier).load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(storeEditControllerProvider);

    if (st.store != null) {
      _seed(st.store!);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mağazanı düzəliş et',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: st.loading && st.store == null
          ? const Center(child: CircularProgressIndicator())
          : st.store == null
              ? _ErrorState(
                  text: st.error ?? 'Məlumat tapılmadı',
                  onRetry: () {
                    ref.read(storeEditControllerProvider.notifier).load();
                  },
                )
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 28),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 920),
                        child: Column(
                          children: [
                            _TopCard(
                              onBack: () => Navigator.of(context).pop(),
                              child: Column(
                                children: [
                                  _SectionCard(
                                    title: 'Əsas məlumatlar',
                                    subtitle:
                                        'Ad, ünvan, telefon, iş saatları və haqqında hissəsini yenilə.',
                                    child: Column(
                                      children: [
                                        _FieldLabel('Mağazanın adı', requiredField: true),
                                        _AppTextField(
                                          controller: _name,
                                          hint: 'Mağaza adı',
                                          errorText: st.fieldErrors['name'],
                                          validator: (v) {
                                            if ((v ?? '').trim().isEmpty) {
                                              return 'Mağazanın adı mütləqdir';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 14),
                                        const _FieldLabel('Ünvan'),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: DropdownButtonFormField<int>(
                                                value: _cityId,
                                                decoration: _inputDecoration('Şəhər seçin'),
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
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: _AppTextField(
                                                controller: _addressShort,
                                                hint: 'Qısa ünvan (optional)',
                                                errorText: st.fieldErrors['address_short'],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        _AppTextField(
                                          controller: _address,
                                          hint: 'Ətraflı ünvan',
                                          errorText: st.fieldErrors['address'],
                                          minLines: 4,
                                          maxLines: 6,
                                        ),
                                        const SizedBox(height: 14),
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
                                        const _FieldLabel('İş saatları'),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _AppTextField(
                                                controller: _workFrom,
                                                hint: '09:00',
                                                errorText: st.fieldErrors['work_hours_from'],
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: _AppTextField(
                                                controller: _workTo,
                                                hint: '19:00',
                                                errorText: st.fieldErrors['work_hours_to'],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        const Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Gecə rejimi də ola bilər (məs: 20:00 → 01:00).',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        const _FieldLabel('Mağaza haqqında'),
                                        _AppTextField(
                                          controller: _description,
                                          hint: 'Haqqında...',
                                          errorText: st.fieldErrors['description'],
                                          minLines: 5,
                                          maxLines: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  _SectionCard(
                                    title: 'Vizual hissə',
                                    subtitle: 'Logo və cover yenilə.',
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _UploadCard(
                                                title: 'Logo',
                                                previewUrl: _logo?.path ?? st.store!.logoUrl,
                                                isFile: _logo != null,
                                                isCover: false,
                                                onPick: _pickLogo,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _UploadCard(
                                                title: 'Cover',
                                                previewUrl: _cover?.path ?? st.store!.coverUrl,
                                                isFile: _cover != null,
                                                isCover: true,
                                                onPick: _pickCover,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            _SectionCard(
                              title: 'Qalareya',
                              subtitle:
                                  'Şəkilləri sırala, sil və yenilərini əlavə et.',
                              trailing: Text(
                                '${st.store!.gallery.length + _newGallery.length} / 10',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: _pickGallery,
                                    icon: const Icon(Icons.add_photo_alternate_outlined),
                                    label: const Text('Şəkil əlavə et'),
                                  ),
                                  if (st.fieldErrors['gallery'] != null) ...[
                                    const SizedBox(height: 12),
                                    _InlineError(text: st.fieldErrors['gallery']!),
                                  ],
                                  const SizedBox(height: 14),
                                  if (st.store!.gallery.isNotEmpty)
                                   ReorderableGridView.builder(
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemCount: st.store!.gallery.length,
                                                dragEnabled: true,
                                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 3,
                                                    crossAxisSpacing: 10,
                                                    mainAxisSpacing: 10,
                                                    childAspectRatio: 1,
                                                ),
                                                onReorder: (oldIndex, newIndex) async {
                                                    final list = [...st.store!.gallery];
                                                    if (oldIndex < newIndex) newIndex -= 1;
                                                    final item = list.removeAt(oldIndex);
                                                    list.insert(newIndex, item);

                                                    final ids = list.map((e) => e.id).toList();
                                                    await ref
                                                        .read(storeEditControllerProvider.notifier)
                                                        .sortGallery(ids);
                                                },
                                                itemBuilder: (context, index) {
                                                    final img = st.store!.gallery[index];
                                                    return _GalleryTile(
                                                    key: ValueKey('gallery-${img.id}'),
                                                    image: Image.network(
                                                        img.url,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_, __, ___) {
                                                        return Container(
                                                            color: const Color(0xFFF3F4F6),
                                                            child: const Icon(Icons.image_not_supported),
                                                        );
                                                        },
                                                    ),
                                                    onDelete: () async {
                                                        await ref
                                                            .read(storeEditControllerProvider.notifier)
                                                            .deleteGallery(img.id);
                                                    },
                                                    );
                                                },
                                                )
                                  else
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF9FAFB),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: const Color(0xFFE5E7EB)),
                                      ),
                                      child: const Text(
                                        'Hələ qalareya şəkli yoxdur.',
                                        style: TextStyle(color: Color(0xFF6B7280)),
                                      ),
                                    ),
                                  if (_newGallery.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Yeni əlavə ediləcək şəkillər',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: List.generate(_newGallery.length, (index) {
                                        final img = _newGallery[index];
                                        return _GalleryTile(
                                          image: Image.file(
                                            File(img.path),
                                            fit: BoxFit.cover,
                                          ),
                                          showDrag: false,
                                          onDelete: () {
                                            setState(() => _newGallery.removeAt(index));
                                          },
                                        );
                                      }),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.icon(
                                onPressed: st.saving ? null : _save,
                                icon: st.saving
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.check_circle_outline),
                                label: Text(st.saving ? 'Yadda saxlanır...' : 'Yadda saxla'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 13,
                                  ),
                                  shape: const StadiumBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
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

class _TopCard extends StatelessWidget {
  const _TopCard({
    required this.child,
    required this.onBack,
  });

  final Widget child;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Mağazanı düzəliş et',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Geri'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: child,
          ),
        ],
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
              fontWeight: FontWeight.w900,
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
    required this.previewUrl,
    required this.isFile,
    required this.isCover,
    required this.onPick,
  });

  final String title;
  final String? previewUrl;
  final bool isFile;
  final bool isCover;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final hasImage = (previewUrl ?? '').trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF9FAFB),
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: isCover ? 2.4 / 1 : 1 / 1,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: hasImage
                  ? (isFile
                      ? Image.file(
                          File(previewUrl!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : Image.network(
                          previewUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        ))
                  : _placeholder(),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
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

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFEEF2F7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Icon(
                isCover ? Icons.photo_size_select_large : Icons.image_outlined,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isCover ? 'Cover yoxdur' : 'Logo yoxdur',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({
    super.key,
    required this.image,
    required this.onDelete,
    this.showDrag = true,
  });

  final Widget image;
  final VoidCallback onDelete;
  final bool showDrag;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        color: Colors.white,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: image,
            ),
          ),
          if (showDrag)
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.55),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.drag_indicator, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Sırala',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            top: 6,
            right: 6,
            child: InkWell(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.text,
    required this.onRetry,
  });

  final String text;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.store_mall_directory_outlined, size: 42),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Yenidən yoxla'),
            ),
          ],
        ),
      ),
    );
  }
}