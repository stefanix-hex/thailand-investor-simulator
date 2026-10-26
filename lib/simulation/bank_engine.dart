import '../models/enums.dart';
import '../models/finance.dart';
import '../models/game_state.dart';
import '../models/opportunity.dart';
import 'financial_calculator.dart';
import 'rng.dart';

class BankEngine {
  static BankDecision review({
    required GameState state,
    required Opportunity opportunity,
    required double requested,
    required SimRng rng,
  }) {
    final m = FinancialCalculator.compute(state);
    final price = opportunity.askingPrice;
    final afterLtv = price <= 0 ? 1.0 : requested / price;
    var maxLtv = 0.65;
    if (opportunity.kind == OpportunityKind.business) maxLtv = 0.50;
    if (opportunity.kind == OpportunityKind.security) {
      return const BankDecision(
        approved: false,
        reason: 'Securities are cash purchases. Banks will not leverage them here.',
      );
    }
    if (opportunity.propertyKind == PropertyKind.hotel ||
        opportunity.propertyKind == PropertyKind.resort) {
      maxLtv = 0.55;
    }
    if (opportunity.ownershipOptions.contains(OwnershipStructure.spv)) {
      maxLtv += 0.05;
    }
    maxLtv *= state.market.creditAvailability.clamp(0.7, 1.05);
    if (state.market.regulatoryTightness > 0.6) maxLtv -= 0.08;

    final projectedNoi = _projectedQuarterly(opportunity);
    final rate = state.market.interestRate +
        0.018 +
        (opportunity.riskScore * 0.03) +
        (m.ltv > 0.5 ? 0.01 : 0);
    final term = opportunity.kind == OpportunityKind.business ? 20 : 40;
    final trial = Loan(
      id: 'trial',
      assetId: opportunity.id,
      kind: LoanKind.mortgage,
      principal: requested,
      annualRate: rate,
      remainingQuarters: term,
      originalPrincipal: requested,
    );
    final newDs = m.quarterlyDebtService + trial.quarterlyPayment;
    final newDscr = newDs <= 0 ? 99.0 : (m.quarterlyNoi + projectedNoi) / newDs;
    final cashAfter = state.cash - (price - requested);
    final minDscr = state.market.creditAvailability < 0.7 ? 1.45 : 1.25;

    if (requested <= 0) {
      return const BankDecision(approved: false, reason: 'No amount requested.');
    }
    if (afterLtv > maxLtv + 0.001) {
      return BankDecision(
        approved: false,
        reason:
            'LTV ${(afterLtv * 100).toStringAsFixed(0)}% exceeds bank cap ${(maxLtv * 100).toStringAsFixed(0)}% given asset type and credit conditions.',
        maxLtv: maxLtv,
      );
    }
    if (newDscr < minDscr) {
      return BankDecision(
        approved: false,
        reason:
            'Projected DSCR ${newDscr.toStringAsFixed(2)} is below the credit committee floor of ${minDscr.toStringAsFixed(2)}.',
        maxLtv: maxLtv,
        offeredRate: rate,
      );
    }
    if (cashAfter < price * 0.08) {
      return BankDecision(
        approved: false,
        reason:
            'Cash reserves after completion would be too thin. Banks require a liquidity buffer.',
        maxLtv: maxLtv,
      );
    }
    if (m.ltv > 0.72) {
      return const BankDecision(
        approved: false,
        reason: 'Existing leverage is already elevated. Delever before new credit.',
      );
    }
    if (state.market.politicalRisk > 0.6 && rng.chance(0.45)) {
      return const BankDecision(
        approved: false,
        reason: 'Credit committee delayed the file on political-risk grounds.',
      );
    }

    // Never automatic: residual underwriting noise.
    final rejectP = 0.08 + opportunity.riskScore * 0.18 + (1 - state.market.creditAvailability) * 0.2;
    if (rng.chance(rejectP)) {
      return BankDecision(
        approved: false,
        reason:
            'Declined after qualitative review (sponsor experience, asset complexity, or market timing).',
        maxLtv: maxLtv,
        offeredRate: rate,
      );
    }

    return BankDecision(
      approved: true,
      reason: 'Approved subject to first-ranking security and standard covenants.',
      maxLtv: maxLtv,
      offeredRate: rate,
      offeredPrincipal: requested,
      termQuarters: term,
    );
  }

  static double _projectedQuarterly(Opportunity o) {
    if (o.kind == OpportunityKind.realEstate) {
      if (o.isDevelopment) return 0;
      final gross = o.askingPrice * o.grossYield * o.occupancy / 4;
      return (gross - gross * o.opexRatio) * o.equityShare;
    }
    if (o.kind == OpportunityKind.business) {
      return o.revenueRunRate * o.margin / 4 * o.equityShare;
    }
    return o.askingPrice * o.dividendYield / 4;
  }
}
