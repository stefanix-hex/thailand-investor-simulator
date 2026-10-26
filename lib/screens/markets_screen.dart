import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/enums.dart';
import '../providers/game_provider.dart';
import '../widgets/money_text.dart';

class MarketsScreen extends ConsumerWidget {
  const MarketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final m = game.market;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Macro', style: Theme.of(context).textTheme.titleLarge),
        ListTile(title: const Text('Interest rate'), trailing: Text(percent(m.interestRate))),
        ListTile(title: const Text('Inflation'), trailing: Text(percent(m.inflation))),
        ListTile(title: const Text('EUR / THB'), trailing: Text(m.eurThb.toStringAsFixed(2))),
        ListTile(title: const Text('Tourism demand'), trailing: Text(m.tourismDemand.toStringAsFixed(2))),
        ListTile(title: const Text('Political risk'), trailing: Text(percent(m.politicalRisk))),
        ListTile(title: const Text('Construction costs'), trailing: Text(m.constructionCostIndex.toStringAsFixed(2))),
        ListTile(title: const Text('Regulatory tightness'), trailing: Text(percent(m.regulatoryTightness))),
        ListTile(title: const Text('Credit availability'), trailing: Text(m.creditAvailability.toStringAsFixed(2))),
        const SizedBox(height: 12),
        Text('Property cycles', style: Theme.of(context).textTheme.titleLarge),
        for (final loc in Location.values)
          ListTile(
            title: Text(loc.label),
            trailing: Text((m.propertyCycle[loc] ?? 1).toStringAsFixed(2)),
          ),
        const SizedBox(height: 12),
        Text('Active effects', style: Theme.of(context).textTheme.titleLarge),
        for (final e in game.activeEffects)
          ListTile(
            title: Text(e.title),
            subtitle: Text('${e.quartersRemaining}Q remaining'),
          ),
        if (game.activeEffects.isEmpty) const Text('None.'),
      ],
    );
  }
}
