import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/shell/ui/main_shell.dart'; 

void main() {
  runApp(const ProviderScope(child: ElanBazarApp()));
}

class ElanBazarApp extends StatelessWidget {
  const ElanBazarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainShell(initialIndex: 0),
    );
  }
}