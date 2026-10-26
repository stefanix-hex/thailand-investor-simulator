import '../models/enums.dart';
import '../models/game_state.dart';
import '../models/market.dart';
import 'rng.dart';

class MarketEngine {
  static MarketConditions tick(GameState state, SimRng rng) {
    var m = state.market;
    final cycleDrift = 0.02 * (rng.nextDouble() - 0.45);
    final cycles = <Location, double>{};
    for (final loc in Location.values) {
      final cur = m.propertyCycle[loc] ?? 1.0;
      cycles[loc] = (cur * (1 + cycleDrift + rng.range(-0.015, 0.015)))
          .clamp(0.72, 1.38);
    }

    var rates = m.interestRate + rng.range(-0.0015, 0.0018);
    var inflation = m.inflation + rng.range(-0.002, 0.002);
    var fx = m.eurThb * (1 + rng.range(-0.02, 0.02));
    var tourism = m.tourismDemand + rng.range(-0.03, 0.03);
    var politics = m.politicalRisk + rng.range(-0.02, 0.02);
    var build = m.constructionCostIndex * (1 + m.inflation / 4 + rng.range(-0.01, 0.02));
    var reg = m.regulatoryTightness + rng.range(-0.02, 0.02);
    var credit = m.creditAvailability + rng.range(-0.03, 0.03);

    // Seasonal: Q4 and Q1 stronger for beaches.
    if (state.quarter == 4 || state.quarter == 1) {
      tourism += 0.03;
    } else if (state.quarter == 3) {
      tourism -= 0.04;
    }

    for (final e in state.activeEffects) {
      if (e.tags.contains('tourism_up')) tourism += 0.08;
      if (e.tags.contains('tourism_down')) tourism -= 0.10;
      if (e.tags.contains('rates_up')) rates += 0.006;
      if (e.tags.contains('recession')) {
        rates += 0.004;
        tourism -= 0.08;
        credit -= 0.18;
        for (final loc in Location.values) {
          cycles[loc] = (cycles[loc]! * 0.97).clamp(0.72, 1.38);
        }
      }
      if (e.tags.contains('fx_calm')) {
        fx = fx * 0.4 + m.eurThb * 0.6;
      }
      if (e.tags.contains('regulation')) reg += 0.08;
      if (e.tags.contains('build_cost_up')) build *= 1.03;
      if (e.tags.contains('phuket_up')) {
        cycles[Location.phuket] = (cycles[Location.phuket]! * 1.02).clamp(0.72, 1.38);
      }
      if (e.tags.contains('bangkok_up')) {
        cycles[Location.bangkok] =
            (cycles[Location.bangkok]! * 1.015).clamp(0.72, 1.38);
      }
      if (e.tags.contains('pattaya_up')) {
        cycles[Location.pattaya] =
            (cycles[Location.pattaya]! * 1.02).clamp(0.72, 1.38);
      }
      if (e.tags.contains('flood') && e.location != null) {
        cycles[e.location!] = (cycles[e.location!]! * 0.96).clamp(0.72, 1.38);
      }
    }

    return m.copyWith(
      interestRate: rates.clamp(0.015, 0.09),
      inflation: inflation.clamp(0.0, 0.08),
      eurThb: fx.clamp(32, 48),
      tourismDemand: tourism.clamp(0.55, 1.45),
      politicalRisk: politics.clamp(0.05, 0.75),
      constructionCostIndex: build.clamp(0.85, 2.2),
      regulatoryTightness: reg.clamp(0.1, 0.85),
      propertyCycle: cycles,
      creditAvailability: credit.clamp(0.35, 1.2),
    );
  }
}
