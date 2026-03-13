import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/state/auth_controller.dart';
import '../../auth/ui/auth_screen.dart';
import '../../discover/ui/discover_screen.dart';
import '../../favorites/ui/favorites_screen.dart';
import '../../profile/ui/account_screen.dart';
import '../../reels/ui/reels_screen.dart';
import '../../ad_create/ui/ad_create_screen.dart';
import '../../messages/ui/messages_list_screen.dart';
import '../../messages/state/messages_unread_controller.dart';

enum HomeTopTab { reels, discover }

class MainShell extends ConsumerStatefulWidget {
  final int initialIndex;
  final HomeTopTab initialHomeTab;

  const MainShell({
    super.key,
    this.initialIndex = 0,
    this.initialHomeTab = HomeTopTab.reels,
  });

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  late int _currentIndex;
  late HomeTopTab _homeTab;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _homeTab = widget.initialHomeTab;
  }

  void _goToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openReels() {
    setState(() {
      _currentIndex = 0;
      _homeTab = HomeTopTab.reels;
    });
  }

  void _openDiscover() {
    setState(() {
      _currentIndex = 0;
      _homeTab = HomeTopTab.discover;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final unreadCount = ref.watch(messagesUnreadControllerProvider);

    final pages = <Widget>[
      HomeSwitcherScreen(
        currentTab: _homeTab,
        onOpenReels: _openReels,
        onOpenDiscover: _openDiscover,
      ),
      const FavoritesScreen(),
      const _CreateAdGateScreen(),
      const _MessagesGateScreen(),
      const _AccountGateScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xff050608),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff090b10),
              Color(0xff06070a),
              Color(0xff040506),
            ],
          ),
        ),
        child: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: _AppBottomNav(
        currentIndex: _currentIndex,
        isAuthenticated: auth.authenticated,
        accountAvatarUrl: auth.user?.photoUrl,
        unreadCount: unreadCount,
        onTap: _goToTab,
      ),
    );
  }
}

class HomeSwitcherScreen extends StatelessWidget {
  final HomeTopTab currentTab;
  final VoidCallback onOpenReels;
  final VoidCallback onOpenDiscover;

  const HomeSwitcherScreen({
    super.key,
    required this.currentTab,
    required this.onOpenReels,
    required this.onOpenDiscover,
  });

  @override
  Widget build(BuildContext context) {
    if (currentTab == HomeTopTab.discover) {
      return DiscoverScreen(
        onOpenReels: onOpenReels,
      );
    }

    return ReelsScreen(
      onOpenDiscover: onOpenDiscover,
    );
  }
}

class _AppBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isAuthenticated;
  final String? accountAvatarUrl;
  final int unreadCount;

  const _AppBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.isAuthenticated,
    required this.accountAvatarUrl,
    required this.unreadCount,
  });

  @override
  State<_AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<_AppBottomNav> {
  static const Color _green = Color(0xff12bf82);
  static const Color _panel = Color(0xff0c0f15);
  static const Color _panelSoft = Color(0xff131722);
  static const Color _border = Color(0x22ffffff);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: Container(
          height: 88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: _panel.withOpacity(.92),
            border: Border.all(color: _border),
            boxShadow: const [
              BoxShadow(
                color: Color(0xaa000000),
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x220f1720),
                          Color(0x00000000),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _NavItem(
                        icon: Icons.home_rounded,
                        inactiveIcon: Icons.home_outlined,
                        label: 'Əsas',
                        active: widget.currentIndex == 0,
                        onTap: () => widget.onTap(0),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        icon: Icons.favorite_rounded,
                        inactiveIcon: Icons.favorite_border_rounded,
                        label: 'Seçilmişlər',
                        active: widget.currentIndex == 1,
                        onTap: () => widget.onTap(1),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: GestureDetector(
                          onTap: () => widget.onTap(2),
                          behavior: HitTestBehavior.opaque,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0,
                              end: widget.currentIndex == 2 ? 1 : 0,
                            ),
                            duration: const Duration(milliseconds: 260),
                            builder: (context, v, child) {
                              final scale = 1 + (v * 0.05);

                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xff1de2a0),
                                        _green,
                                        Color(0xff0aa56f),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x6612BF82),
                                        blurRadius: 18,
                                        offset: Offset(0, 8),
                                      ),
                                      BoxShadow(
                                        color: Color(0x33000000),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white24,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.add_rounded,
                                        color: Colors.white,
                                        size: 31,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        icon: Icons.chat_bubble_rounded,
                        inactiveIcon: Icons.chat_bubble_outline_rounded,
                        label: 'Mesajlar',
                        active: widget.currentIndex == 3,
                        unreadCount: widget.unreadCount,
                        onTap: () => widget.onTap(3),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        icon: Icons.person_rounded,
                        inactiveIcon: Icons.person_outline_rounded,
                        label: 'Hesab',
                        active: widget.currentIndex == 4,
                        onTap: () => widget.onTap(4),
                        useAvatar: widget.isAuthenticated,
                        avatarUrl: widget.accountAvatarUrl,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 0,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        _panelSoft.withOpacity(.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData inactiveIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final bool useAvatar;
  final String? avatarUrl;
  final int unreadCount;

  const _NavItem({
    required this.icon,
    required this.inactiveIcon,
    required this.label,
    required this.active,
    required this.onTap,
    this.useAvatar = false,
    this.avatarUrl,
    this.unreadCount = 0,
  });

  static const Color activeColor = Color(0xfff5f7fb);
  static const Color activeSoft = Color(0xff12bf82);
  static const Color inactiveColor = Color(0xff8d96a8);

  @override
  Widget build(BuildContext context) {
    final hasAvatar =
        useAvatar && avatarUrl != null && avatarUrl!.trim().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: SizedBox(
          height: double.infinity,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: active ? 1 : 0),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              final dy = -2.0 * value;

              return Transform.translate(
                offset: Offset(0, dy),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: active
                            ? const Color(0xff161c24)
                            : Colors.transparent,
                        border: Border.all(
                          color: active
                              ? const Color(0x2212BF82)
                              : Colors.transparent,
                        ),
                      ),
                      child: useAvatar
                          ? _NavAvatar(
                              active: active,
                              hasAvatar: hasAvatar,
                              avatarUrl: avatarUrl,
                            )
                          : Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                if (active)
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x5512BF82),
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                Icon(
                                  active ? icon : inactiveIcon,
                                  size: 24,
                                  color: active ? activeColor : inactiveColor,
                                ),
                                if (unreadCount > 0 && label == 'Mesajlar')
                                  Positioned(
                                    right: -8,
                                    top: -7,
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        minWidth: 18,
                                        minHeight: 18,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        border: Border.all(
                                          color: const Color(0xff0c0f15),
                                          width: 1.5,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x55EF4444),
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          unreadCount > 99
                                              ? '99+'
                                              : '$unreadCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            height: 1.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 5),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 220),
                      style: TextStyle(
                        fontSize: 11.5,
                        color: active ? activeColor : inactiveColor,
                        fontWeight:
                            active ? FontWeight.w800 : FontWeight.w600,
                        letterSpacing: .05,
                      ),
                      child: Text(label),
                    ),
                    const SizedBox(height: 2),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: active ? 16 : 0,
                      height: 2.2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: activeSoft,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavAvatar extends StatelessWidget {
  final bool active;
  final bool hasAvatar;
  final String? avatarUrl;

  const _NavAvatar({
    required this.active,
    required this.hasAvatar,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xff1c212b),
        border: Border.all(
          color: active
              ? const Color(0xff12bf82)
              : Colors.white.withOpacity(.08),
          width: active ? 1.5 : 1,
        ),
        boxShadow: active
            ? const [
                BoxShadow(
                  color: Color(0x4412BF82),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasAvatar
          ? Image.network(
              avatarUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.person,
                size: 17,
                color: active ? Colors.white : const Color(0xff8d96a8),
              ),
            )
          : Icon(
              Icons.person,
              size: 17,
              color: active ? Colors.white : const Color(0xff8d96a8),
            ),
    );
  }
}

class _MessagesGateScreen extends ConsumerWidget {
  const _MessagesGateScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    if (!auth.initialized) {
      return const Scaffold(
        backgroundColor: Color(0xff050608),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xff12bf82),
          ),
        ),
      );
    }

    if (!auth.authenticated) {
      return const AuthScreen();
    }

    return const MessagesListScreen();
  }
}

class _CreateAdGateScreen extends ConsumerWidget {
  const _CreateAdGateScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    if (!auth.initialized) {
      return const Scaffold(
        backgroundColor: Color(0xff050608),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xff12bf82),
          ),
        ),
      );
    }

    if (!auth.authenticated) {
      return const AuthScreen();
    }

    return const _CreateAdScreen();
  }
}

class _AccountGateScreen extends ConsumerWidget {
  const _AccountGateScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    if (!auth.initialized) {
      return const Scaffold(
        backgroundColor: Color(0xff050608),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xff12bf82),
          ),
        ),
      );
    }

    if (!auth.authenticated) {
      return const AuthScreen();
    }

    return const AccountScreen();
  }
}

class _CreateAdScreen extends StatelessWidget {
  const _CreateAdScreen();

  @override
  Widget build(BuildContext context) {
    return const AdCreateScreen();
  }
}

class _MessagesScreen extends StatelessWidget {
  const _MessagesScreen();

  @override
  Widget build(BuildContext context) {
    return const MessagesListScreen();
  }
}