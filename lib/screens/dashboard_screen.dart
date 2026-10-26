import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/enums.dart';
import '../providers/game_provider.dart';
import '../widgets/metric_card.dart';
import '../widgets/money_text.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final m = ref.watch(metricsProvider);
    final event = game.currentEvent;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(game.periodLabel, style: Theme.of(context).textTheme.headlineSmall),
        Text(
          'Turn ${game.turn} of 160',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        if (event != null)
          Card(
            color: event.tone == EventTone.negative
                ? Theme.of(context).colorScheme.errorContainer
                : event.tone == EventTone.positive
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(event.body),
                  const SizedBox(height: 8),
                  Text(
                    'Persists ${event.quartersRemaining} quarter(s) · ${event.tone.name}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _m('Cash', money(m.cash), alert: m.cash < 0),
            _m('Portfolio', money(m.portfolioValue)),
            _m('Debt', money(m.debt)),
            _m('Net worth', money(m.netWorth)),
            _m(
  'Reputation',
  '${game.reputation.toStringAsFixed(0)}/100',
),
_m(
  'Tier',
  game.reputationTier,
),
            _m('Passive income', '${money(m.passiveIncome)}/yr'),
            _m('LTV', percent(m.ltv), alert: m.ltv > 0.7),
            _m('DSCR', ratio(m.dscr), alert: m.dscr < 1.2 && m.quarterlyDebtService > 0),
            _m('ROI', percent(m.roi)),
            _m('ROE', percent(m.roe)),
            _m('Occupancy', percent(m.occupancyRate)),
            _m('ADR', m.adr == 0 ? '—' : money(m.adr)),
            _m('RevPAR', m.revpar == 0 ? '—' : money(m.revpar)),
          ],
        ),
        if (game.reputationLastChange != null)
  Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Text(
      'Last Reputation Change: ${game.reputationLastChange}',
      style: Theme.of(context).textTheme.bodySmall,
    ),
  ),
        const SizedBox(height: 20),
        Text('This quarter cash flow', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ListTile(
          title: const Text('NOI (est.)'),
          trailing: Text(money(m.quarterlyNoi)),
        ),
        ListTile(
          title: const Text('Debt service'),
          trailing: Text(money(m.quarterlyDebtService)),
        ),
        ListTile(
          title: const Text('Free cash after debt'),
          trailing: Text(money(m.quarterlyNoi - m.quarterlyDebtService)),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: game.phase == GamePhase.playing
              ? () async {
                  final confirm = game.isFinalQuarter;
                  if (confirm) {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Close the campaign?'),
                        content: const Text(
                          'Year 20 Q4 will process and the game will end.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Stay'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Close year 20'),
                          ),
                        ],
                      ),
                    );
                    if (ok != true) return;
                  }
                  await ref.read(gameProvider.notifier).closeQuarter();
                  if (context.mounted) {
                    final msg = ref.read(gameProvider.notifier).lastMessage;
                    if (msg != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(msg)),
                      );
                    }
                  }
                }
              : null,
          icon: const Icon(Icons.calendar_month),
          label: Text(game.isFinalQuarter ? 'Close Year 20 Q4' : 'Close quarter'),
        ),
        const SizedBox(height: 20),
        Text('Ledger', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final line in game.log.reversed.take(12))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(line, style: Theme.of(context).textTheme.bodySmall),
          ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _m(String label, String value, {bool alert = false}) {
    return SizedBox(
      width: 180,
      child: MetricCard(label: label, value: value, alert: alert),
    );
  }
}
