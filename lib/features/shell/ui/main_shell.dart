import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/state/auth_controller.dart';
import '../../auth/ui/auth_screen.dart';
import '../../discover/ui/discover_screen.dart';
import '../../favorites/ui/favorites_screen.dart';
import '../../profile/ui/account_screen.dart';
import '../../reels/ui/reels_screen.dart';

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
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: _AppBottomNav(
        currentIndex: _currentIndex,
        isAuthenticated: auth.authenticated,
        accountAvatarUrl: auth.user?.photoUrl,
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

class _AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isAuthenticated;
  final String? accountAvatarUrl;

  const _AppBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.isAuthenticated,
    required this.accountAvatarUrl,
  });

  static const Color _active = Color(0xff6b7a99);
  static const Color _inactive = Color(0xff7b8494);
  static const Color _green = Color(0xff12bf82);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 74,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xffe9edf2)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _NavItem(
                icon: Icons.home_outlined,
                label: 'Əsas',
                active: currentIndex == 0,
                onTap: () => onTap(0),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.favorite_border,
                label: 'Seçilmişlər',
                active: currentIndex == 1,
                onTap: () => onTap(1),
              ),
            ),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: () => onTap(2),
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      color: _green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x3312BF82),
                          blurRadius: 14,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.chat_bubble_outline,
                label: 'Mesajlar',
                active: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.person_outline,
                label: 'Hesab',
                active: currentIndex == 4,
                onTap: () => onTap(4),
                useAvatar: isAuthenticated,
                avatarUrl: accountAvatarUrl,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final bool useAvatar;
  final String? avatarUrl;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.useAvatar = false,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xff6b7a99);
    const inactiveColor = Color(0xff7b8494);

    final hasAvatar = useAvatar && avatarUrl != null && avatarUrl!.trim().isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (useAvatar)
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xffe5e7eb),
                  border: active ? Border.all(color: activeColor, width: 1.5) : null,
                ),
                clipBehavior: Clip.antiAlias,
                child: hasAvatar
                    ? Image.network(
                        avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.person,
                          size: 18,
                          color: active ? activeColor : inactiveColor,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 18,
                        color: active ? activeColor : inactiveColor,
                      ),
              )
            else
              Icon(
                icon,
                size: 24,
                color: active ? activeColor : inactiveColor,
              ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: active ? activeColor : inactiveColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!auth.authenticated) {
      return const AuthScreen();
    }

    return const _MessagesScreen();
  }
}

class _CreateAdGateScreen extends ConsumerWidget {
  const _CreateAdGateScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    if (!auth.initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
        body: Center(child: CircularProgressIndicator()),
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
    return const Scaffold(
      body: Center(
        child: Text(
          'Yeni elan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _MessagesScreen extends StatelessWidget {
  const _MessagesScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Mesajlar',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}