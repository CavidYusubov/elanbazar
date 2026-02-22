import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/reels/ui/reels_screen.dart';

void main() {
  runApp(const ProviderScope(child: ElanBazarApp()));
}

class ElanBazarApp extends StatelessWidget {
  const ElanBazarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ReelsScreen(),
    );
  }
}