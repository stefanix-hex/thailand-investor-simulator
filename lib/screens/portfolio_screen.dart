import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/game_provider.dart';
import '../widgets/metric_card.dart';
import '../widgets/money_text.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final empty = game.properties.isEmpty &&
        game.businesses.isEmpty &&
        game.securities.isEmpty;
    if (empty) {
      return const Center(
        child: Text('No assets yet. Underwrite a deal this quarter.'),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Real estate', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final p in game.properties)
          Card(
            child: ListTile(
              title: Text(p.name),
              subtitle: Text(
                '${p.location.name} · ${p.ownership.name}\n'
                '${p.failed ? 'FAILED' : p.isDevelopment ? 'In construction (${p.constructionQuartersRemaining}Q)' : 'Occ ${percent(p.occupancy)}'}'
                '${p.disputeActive ? ' · dispute' : ''}',
              ),
              isThreeLine: true,
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(money(p.playerValue)),
                  RiskChip(label: p.riskLevel.name),
                ],
              ),
              onTap: () => _sell(context, ref, p.id, p.name),
            ),
          ),
        if (game.properties.isEmpty) const Text('None.'),
        const SizedBox(height: 20),
        Text('Businesses', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final b in game.businesses)
          Card(
            child: ListTile(
              title: Text(b.name),
              subtitle: Text(
                '${b.location.name} · ${b.kind.name}\n'
                '${b.failed ? 'FAILED' : 'Margin ${percent(b.margin)}'}',
              ),
              isThreeLine: true,
              trailing: Text(money(b.playerValue)),
              onTap: () => _sell(context, ref, b.id, b.name),
            ),
          ),
        if (game.businesses.isEmpty) const Text('None.'),
        const SizedBox(height: 20),
        Text('Financial assets', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final s in game.securities)
          Card(
            child: ListTile(
              title: Text(s.name),
              subtitle: Text('${s.kind.name} · yield ${percent(s.dividendYield)}'),
              trailing: Text(money(s.marketValue)),
              onTap: () => _sell(context, ref, s.id, s.name),
            ),
          ),
        if (game.securities.isEmpty) const Text('None.'),
        const SizedBox(height: 20),
        Text('Loans', style: Theme.of(context).textTheme.titleLarge),
        for (final l in game.loans)
          ListTile(
            title: Text('${l.kind.name} ${money(l.principal)}'),
            subtitle: Text(
              'Rate ${percent(l.annualRate)} · ${l.remainingQuarters}Q left · '
              'service ${money(l.quarterlyPayment)}/q',
            ),
          ),
        if (game.loans.isEmpty) const Text('No debt.'),
        const SizedBox(height: 40),
      ],
    );
  }

  Future<void> _sell(
    BuildContext context,
    WidgetRef ref,
    String id,
    String name,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sell $name?'),
        content: const Text(
          'Sale is at a bid-ask discount. Attached loans are repaid from proceeds.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sell')),
        ],
      ),
    );
    if (ok != true) return;
    final result = await ref.read(gameProvider.notifier).sell(id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
    }
  }
}
