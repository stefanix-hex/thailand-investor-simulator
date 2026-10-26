import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.hint,
    this.alert = false,
  });

  final String label;
  final String value;
  final String? hint;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: alert ? scheme.errorContainer : scheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.6,
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: alert ? scheme.onErrorContainer : scheme.onSurface,
                  ),
            ),
            if (hint != null) ...[
              const SizedBox(height: 4),
              Text(hint!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class RiskChip extends StatelessWidget {
  const RiskChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final high = label.startsWith('High');
    final med = label.startsWith('Medium');
    final color = high
        ? Colors.red.shade700
        : med
            ? Colors.orange.shade800
            : Colors.teal.shade800;
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: color.withOpacity(0.4)),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
    );
  }
}
