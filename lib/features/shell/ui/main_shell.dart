import 'package:flutter/material.dart';
import 'package:elanbazar/features/reels/ui/reels_screen.dart';
import 'package:elanbazar/features/discover/ui/discover_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    // 0: Reels, 1: Discover
    final pages = <Widget>[
      const ReelsScreen(),
      const DiscoverScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: ElanbazarBottomNav(
        activeIndex: _index,
        onTap: (i) {
          // yalnız Reels və Discover switch edirik
          if (i == 0) _go(0); // Əsas -> Reels (hələlik)
          if (i == 1) _go(1); // Seçilmişlər -> Discover (hələlik)
          // qalanları hələlik boş
        },
        onCreateTap: () {
          // + düyməsi
          showModalBottomSheet(
            context: context,
            showDragHandle: true,
            builder: (_) => const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Elan yerləşdir (sonra)', style: TextStyle(fontWeight: FontWeight.w900)),
                  SizedBox(height: 10),
                  Text('Burda create flow olacaq.'),
                  SizedBox(height: 18),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ElanbazarBottomNav extends StatelessWidget {
  const ElanbazarBottomNav({
    super.key,
    required this.activeIndex,
    required this.onTap,
    required this.onCreateTap,
  });

  final int activeIndex; // 0 reels, 1 discover
  final void Function(int index) onTap;
  final VoidCallback onCreateTap;

  static const _activeColor = Color(0xFF00B26A); // yaşıl
  static const _inactiveColor = Color(0xFF7A7A7A);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 74,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // bar
          Container(
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black.withOpacity(0.08))),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _item(
                  icon: Icons.home_outlined,
                  label: 'Əsas',
                  active: activeIndex == 0,
                  onTap: () => onTap(0),
                ),
                _item(
                  icon: Icons.favorite_border,
                  label: 'Seçilmişlər',
                  active: activeIndex == 1,
                  onTap: () => onTap(1),
                ),

                const SizedBox(width: 66), // + üçün boşluq

                _item(
                  icon: Icons.chat_bubble_outline,
                  label: 'Mesajlar',
                  active: false,
                  onTap: () {},
                ),
                _item(
                  icon: Icons.person_outline,
                  label: 'Hesab',
                  active: false,
                  onTap: () {},
                ),
              ],
            ),
          ),

          // floating +
          Positioned(
            bottom: 18,
            child: GestureDetector(
              onTap: onCreateTap,
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: _activeColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    final c = active ? _activeColor : _inactiveColor;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: c),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: c,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}