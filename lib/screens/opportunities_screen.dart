import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/enums.dart';
import '../models/opportunity.dart';
import '../providers/game_provider.dart';
import '../widgets/metric_card.dart';
import '../widgets/money_text.dart';

class OpportunitiesScreen extends ConsumerWidget {
  const OpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    if (game.opportunities.isEmpty) {
      return const Center(child: Text('No live deals this quarter.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: game.opportunities.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final o = game.opportunities[i];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        o.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    RiskChip(label: o.riskLevel.label),
                  ],
                ),
                const SizedBox(height: 6),
                Text('${o.location.label} · ${o.kind.name}'),
                const SizedBox(height: 8),
                Text(o.summary),
                const SizedBox(height: 8),
                Text(
                  'Ask ${money(o.askingPrice)}'
                  '${o.kind == OpportunityKind.security ? ' · yield ${percent(o.dividendYield)}' : ''}'
                  '${o.kind == OpportunityKind.realEstate ? ' · gross yield ${percent(o.grossYield)}' : ''}'
                  '${o.isDevelopment ? ' · development ${o.constructionQuarters}Q' : ''}',
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => _openDeal(context, ref, o),
                    child: const Text('Underwrite'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openDeal(
    BuildContext context,
    WidgetRef ref,
    Opportunity o,
  ) async {
    var ownership = o.ownershipOptions.isEmpty
        ? OwnershipStructure.spv
        : o.ownershipOptions.first;
    var wantLoan = false;
    var ltv = 0.5;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            final price = o.askingPrice * o.equityShare;
            final loanAmt = wantLoan ? price * ltv : 0.0;
            final down = price - loanAmt;
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 8,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o.title, style: Theme.of(ctx).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(o.summary),
                  if (o.ownershipOptions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text('Ownership structure',
                        style: Theme.of(ctx).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final own in o.ownershipOptions)
                          ChoiceChip(
                            label: Text(own.label),
                            selected: ownership == own,
                            onSelected: (_) => setLocal(() => ownership = own),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(ownership.summary,
                        style: Theme.of(ctx).textTheme.bodySmall),
                  ],
                  if (o.kind != OpportunityKind.security) ...[
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Apply for bank financing'),
                      subtitle: const Text('Approval is never automatic.'),
                      value: wantLoan,
                      onChanged: (v) => setLocal(() => wantLoan = v),
                    ),
                    if (wantLoan)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Requested LTV ${percent(ltv)}'),
                          Slider(
                            value: ltv,
                            min: 0.2,
                            max: 0.75,
                            divisions: 11,
                            onChanged: (v) => setLocal(() => ltv = v),
                          ),
                        ],
                      ),
                  ],
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Equity cheque'),
                    trailing: Text(money(down)),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () async {
                      final result = await ref.read(gameProvider.notifier).acquire(
                            o,
                            ownership: ownership,
                            loanAmount: loanAmt,
                          );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result.message)),
                        );
                      }
                    },
                    child: Text(wantLoan ? 'Submit to bank and buy' : 'Buy with cash'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
