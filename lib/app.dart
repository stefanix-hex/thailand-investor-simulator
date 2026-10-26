import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/enums.dart';
import 'providers/game_provider.dart';
import 'screens/end_game_screen.dart';
import 'screens/shell_screen.dart';
import 'screens/title_screen.dart';
import 'theme.dart';

class ThailandInvestorApp extends ConsumerWidget {
  const ThailandInvestorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(gameProvider.select((s) => s.phase));
    return MaterialApp(
      title: 'Thailand Investor Simulator',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: switch (phase) {
        GamePhase.title => const TitleScreen(),
        GamePhase.playing => const ShellScreen(),
        GamePhase.ended => const EndGameScreen(),
      },
    );
  }
}
