import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/auth_controller.dart';

enum AuthViewMode {
  chooser,
  phoneLogin,
  otpVerify,
  emailLogin,
  register,
  forgotPassword,
}

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  AuthViewMode _mode = AuthViewMode.chooser;

  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  final _forgotEmailCtrl = TextEditingController();

  final _regNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPhoneCtrl = TextEditingController();
  final _regPasswordCtrl = TextEditingController();
  final _regPassword2Ctrl = TextEditingController();

  final List<TextEditingController> _otpCtrls = List.generate(
    4,
    (_) => TextEditingController(),
  );

  bool _rememberMe = true;
  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  bool _obscureRegisterPassword2 = true;

  String _otpPhoneText = '';

  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _forgotEmailCtrl.dispose();
    _regNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPhoneCtrl.dispose();
    _regPasswordCtrl.dispose();
    _regPassword2Ctrl.dispose();
    for (final c in _otpCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xff12161d),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String get _otpCode => _otpCtrls.map((e) => e.text).join();

  Future<void> _sendOtp() async {
    final phone = _phoneCtrl.text.trim();

    if (phone.isEmpty) {
      _toast('Telefon nömrəsini daxil et');
      return;
    }

    try {
      await ref.read(authControllerProvider.notifier).sendOtp(phone: phone);

      setState(() {
        _otpPhoneText = phone;
        _mode = AuthViewMode.otpVerify;
      });

      _toast('SMS kod göndərildi');
    } catch (_) {}
  }

  Future<void> _verifyOtp() async {
    if (_otpCode.length != 4) {
      _toast('4 rəqəmli kodu daxil et');
      return;
    }

    await ref.read(authControllerProvider.notifier).verifyOtp(
          phone: _otpPhoneText,
          code: _otpCode,
        );
  }

  Future<void> _loginEmail() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      _toast('Email və şifrəni daxil et');
      return;
    }

    await ref.read(authControllerProvider.notifier).loginWithEmail(
          email: email,
          password: password,
        );
  }

  Future<void> _register() async {
    final name = _regNameCtrl.text.trim();
    final email = _regEmailCtrl.text.trim();
    final phone = _regPhoneCtrl.text.trim();
    final password = _regPasswordCtrl.text;
    final password2 = _regPassword2Ctrl.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || password2.isEmpty) {
      _toast('Vacib sahələri doldur');
      return;
    }

    if (password != password2) {
      _toast('Şifrələr eyni deyil');
      return;
    }

    await ref.read(authControllerProvider.notifier).register(
          name: name,
          email: email,
          phone: phone.isEmpty ? null : phone,
          password: password,
          passwordConfirmation: password2,
        );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (prev, next) {
      if (prev?.error != next.error && next.error != null && next.error!.isNotEmpty) {
        _toast(next.error!);
      }
    });

    if (auth.authenticated) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: const Color(0xff050608),
      body: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          final t = _glowController.value;
          final dx1 = math.sin(t * math.pi * 2) * 24;
          final dx2 = math.cos(t * math.pi * 2) * 18;

          return Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xff080a0f),
                        Color(0xff050608),
                        Color(0xff030405),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -60,
                left: -30 + dx1,
                child: _GlowBlob(
                  size: 170,
                  color: const Color(0x2212BF82),
                ),
              ),
              Positioned(
                top: 120,
                right: -40 + dx2,
                child: _GlowBlob(
                  size: 140,
                  color: const Color(0x182D63FF),
                ),
              ),
              Positioned(
                bottom: 40,
                left: 30 - dx2,
                child: _GlowBlob(
                  size: 120,
                  color: const Color(0x16FFFFFF),
                ),
              ),
              SafeArea(
                bottom: false,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(14, 16, 14, 28),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 16,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 430),
                            child: Column(
                              children: [
                                const SizedBox(height: 6),
                                _TopBrandBlock(
                                  mode: _mode,
                                  onBack: _mode == AuthViewMode.chooser
                                      ? null
                                      : () {
                                          setState(() {
                                            _mode = AuthViewMode.chooser;
                                          });
                                        },
                                ),
                                const SizedBox(height: 14),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 240),
                                  transitionBuilder: (child, animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0.0, 0.03),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: _buildCurrentPanel(auth.loading),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentPanel(bool loading) {
    switch (_mode) {
      case AuthViewMode.chooser:
        return _AuthCardShell(
          key: const ValueKey('chooser'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 2),
              const _AuthTitle('Hesaba giriş'),
              const SizedBox(height: 10),
              const _AuthSubtitle(
                'Daxil olmaqla və ya qeydiyyatdan keçməklə, siz\n'
                'saytın daha çox funksiyalarına əlçatan\n'
                'olursunuz.',
              ),
              const SizedBox(height: 26),
              _PrimaryGreenButton(
                icon: Icons.phone_outlined,
                text: 'Telefon nömrəsi ilə',
                onTap: () => setState(() => _mode = AuthViewMode.phoneLogin),
              ),
              const SizedBox(height: 16),
              const _SoftDividerText('və-ya'),
              const SizedBox(height: 16),
              _OutlineGreenButton(
                icon: Icons.mail_outline,
                text: 'Biznes / Email Hesaba Giriş',
                onTap: () => setState(() => _mode = AuthViewMode.emailLogin),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Hesabın yoxdur ?',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xff9ca6b8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _mode = AuthViewMode.register),
                    child: const Text(
                      'Qeydiyyatdan keç',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xffff7d69),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case AuthViewMode.phoneLogin:
        return _AuthCardShell(
          key: const ValueKey('phone'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _AuthTitle('Hesaba giriş'),
              const SizedBox(height: 20),
              const _FieldLabel('Telefon Nömrəsi'),
              const SizedBox(height: 10),
              _AuthInput(
                controller: _phoneCtrl,
                hint: '(0',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _PrimaryGreenButton(
                text: loading ? 'Göndərilir...' : 'SMS - Kodu göndər',
                onTap: loading ? null : _sendOtp,
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => setState(() => _mode = AuthViewMode.emailLogin),
                child: const Text(
                  'E-mail ilə daxil ol',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xff74a8ff),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _mode = AuthViewMode.chooser),
                    child: const Text(
                      '← Geri',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xffc7d0df),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _mode = AuthViewMode.register),
                    child: const Text(
                      'Qeydiyyatdan keç',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xffff7d69),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case AuthViewMode.otpVerify:
        return _AuthCardShell(
          key: const ValueKey('otp'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _AuthTitle('Nömrənin təsdiqlənməsi'),
              const SizedBox(height: 10),
              _AuthSubtitle('($_otpPhoneText) nömrəsinə SMS-kod göndərildi'),
              const SizedBox(height: 18),
              _OtpBoxes(
                controllers: _otpCtrls,
              ),
              const SizedBox(height: 16),
              _PrimaryGreenButton(
                text: loading ? 'Təsdiqlənir...' : 'Təsdiqlə',
                onTap: loading ? null : _verifyOtp,
              ),
              const SizedBox(height: 12),
              const Text(
                'SMS-kod yenidən göndərilsin',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xff7f8898),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _mode = AuthViewMode.phoneLogin),
                    child: const Text(
                      '← Nömrəni dəyiş',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xffc7d0df),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _mode = AuthViewMode.chooser),
                    child: const Text(
                      'Çıx',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xffff7d69),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case AuthViewMode.emailLogin:
        return _AuthCardShell(
          key: const ValueKey('email'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _AuthTitle('Hesaba giriş'),
              const SizedBox(height: 20),
              const _FieldLabel('E-mail adresi'),
              const SizedBox(height: 10),
              _AuthInput(
                controller: _emailCtrl,
                hint: 'email@email.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              const _FieldLabel('Şifrə'),
              const SizedBox(height: 10),
              _AuthInput(
                controller: _passwordCtrl,
                hint: 'Şifrəniz',
                obscureText: _obscureLoginPassword,
                suffix: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureLoginPassword = !_obscureLoginPassword;
                    });
                  },
                  icon: Icon(
                    _obscureLoginPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: const Color(0xffb4bfd3),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: _rememberMe,
                      activeColor: const Color(0xff1fbd87),
                      checkColor: Colors.white,
                      side: const BorderSide(color: Color(0xff3a4355)),
                      fillColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return const Color(0xff1fbd87);
                        }
                        return const Color(0xff12161d);
                      }),
                      onChanged: (v) {
                        setState(() {
                          _rememberMe = v ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Məni xatırla',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xffb6c0d0),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _mode = AuthViewMode.forgotPassword),
                    child: const Text(
                      'Şifrəmi unutmuşam',
                      style: TextStyle(
                        color: Color(0xff74a8ff),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _PrimaryGreenButton(
                text: loading ? 'Gözləyin...' : 'Giriş',
                onTap: loading ? null : _loginEmail,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Hesabın yoxdur ?',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xff9ca6b8),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _mode = AuthViewMode.register),
                    child: const Text(
                      'Qeydiyyatdan keç',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xffff7d69),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => setState(() => _mode = AuthViewMode.chooser),
                child: const Text(
                  '← Geri',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xffc7d0df),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );

      case AuthViewMode.register:
        return _AuthCardShell(
          key: const ValueKey('register'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _AuthTitle('Qeydiyyat'),
              const SizedBox(height: 10),
              const _AuthSubtitle('Bir neçə saniyə hesab yarat'),
              const SizedBox(height: 20),
              const _FieldLabel('ad *'),
              const SizedBox(height: 10),
              _AuthInput(
                controller: _regNameCtrl,
                hint: 'Adı, Soyadı',
              ),
              const SizedBox(height: 14),
              const _FieldLabel('E-poçt *'),
              const SizedBox(height: 10),
              _AuthInput(
                controller: _regEmailCtrl,
                hint: 'your.email@dot.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              const _FieldLabel('Mobil Telefon'),
              const SizedBox(height: 10),
              _AuthInput(
                controller: _regPhoneCtrl,
                hint: '+XXX XXX XXX',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              const _FieldLabel('parol *'),
              const SizedBox(height: 10),
              _AuthInput(
                controller: _regPasswordCtrl,
                hint: 'Sizin Pass123!',
                obscureText: _obscureRegisterPassword,
                suffix: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureRegisterPassword = !_obscureRegisterPassword;
                    });
                  },
                  icon: Icon(
                    _obscureRegisterPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: const Color(0xffb4bfd3),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const _FieldLabel('Şifrəni yenidən daxil edin *'),
              const SizedBox(height: 10),
              _AuthInput(
                controller: _regPassword2Ctrl,
                hint: 'Sizin Pass123!',
                obscureText: _obscureRegisterPassword2,
                suffix: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureRegisterPassword2 = !_obscureRegisterPassword2;
                    });
                  },
                  icon: Icon(
                    _obscureRegisterPassword2
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: const Color(0xffb4bfd3),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _PrimaryGreenButton(
                text: loading ? 'Yaradılır...' : 'Hesab yarat',
                onTap: loading ? null : _register,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Artıq hesabınız var? ',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xff9ca6b8),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _mode = AuthViewMode.chooser),
                    child: const Text(
                      'Daxil ol',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xff74a8ff),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case AuthViewMode.forgotPassword:
        return _AuthCardShell(
          key: const ValueKey('forgot'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _AuthTitle('Şifrəmi unutmuşam'),
              const SizedBox(height: 10),
              const _AuthSubtitle(
                'Email adresini yaz, bərpa linki göndərək.',
              ),
              const SizedBox(height: 18),
              const _FieldLabel('Email'),
              const SizedBox(height: 10),
              _AuthInput(
                controller: _forgotEmailCtrl,
                hint: 'email@email.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _PrimaryGreenButton(
                text: 'Link göndər',
                onTap: () {
                  _toast('Forgot password API-ni sonra bağlayarıq');
                },
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => setState(() => _mode = AuthViewMode.emailLogin),
                child: const Text(
                  '← Geri',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xffc7d0df),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}

class _TopBrandBlock extends StatelessWidget {
  final AuthViewMode mode;
  final VoidCallback? onBack;

  const _TopBrandBlock({
    required this.mode,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isChooser = mode == AuthViewMode.chooser;

    return Row(
      children: [
        if (!isChooser)
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xff11151c),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          )
        else
          const SizedBox(width: 42, height: 42),
        Expanded(
          child: Column(
            children: [
              const Text(
                'elanbazar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _modeCaption(mode),
                style: const TextStyle(
                  color: Color(0xff8a95a8),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xff11151c),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: const Icon(
            Icons.shield_moon_outlined,
            size: 20,
            color: Color(0xff12bf82),
          ),
        ),
      ],
    );
  }

  static String _modeCaption(AuthViewMode mode) {
    switch (mode) {
      case AuthViewMode.chooser:
        return 'Təhlükəsiz giriş və qeydiyyat';
      case AuthViewMode.phoneLogin:
        return 'Telefon nömrəsi ilə giriş';
      case AuthViewMode.otpVerify:
        return 'SMS kod təsdiqi';
      case AuthViewMode.emailLogin:
        return 'Email ilə hesab girişi';
      case AuthViewMode.register:
        return 'Yeni hesab yarat';
      case AuthViewMode.forgotPassword:
        return 'Şifrə bərpası';
    }
  }
}

class _GlowBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowBlob({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: size * .65,
              spreadRadius: size * .12,
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthCardShell extends StatelessWidget {
  const _AuthCardShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xff0e1117).withOpacity(.94),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.40),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
          const BoxShadow(
            color: Color(0x1412BF82),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AuthTitle extends StatelessWidget {
  const _AuthTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: .1,
      ),
    );
  }
}

class _AuthSubtitle extends StatelessWidget {
  const _AuthSubtitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xff8a95a8),
        height: 1.48,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _SoftDividerText extends StatelessWidget {
  final String text;

  const _SoftDividerText(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(.09),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xff7d8799),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(.09),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: Color(0xffd8deea),
      ),
    );
  }
}

class _AuthInput extends StatelessWidget {
  const _AuthInput({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xff141922),
        border: Border.all(color: Colors.white10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 15,
            color: Color(0xff727d90),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          suffixIcon: suffix,
        ),
      ),
    );
  }
}

class _PrimaryGreenButton extends StatelessWidget {
  const _PrimaryGreenButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
  });

  final String text;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final hasIcon = icon != null;

    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff1fbd87),
          foregroundColor: Colors.white,
          elevation: 0,
          disabledBackgroundColor: const Color(0xff3f8d73),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(
            Colors.white.withOpacity(.06),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasIcon) ...[
              Icon(icon, size: 20, color: Colors.white),
              const SizedBox(width: 10),
            ],
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlineGreenButton extends StatelessWidget {
  const _OutlineGreenButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
  });

  final String text;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final hasIcon = icon != null;

    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xff12161d),
          side: const BorderSide(color: Color(0xff1fbd87), width: 1.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasIcon) ...[
              const SizedBox(width: 2),
              Icon(icon, size: 20, color: const Color(0xffd8deea)),
              const SizedBox(width: 10),
            ],
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xffe5ebf7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpBoxes extends StatefulWidget {
  const _OtpBoxes({
    required this.controllers,
  });

  final List<TextEditingController> controllers;

  @override
  State<_OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<_OtpBoxes> {
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _nodes = List.generate(widget.controllers.length, (_) => FocusNode());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_nodes.isNotEmpty) {
        _nodes.first.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.controllers.length, (index) {
        return Padding(
          padding: EdgeInsets.only(
            right: index == widget.controllers.length - 1 ? 0 : 10,
          ),
          child: SizedBox(
            width: 58,
            height: 62,
            child: TextField(
              controller: widget.controllers[index],
              focusNode: _nodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: const Color(0xff141922),
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.white10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.white10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xff1fbd87), width: 1.5),
                ),
              ),
              onChanged: (value) {
                if (value.length == 1 && index < _nodes.length - 1) {
                  _nodes[index + 1].requestFocus();
                }
                if (value.isEmpty && index > 0) {
                  _nodes[index - 1].requestFocus();
                }
              },
            ),
          ),
        );
      }),
    );
  }
}