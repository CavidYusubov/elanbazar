import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/followers_controller.dart';

class FollowersScreen extends ConsumerWidget {
  const FollowersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(followersControllerProvider);
    final controller = ref.read(followersControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),
      appBar: AppBar(
        title: const Text('Məni izləyənlər'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshAll,
        child: state.loading
            ? const Center(child: CircularProgressIndicator())
            : state.items.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 100),
                      Center(child: Text('Hələ səni izləyən yoxdur.')),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(10),
                    itemCount: state.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return _FollowerTile(
                        name: item.target.name,
                        imageUrl: item.target.photoUrl,
                      );
                    },
                  ),
      ),
    );
  }
}

class _FollowerTile extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const _FollowerTile({
    required this.name,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe5e7eb)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xffe5e7eb),
            backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
            child: !hasImage ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'İstifadəçi',
              style: TextStyle(fontSize: 12, color: Color(0xff6b7280)),
            ),
          ),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}