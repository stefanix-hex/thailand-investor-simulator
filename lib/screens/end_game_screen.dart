import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/game_provider.dart';
import '../widgets/metric_card.dart';
import '../widgets/money_text.dart';

class EndGameScreen extends ConsumerWidget {
  const EndGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(gameProvider).report;
    if (report == null) {
      return const Scaffold(body: Center(child: Text('No report.')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Year 20 · Final report')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Campaign complete. No further turns.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 220,
                child: MetricCard(
                  label: 'Final net worth',
                  value: money(report.finalNetWorth),
                ),
              ),
              SizedBox(
                width: 220,
                child: MetricCard(
                  label: 'Passive income',
                  value: '${money(report.finalPassiveIncome)}/yr',
                ),
              ),
              SizedBox(
                width: 220,
                child: MetricCard(
                  label: 'Total assets',
                  value: money(report.totalAssets),
                ),
              ),
              SizedBox(
                width: 220,
                child: MetricCard(
                  label: 'Remaining debt',
                  value: money(report.remainingDebt),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Best investments', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final i in report.bestInvestments)
            ListTile(
              title: Text(i.name),
              subtitle: Text('ROI ${percent(i.roi)}'),
              trailing: Text(money(i.profit)),
            ),
          const SizedBox(height: 16),
          Text('Worst investments', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final i in report.worstInvestments)
            ListTile(
              title: Text(i.name),
              subtitle: Text('ROI ${percent(i.roi)}'),
              trailing: Text(money(i.profit)),
            ),
          const SizedBox(height: 16),
          Text('Major decisions', style: Theme.of(context).textTheme.titleLarge),
          for (final d in report.majorDecisions)
            ListTile(title: Text(d.title), subtitle: Text(d.detail)),
          const SizedBox(height: 16),
          Text('Portfolio performance', style: Theme.of(context).textTheme.titleLarge),
          for (final n in report.portfolioNotes) ListTile(title: Text(n)),
          const SizedBox(height: 16),
          Text('Risk analysis', style: Theme.of(context).textTheme.titleLarge),
          for (final n in report.riskNotes) ListTile(title: Text(n)),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => ref.read(gameProvider.notifier).newGame(),
            child: const Text('Start another campaign'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
