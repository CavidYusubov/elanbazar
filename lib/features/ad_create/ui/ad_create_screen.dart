import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../state/ad_create_controller.dart';
import '../state/ad_create_state.dart';
import 'widgets/ad_create_attribute_field.dart';
import 'widgets/ad_create_category_picker_sheet.dart';
import 'widgets/ad_create_image_picker.dart';
import 'widgets/ad_create_loading.dart';

class AdCreateScreen extends ConsumerStatefulWidget {
  const AdCreateScreen({super.key});

  @override
  ConsumerState<AdCreateScreen> createState() => _AdCreateScreenState();
}

class _AdCreateScreenState extends ConsumerState<AdCreateScreen> {
  final _picker = ImagePicker();

  late final TextEditingController _priceC;
  late final TextEditingController _descC;
  late final TextEditingController _nameC;
  late final TextEditingController _emailC;
  late final TextEditingController _phoneC;

  bool _bootstrapped = false;
  PageController? _previewPageController;

  @override
  void initState() {
    super.initState();
    _priceC = TextEditingController();
    _descC = TextEditingController();
    _nameC = TextEditingController();
    _emailC = TextEditingController();
    _phoneC = TextEditingController();
    _previewPageController = PageController(viewportFraction: .88);

    Future.microtask(() {
      ref.read(adCreateControllerProvider.notifier).init();
    });
  }

  @override
  void dispose() {
    _priceC.dispose();
    _descC.dispose();
    _nameC.dispose();
    _emailC.dispose();
    _phoneC.dispose();
    _previewPageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adCreateControllerProvider);
    final vm = ref.read(adCreateControllerProvider.notifier);

    _syncControllers(state);

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: const Color(0xff090b10),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xff1a1d24),
          labelStyle: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
          hintStyle: const TextStyle(color: Colors.white38),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Colors.white10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xff12bf82), width: 1.4),
          ),
        ),
      ),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xff0c0f15),
                Color(0xff090b10),
                Color(0xff050608),
              ],
            ),
          ),
          child: SafeArea(
            child: state.isLoading && state.meta == null
                ? const AdCreateLoadingView()
                : Column(
                    children: [
                      _buildTopBar(context, state),
                      Expanded(
                        child: RefreshIndicator(
                          color: const Color(0xff12bf82),
                          backgroundColor: const Color(0xff1a1d24),
                          onRefresh: () => vm.init(),
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
                            children: [
                              if (state.error != null)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff2a1316),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: Colors.redAccent.withValues(alpha: .28)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 1),
                                        child: Icon(Icons.info_outline, color: Colors.redAccent),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          state.error!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              _previewBlock(state),

                              const SizedBox(height: 16),

                              _categoryBlock(state, vm),

                              const SizedBox(height: 16),

                              _sectionCard(
                                title: 'Qiymət və yerləşmə',
                                subtitle: 'Elanın əsas məlumatları',
                                child: Column(
                                  children: [
                                    DropdownButtonFormField(
                                      value: state.selectedCity,
                                      dropdownColor: const Color(0xff1a1d24),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      decoration: const InputDecoration(
                                        labelText: 'Şəhər',
                                      ),
                                      items: (state.meta?.cities ?? [])
                                          .map(
                                            (city) => DropdownMenuItem(
                                              value: city,
                                              child: Text(city.name),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: vm.setCity,
                                      iconEnabledColor: Colors.white70,
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _priceC,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      decoration: const InputDecoration(
                                        labelText: 'Qiymət',
                                        hintText: 'Məs: 12500',
                                      ),
                                      onChanged: vm.setPrice,
                                    ),
                                    const SizedBox(height: 12),
                                    DropdownButtonFormField<String>(
                                      value: state.currency,
                                      dropdownColor: const Color(0xff1a1d24),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      decoration: const InputDecoration(
                                        labelText: 'Valyuta',
                                      ),
                                      items: (state.meta?.currencies ?? const ['AZN'])
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) {
                                        if (v != null) vm.setCurrency(v);
                                      },
                                      iconEnabledColor: Colors.white70,
                                    ),
                                    const SizedBox(height: 12),
                                    DropdownButtonFormField<String>(
                                      value: state.condition,
                                      dropdownColor: const Color(0xff1a1d24),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      decoration: const InputDecoration(
                                        labelText: 'Vəziyyət',
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: 'new', child: Text('Yeni')),
                                        DropdownMenuItem(value: 'used', child: Text('İşlənmiş')),
                                      ],
                                      onChanged: (v) {
                                        if (v != null) vm.setCondition(v);
                                      },
                                      iconEnabledColor: Colors.white70,
                                    ),
                                    const SizedBox(height: 12),
                                    _switchTile(
                                      title: 'Çatdırılma mövcuddur',
                                      subtitle: 'Müştəriyə çatdırılma imkanı göstər',
                                      value: state.hasDelivery,
                                      onChanged: vm.setHasDelivery,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              if (state.attributes.isNotEmpty)
                                _sectionCard(
                                  title: 'Elan parametrləri',
                                  subtitle: 'Kateqoriyaya uyğun dinamik sahələr',
                                  child: Column(
                                    children: state.attributes
                                        .where((attr) => vm.isAttributeVisible(attr.id))
                                        .map(
                                          (attr) => Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: AdCreateAttributeField(
                                              attribute: attr,
                                              value: vm.getAttributeValue(attr.id),
                                              onChanged: (value) {
                                                vm.setAttributeValue(attr.id, value);
                                              },
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),

                              if (state.attributes.isNotEmpty) const SizedBox(height: 16),

                              _sectionCard(
                                title: 'Təsvir',
                                subtitle: 'Elanın güclü tərəflərini yaz',
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: _descC,
                                      minLines: 5,
                                      maxLines: 9,
                                      maxLength: 3000,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      decoration: const InputDecoration(
                                        labelText: 'Məzmun',
                                        hintText: 'Üstünlüklərini, vəziyyətini, vacib məqamları qeyd et...',
                                        counterStyle: TextStyle(color: Colors.white38),
                                      ),
                                      onChanged: vm.setDescription,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              AdCreateImagePicker(
                                images: state.images,
                                coverIndex: state.coverIndex,
                                maxImages: AdCreateController.maxImages,
                                onAdd: _pickImages,
                                onRemove: vm.removeImageAt,
                                onSetCover: vm.setCoverIndex,
                                onReorder: vm.reorderImages,
                              ),

                              const SizedBox(height: 16),

                              _sectionCard(
                                title: 'Əlaqə məlumatları',
                                subtitle: 'Müştəri səninlə necə əlaqə saxlasın',
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: _nameC,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                      decoration: const InputDecoration(
                                        labelText: 'Ad',
                                      ),
                                      onChanged: vm.setContactName,
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _emailC,
                                      keyboardType: TextInputType.emailAddress,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                      decoration: const InputDecoration(
                                        labelText: 'E-mail',
                                      ),
                                      onChanged: vm.setContactEmail,
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _phoneC,
                                      keyboardType: TextInputType.phone,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                      decoration: const InputDecoration(
                                        labelText: 'Mobil nömrə',
                                        hintText: '+994 XX XXX XX XX',
                                      ),
                                      onChanged: vm.setContactPhone,
                                    ),
                                    const SizedBox(height: 12),
                                    DropdownButtonFormField<String>(
                                      value: state.contactMethod,
                                      dropdownColor: const Color(0xff1a1d24),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      decoration: const InputDecoration(
                                        labelText: 'Əlaqə üsulu',
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'calls_messages',
                                          child: Text('Zənglər və mesajlar'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'calls',
                                          child: Text('Yalnız zəng'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'messages',
                                          child: Text('Yalnız mesaj'),
                                        ),
                                      ],
                                      onChanged: (v) {
                                        if (v != null) vm.setContactMethod(v);
                                      },
                                      iconEnabledColor: Colors.white70,
                                    ),
                                    if (state.meta?.store.canPostAsStore == true) ...[
                                      const SizedBox(height: 12),
                                      _switchTile(
                                        title: 'Mağaza kimi paylaş',
                                        subtitle: state.meta?.store.name ?? 'Store hesabı aktivdir',
                                        value: state.postAsStore,
                                        onChanged: vm.setPostAsStore,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: const Color(0xff090b10).withValues(alpha: .96),
              border: const Border(
                top: BorderSide(color: Colors.white10),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55000000),
                  blurRadius: 20,
                  offset: Offset(0, -6),
                ),
              ],
            ),
            child: SizedBox(
              height: 56,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xff12bf82),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: state.isSubmitting ? null : _submit,
                child: state.isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Elanı əlavə et',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AdCreateState state) {
    final leaf = state.selectedLeaf?.name;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Yeni elan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (leaf != null)
                  Text(
                    leaf,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xff171b22),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(Icons.auto_awesome, color: Color(0xff12bf82), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _previewBlock(AdCreateState state) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xff111318),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white10),
      ),
      child: state.images.isEmpty
          ? Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xff1d2330),
                          Color(0xff111318),
                        ],
                      ),
                    ),
                  ),
                ),
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_circle_outline_rounded, size: 58, color: Colors.white54),
                      SizedBox(height: 10),
                      Text(
                        'Reels preview',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Şəkil əlavə etdikcə burada görünüş formalaşacaq',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Stack(
              children: [
                PageView.builder(
                  controller: _previewPageController,
                  itemCount: state.images.length,
                  itemBuilder: (context, index) {
                    final image = state.images[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              image,
                              fit: BoxFit.cover,
                            ),
                            DecoratedBox(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0x22000000),
                                    Color(0x00000000),
                                    Color(0xAA000000),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 14,
                              right: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: .45),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  index == state.coverIndex ? 'Cover' : 'Preview',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 18,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.selectedLeaf?.name ?? 'Yeni elan',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    state.price.isEmpty
                                        ? 'Qiymət əlavə et'
                                        : '${state.price} ${state.currency}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (state.description.trim().isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      state.description.trim(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .45),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${state.images.length} şəkil',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

Widget _categoryBlock(AdCreateState state, AdCreateController vm) {
  final path = _selectedPath(state);

  return Container(
    decoration: BoxDecoration(
      color: const Color(0xff111318),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white10),
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kateqoriya',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          path.isEmpty ? 'Kateqoriya seçilməyib' : path,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const _CategoryFlowScreen(),
              ),
            );
            if (mounted) setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xff1a1d24),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Kateqoriya seç',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (state.selectedLeaf != null)
                  GestureDetector(
                    onTap: () {
                      vm.clearSelectedCategory();
                      setState(() {});
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xff2a1316),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Sıfırla',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white70),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff111318),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff1a1d24),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: const Color(0xff12bf82),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  String _selectedPath(AdCreateState state) {
    final parts = <String>[
      if (state.selectedRoot != null) state.selectedRoot!.name,
      if (state.selectedLevel2 != null) state.selectedLevel2!.name,
      if (state.selectedLeaf != null &&
          state.selectedLeaf!.id != state.selectedLevel2?.id &&
          state.selectedLeaf!.id != state.selectedRoot?.id)
        state.selectedLeaf!.name,
    ];
    return parts.join(' / ');
  }

  Future<void> _pickImages() async {
    final vm = ref.read(adCreateControllerProvider.notifier);
    final picked = await _picker.pickMultiImage(imageQuality: 90);
    if (picked.isEmpty) return;
    vm.addImages(picked.map((x) => File(x.path)).toList());
  }

  Future<void> _submit() async {
    final ok = await ref.read(adCreateControllerProvider.notifier).submit();
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Elan moderator təsdiqinə göndərildi.'),
        ),
      );
      Navigator.of(context).maybePop(true);
    }
  }

  void _syncControllers(AdCreateState state) {
    if (!_bootstrapped && state.meta != null) {
      _bootstrapped = true;
      _priceC.text = state.price;
      _descC.text = state.description;
      _nameC.text = state.contactName;
      _emailC.text = state.contactEmail;
      _phoneC.text = state.contactPhone;
      return;
    }

    if (_priceC.text != state.price) _priceC.text = state.price;
    if (_descC.text != state.description) _descC.text = state.description;
    if (_nameC.text != state.contactName) _nameC.text = state.contactName;
    if (_emailC.text != state.contactEmail) _emailC.text = state.contactEmail;
    if (_phoneC.text != state.contactPhone) _phoneC.text = state.contactPhone;
  }

  
}


class _CategoryFlowScreen extends ConsumerStatefulWidget {
  const _CategoryFlowScreen();

  @override
  ConsumerState<_CategoryFlowScreen> createState() => _CategoryFlowScreenState();
}


class _CategoryFlowScreenState extends ConsumerState<_CategoryFlowScreen> {
  int step = 1;

  @override
  void initState() {
    super.initState();

    final state = ref.read(adCreateControllerProvider);

    if (state.selectedLeaf != null) {
      if (state.selectedLevel2 != null &&
          state.selectedLeaf!.id != state.selectedLevel2!.id) {
        step = 3;
      } else {
        step = 2;
      }
    } else if (state.selectedLevel2 != null) {
      step = 2;
    } else {
      step = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adCreateControllerProvider);
    final vm = ref.read(adCreateControllerProvider.notifier);

    final items = _itemsForStep(state);
    final title = switch (step) {
      1 => 'Kateqoriya seç',
      2 => 'Alt kateqoriya seç',
      _ => '3-cü səviyyə seç',
    };

    return Scaffold(
      backgroundColor: const Color(0xff090b10),
      appBar: AppBar(
        backgroundColor: const Color(0xff090b10),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          onPressed: () {
            if (step > 1) {
              setState(() {
                step -= 1;
              });
            } else {
              Navigator.of(context).pop();
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_pathText(state).isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xff111318),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white10),
                ),
                child: Text(
                  _pathText(state),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (step > 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Row(
                  children: [
                    _crumbButton(
                      title: 'Kök',
                      active: step == 1,
                      onTap: () {
                        setState(() {
                          step = 1;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    if (state.selectedRoot != null)
                      _crumbButton(
                        title: state.selectedRoot!.name,
                        active: step == 2,
                        onTap: () {
                          setState(() {
                            step = 2;
                          });
                        },
                      ),
                    const SizedBox(width: 8),
                    if (state.selectedLevel2 != null &&
                        state.selectedLeaf != null &&
                        state.selectedLevel2!.id != state.selectedLeaf!.id)
                      _crumbButton(
                        title: state.selectedLevel2!.name,
                        active: step == 3,
                        onTap: () {
                          setState(() {
                            step = 3;
                          });
                        },
                      ),
                  ],
                ),
              ),
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text(
                        'Məlumat tapılmadı',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: .95,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final selected = _isSelected(state, item.id);

                        return GestureDetector(
                          onTap: () async {
                            if (step == 1) {
                              await vm.selectRoot(item);
                              if (!mounted) return;
                              setState(() {
                                step = 2;
                              });
                              return;
                            }

                            if (step == 2) {
                              await vm.selectLevel2(item);
                              if (!mounted) return;

                              final updated = ref.read(adCreateControllerProvider);
                              if (updated.level3.isEmpty) {
                                Navigator.of(context).pop();
                              } else {
                                setState(() {
                                  step = 3;
                                });
                              }
                              return;
                            }

                            await vm.selectLeaf(item);
                            if (!mounted) return;
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xff12bf82)
                                  : const Color(0xff141821),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: selected
                                    ? const Color(0xff12bf82)
                                    : Colors.white10,
                              ),
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 66,
                                  height: 66,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? Colors.white.withOpacity(.18)
                                        : const Color(0xff1f2430),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.grid_view_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  item.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> _itemsForStep(dynamic state) {
    if (step == 1) return state.roots;
    if (step == 2) return state.level2;
    return state.level3;
  }

  bool _isSelected(dynamic state, int id) {
    if (step == 1) return state.selectedRoot?.id == id;
    if (step == 2) return state.selectedLevel2?.id == id;
    return state.selectedLeaf?.id == id;
  }

  String _pathText(dynamic state) {
    final parts = <String>[
      if (state.selectedRoot != null) state.selectedRoot!.name,
      if (state.selectedLevel2 != null) state.selectedLevel2!.name,
      if (state.selectedLeaf != null &&
          state.selectedLeaf!.id != state.selectedLevel2?.id &&
          state.selectedLeaf!.id != state.selectedRoot?.id)
        state.selectedLeaf!.name,
    ];
    return parts.join(' / ');
  }

  Widget _crumbButton({
    required String title,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xff12bf82) : const Color(0xff141821),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? const Color(0xff12bf82) : Colors.white10,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: active ? FontWeight.w800 : FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}