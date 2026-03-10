import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/account_controller.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final acc = ref.read(accountControllerProvider).account;
    final user = acc?.user;
    _nameCtrl.text = user?.name ?? '';
    _emailCtrl.text = user?.email ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accountControllerProvider);
    final controller = ref.read(accountControllerProvider.notifier);
    final user = state.account?.user;

    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profil',
          style: TextStyle(
            color: Color(0xff111827),
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xff111827)),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 40),
            children: [
              Row(
                children: [
                  _AvatarBig(imageUrl: user?.photoUrl),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      user?.name ?? 'İstifadəçi',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xff111827),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Profil məlumatları',
                child: Column(
                  children: [
                    _LabeledField(
                      label: 'Adınız *',
                      child: TextField(
                        controller: _nameCtrl,
                        decoration: _inputDecoration(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await controller.saveProfile(name: _nameCtrl.text.trim());
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profil məlumatları yeniləndi')),
                            );
                          } catch (_) {}
                        },
                        style: _greenBtn(),
                        child: const Text('Təqdim et'),
                      ),
                    ),
                  ],
                ),
              ),
              _SectionCard(
                title: 'E-poçtunuzu dəyişdirin',
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _LabeledField(
                        label: 'Yeni e-poçt',
                        child: TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await controller.saveEmail(_emailCtrl.text.trim());
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('E-poçt yeniləndi')),
                          );
                        } catch (_) {}
                      },
                      style: _greenBtn(),
                      child: const Text('Təqdim et'),
                    ),
                  ],
                ),
              ),
              _SectionCard(
                title: 'Şifrənizi dəyişdirin',
                child: Column(
                  children: [
                    _LabeledField(
                      label: 'Cari şifrə*',
                      child: TextField(
                        controller: _currentPasswordCtrl,
                        obscureText: true,
                        decoration: _inputDecoration(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _LabeledField(
                      label: 'Yeni şifrə*',
                      child: TextField(
                        controller: _newPasswordCtrl,
                        obscureText: true,
                        decoration: _inputDecoration(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _LabeledField(
                      label: 'Yeni şifrəni təkrarlayın*',
                      child: TextField(
                        controller: _confirmPasswordCtrl,
                        obscureText: true,
                        decoration: _inputDecoration(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await controller.savePassword(
                              currentPassword: _currentPasswordCtrl.text,
                              password: _newPasswordCtrl.text,
                              passwordConfirmation: _confirmPasswordCtrl.text,
                            );
                            _currentPasswordCtrl.clear();
                            _newPasswordCtrl.clear();
                            _confirmPasswordCtrl.clear();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Şifrə yeniləndi')),
                            );
                          } catch (_) {}
                        },
                        style: _greenBtn(),
                        child: const Text('Təqdim et'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (state.saving)
            Positioned.fill(
              child: Container(
                color: const Color(0x22000000),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffe5e7eb)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffe5e7eb)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xff10b981)),
      ),
    );
  }

  ButtonStyle _greenBtn() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xff10b981),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffe5e7eb)),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0f0f172a),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xff111827),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xff374151),
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _AvatarBig extends StatelessWidget {
  final String? imageUrl;

  const _AvatarBig({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      width: 92,
      height: 92,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xffe5e7eb),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 38),
            )
          : const Icon(Icons.person, size: 38),
    );
  }
}