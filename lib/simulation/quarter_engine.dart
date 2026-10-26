import '../data/catalogs.dart';
import '../models/assets.dart';
import '../models/enums.dart';
import '../models/finance.dart';
import '../models/game_state.dart';
import '../models/market.dart';
import '../models/opportunity.dart';
import 'bank_engine.dart';
import 'financial_calculator.dart';
import 'market_engine.dart';
import 'opportunity_engine.dart';
import 'rng.dart';
import 'risk_engine.dart';

class ActionResult {
  const ActionResult({required this.state, required this.message, this.ok = true});
  final GameState state;
  final String message;
  final bool ok;
}

class QuarterEngine {
  static GameState startCampaign({int? seed}) {
    final s = seed ?? DateTime.now().millisecondsSinceEpoch % 1000000;
    var state = GameState.newCampaign(seed: s);
    final rng = SimRng(state.rngState);
    state = _newQuarterContent(state, rng, opening: true);
    return state.copyWith(rngState: rng.state);
  }

  static GameState closeQuarter(GameState raw) {
    if (raw.phase != GamePhase.playing) return raw;
    final rng = SimRng(raw.rngState);
    var s = raw;
    final log = [...s.log];

    final income = FinancialCalculator.quarterlyNoi(s);
    s = s.copyWith(cash: FinancialCalculator.money(s.cash + income));
    log.add(_fmt(s, 'Portfolio income €${income.toStringAsFixed(0)} credited.'));

    // Insurance / legal baseline even with empty book.
   final overhead =
      s.properties.length * 120
    + s.businesses.length * 180
    + s.securities.length * 20;
    s = s.copyWith(cash: FinancialCalculator.money(s.cash - overhead));

    var loans = <Loan>[];
    var cash = s.cash;
    for (final loan in s.loans) {
      final pay = loan.quarterlyPayment;
      cash -= pay;
      var principal = loan.principal;
      if (!loan.interestOnly) {
        principal = (principal - (pay - principal * loan.quarterlyRate))
            .clamp(0, loan.principal);
      }
      final left = loan.remainingQuarters - 1;
      if (principal > 1 && left > 0) {
        loans.add(loan.copyWith(principal: principal, remainingQuarters: left));
      }
    }
    s = s.copyWith(cash: FinancialCalculator.money(cash), loans: loans);

    s = s.copyWith(market: MarketEngine.tick(s, rng));
    s = _applyPersistentEffects(s, rng, log);
    s = _updateValues(s, rng, log);
    s = _operateAssets(s, rng, log);

    if (s.cash < 0) {

s = _changeReputation(
  s,
  -2,
  'Negative cash balance',
);

      log.add(_fmt(s, 'Cash is negative. Emergency asset pressure is likely next quarter.'));
      s = _distress(s, rng, log);
    }

    final m = FinancialCalculator.compute(s);
    final history = [...s.netWorthHistory, m.netWorth];
    var yearEnds = Map<int, double>.from(s.yearEndNetWorth);
    var sawDown = s.sawDownturn;
    if (s.quarter == 4) {
      yearEnds[s.year] = m.netWorth;
      final prev = yearEnds[s.year - 1];
      if (prev != null && m.netWorth < prev) {
        sawDown = true;
        log.add(_fmt(s, 'Year ${s.year} closed with declining net worth.'));
      }
    }

    s = s.copyWith(
      log: log,
      netWorthHistory: history,
      yearEndNetWorth: yearEnds,
      sawDownturn: sawDown,
    );

    if (s.isFinalQuarter) {
      return _endGame(s);
    }

    var year = s.year;
    var quarter = s.quarter + 1;
    if (quarter > 4) {
      quarter = 1;
      year += 1;
    }
    s = s.copyWith(year: year, quarter: quarter, opportunities: const [], log: log);
    s = _newQuarterContent(s, rng, opening: false);
    s = _maybeForceStress(s, rng);
    return s.copyWith(rngState: rng.state);
  }

  static GameState _newQuarterContent(
    GameState s,
    SimRng rng, {
    required bool opening,
  }) {
    final event = _pickEvent(s, rng);
    final effects = [
      for (final e in s.activeEffects)
        if (e.quartersRemaining > 1) e.copyWith(quartersRemaining: e.quartersRemaining - 1),
      event,
    ];
    final opps = OpportunityEngine.generate(s, rng);
    final log = [
      ...s.log,
      if (!opening) _fmt(s, 'Market event: ${event.title}.'),
      if (opening) 'Q1 deal flow is on the table. Banks will underwrite, not rubber-stamp.',
    ];
    return s.copyWith(
      currentEvent: event,
      activeEffects: effects,
      eventHistory: [...s.eventHistory, event],
      opportunities: opps,
      log: log,
    );
  }

  static MarketEvent _pickEvent(GameState s, SimRng rng) {
    var pool = [...Catalogs.events];
    if (s.year >= 6 && !s.sawDownturn && !s.forcedStressApplied) {
      pool = pool.where((e) => e.tags.contains('recession')).toList();
    }
    final b = rng.pick(pool.isEmpty ? Catalogs.events : pool);
    return Catalogs.instantiate(b, '${s.turn}_${rng.nextInt(9999)}');
  }

  static GameState _maybeForceStress(GameState s, SimRng _) {
    final event = s.currentEvent;
    final isRecession = event?.tags.contains('recession') ?? false;
    if (!isRecession) return s;
    return s.copyWith(
      forcedStressApplied: s.year >= 6 ? true : s.forcedStressApplied,
      sawDownturn: true,
      market: s.market.copyWith(
        creditAvailability: (s.market.creditAvailability * 0.85).clamp(0.35, 1.2),
        tourismDemand: (s.market.tourismDemand * 0.9).clamp(0.55, 1.45),
        interestRate: (s.market.interestRate + 0.004).clamp(0.015, 0.09),
      ),
    );
  }
static GameState _changeReputation(
  GameState s,
  double delta,
  String reason,
) {
  final newRep = (s.reputation + delta).clamp(0.0, 100.0);

  return s.copyWith(
    reputation: newRep,
    reputationLastChange:
        '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(0)} • $reason',
  );
}
  static int _decliningYears(GameState s) {
    var n = 0;
    final keys = s.yearEndNetWorth.keys.toList()..sort();
    for (var i = 1; i < keys.length; i++) {
      final a = s.yearEndNetWorth[keys[i - 1]]!;
      final b = s.yearEndNetWorth[keys[i]]!;
      if (b < a) n++;
    }
    return n;
  }

  static GameState _applyPersistentEffects(
    GameState s,
    SimRng rng,
    List<String> log,
  ) {
    var props = [...s.properties];
    var biz = [...s.businesses];
    for (final e in s.activeEffects) {
      if (e.tags.contains('flood')) {
        props = [
          for (final p in props)
            if (e.location == null || p.location == e.location)
              p.copyWith(occupancy: (p.occupancy * 0.9).clamp(0.3, 0.98))
            else
              p,
        ];
      }
      if (e.tags.contains('tourism_down') || e.tags.contains('recession')) {
        props = [
          for (final p in props)
            p.copyWith(
              occupancy: (p.occupancy *
                      (p.isHospitality ? 0.94 : 0.98) *
                      s.market.tourismDemand.clamp(0.75, 1.05))
                  .clamp(0.35, 0.97),
            ),
        ];
        biz = [
          for (final b in biz)
            b.copyWith(
              revenueRunRate: b.revenueRunRate * 0.96,
              margin: (b.margin * 0.98).clamp(0.01, 0.4),
            ),
        ];
      }
      if (e.tags.contains('tourism_up')) {
        props = [
          for (final p in props)
            p.copyWith(occupancy: (p.occupancy * 1.03).clamp(0.4, 0.97)),
        ];
      }
      if (e.tags.contains('tax_cut')) {
        props = [
          for (final p in props)
            p.copyWith(grossYield: (p.grossYield * 1.01).clamp(0.02, 0.16)),
        ];
      }
      if (e.tags.contains('seasonal')) {
        final beachBoost = s.quarter == 4 || s.quarter == 1 ? 1.04 : 0.97;
        props = [
          for (final p in props)
            if (p.location == Location.phuket ||
                p.location == Location.samui ||
                p.location == Location.pattaya)
              p.copyWith(occupancy: (p.occupancy * beachBoost).clamp(0.35, 0.97))
            else
              p,
        ];
      }
    }
    return s.copyWith(properties: props, businesses: biz);
  }

  static GameState _updateValues(GameState s, SimRng rng, List<String> log) {
final fxAdj = (38.4 / s.market.eurThb).clamp(0.85, 1.15);
    var props = <RealEstateAsset>[];
    for (var p in s.properties) {
      if (p.failed) {
        props.add(p);
        continue;
      }
      final cycle = s.market.propertyCycle[p.location] ?? 1;
      var value = p.currentValue *
          (1 + s.market.inflation / 4) *
          (0.985 + cycle * 0.015) *
          (0.99 + rng.range(0, 0.02));
value *= (0.95 + 0.05 * fxAdj);      
if (p.ownership == OwnershipStructure.leasehold &&
          p.leaseQuartersRemaining > 0) {
        final frac = p.leaseQuartersRemaining / 120.0;
        value *= 0.55 + 0.45 * frac;
      }
      if (p.isDevelopment) {
        value *= 0.92 + rng.range(0, 0.06);
      }
      var leaseLeft = p.leaseQuartersRemaining;
      if (p.ownership == OwnershipStructure.leasehold) {
        leaseLeft = (leaseLeft - 1).clamp(0, 120);
        if (leaseLeft == 0 && rng.chance(0.7)) {
          log.add(_fmt(s, '${p.name}: lease expired without renewal. Write-down.'));
          value *= 0.2;
        }
      }
      props.add(p.copyWith(
        currentValue: FinancialCalculator.money(value),
        leaseQuartersRemaining: leaseLeft,
      ));
    }
    var secs = [
      for (final sec in s.securities)
        sec.copyWith(
          marketValue: FinancialCalculator.money(
            sec.marketValue *
                (1 + rng.range(-0.04, 0.045) + s.market.inflation / 8),
          ),
        ),
    ];
    var biz = [
      for (final b in s.businesses)
        b.failed
            ? b
            : b.copyWith(
                currentValue: FinancialCalculator.money(
                  b.currentValue *
                      (0.97 + rng.range(0, 0.05)) *
                      (0.85 + 0.15 * s.market.tourismDemand),
                ),
                revenueRunRate: b.revenueRunRate *
                    (0.98 + rng.range(0, 0.04)) *
                    (0.9 + 0.1 * s.market.tourismDemand),
              ),
    ];
    return s.copyWith(properties: props, businesses: biz, securities: secs);
  }

  static GameState _operateAssets(GameState s, SimRng rng, List<String> log) {
    var props = <RealEstateAsset>[];
    var sawFail = s.sawFailedInvestment;
    var sawDelay = s.sawDelay;
    var sawPermit = s.sawPermitIssue;
    var sawDispute = s.sawDispute;

    for (var p in s.properties) {
      if (p.failed) {
        props.add(p);
        continue;
      }
      var notes = [...p.notes];
      if (p.isDevelopment) {
        if (p.permitBlocked) {
          if (rng.chance(0.35)) {
            p = p.copyWith(permitBlocked: false);
            notes.add('Permit released.');
            log.add(_fmt(s, '${p.name}: permit issued after delay.'));
          }
        } else if (rng.chance(0.08 + s.market.regulatoryTightness * 0.12)) {
          p = p.copyWith(permitBlocked: true);
          sawPermit = true;
          notes.add('Permit issue.');
          log.add(_fmt(s, '${p.name}: permit issue halted construction.'));
        }
        if (!p.permitBlocked) {
          var left = p.constructionQuartersRemaining - 1;
          if (rng.chance(0.12 + (s.market.constructionCostIndex - 1).clamp(0, 1) * 0.2)) {
            left += 1;
            sawDelay = true;
            notes.add('Construction delay.');
            log.add(_fmt(s, '${p.name}: construction delay and cost pressure.'));
            p = p.copyWith(
              currentValue: FinancialCalculator.money(p.currentValue * 0.97),
            );
          }
          if (left <= 0) {
            p = p.copyWith(isDevelopment: false, constructionQuartersRemaining: 0);
            notes.add('Completed.');
            log.add(_fmt(s, '${p.name}: development completed and can lease.'));
          } else {
            p = p.copyWith(constructionQuartersRemaining: left);
          }
        }
      }

      if (p.partner != null &&
          (p.disputeActive ||
              (p.partner!.conflictProne && rng.chance(0.06 + (1 - p.partner!.quality) * 0.08)))) {
        if (!p.disputeActive) {
          sawDispute = true;
          notes.add('Investor dispute.');
          log.add(_fmt(s, '${p.name}: joint-venture dispute froze distributions.'));
          p = p.copyWith(disputeActive: true);
        } else if (rng.chance(0.3)) {
          notes.add('Dispute settled.');
          log.add(_fmt(s, '${p.name}: dispute settled. Operations resume.'));
          p = p.copyWith(disputeActive: false);
        }
      }

      final failP = p.riskScore * 0.012 + (p.isDevelopment ? 0.01 : 0);
      if (rng.chance(failP)) {
        sawFail = true;
        log.add(_fmt(s, '${p.name}: investment failed. Residual debt remains if any.'));
        p = p.copyWith(
          failed: true,
          failReason: 'Sponsor default / unsellable completion / total loss of thesis.',
          currentValue: FinancialCalculator.money(p.currentValue * 0.08),
          notes: [...notes, 'Failed investment.'],
        );
      } else {
        p = p.copyWith(notes: notes);
      }

      final score = RiskEngine.score(
        location: p.location,
        leverage: 0.4,
        market: s.market,
        development: p.isDevelopment,
        partnerQuality: p.partner?.quality ?? 1,
        ownership: p.ownership,
        hospitality: p.isHospitality,
      );
      p = p.copyWith(riskScore: score, riskLevel: RiskEngine.levelFor(score));
      props.add(p);
    }

    var biz = <BusinessAsset>[];
    for (var b in s.businesses) {
      if (b.failed) {
        biz.add(b);
        continue;
      }
      var notes = [...b.notes];
      if (b.partner != null && rng.chance(0.07 + (1 - b.partner!.quality) * 0.1)) {
        sawDispute = true;
        notes.add('Operator dispute.');
        log.add(_fmt(s, '${b.name}: operator dispute.'));
        b = b.copyWith(disputeActive: true, notes: notes);
      } else if (b.disputeActive && rng.chance(0.4)) {
        b = b.copyWith(disputeActive: false);
      }
      if (rng.chance(b.riskScore * 0.02)) {
        sawFail = true;
        log.add(_fmt(s, '${b.name}: business failed.'));
        b = b.copyWith(
          failed: true,
          failReason: 'Demand collapse or operator failure.',
          currentValue: FinancialCalculator.money(b.currentValue * 0.05),
        );
      }
      biz.add(b);
    }

    return s.copyWith(
      properties: props,
      businesses: biz,
      log: log,
      sawFailedInvestment: sawFail,
      sawDelay: sawDelay,
      sawPermitIssue: sawPermit,
      sawDispute: sawDispute,
    );
  }

  static GameState _distress(GameState s, SimRng rng, List<String> log) {
    if (s.properties.isEmpty && s.businesses.isEmpty && s.securities.isEmpty) {
      return s;
    }
    if (s.securities.isNotEmpty) {
      final sec = s.securities.first;
      log.add(_fmt(s, 'Forced sale of ${sec.name} to cover cash shortfall.'));
      final rest = s.securities.skip(1).toList();
      return s.copyWith(
        cash: FinancialCalculator.money(s.cash + sec.marketValue * 0.98),
        securities: rest,
      );
    }
    return s;
  }

  static GameState _endGame(GameState s) {
    final m = FinancialCalculator.compute(s);
    final results = <InvestmentResult>[];
    for (final p in s.properties) {
      final profit = p.playerValue - p.purchasePrice * p.equityShare;
      results.add(InvestmentResult(
        id: p.id,
        name: p.name,
        profit: profit,
        roi: p.purchasePrice == 0 ? 0 : profit / (p.purchasePrice * p.equityShare),
      ));
    }
    for (final b in s.businesses) {
      final profit = b.playerValue - b.purchasePrice * b.equityShare;
      results.add(InvestmentResult(
        id: b.id,
        name: b.name,
        profit: profit,
        roi: b.purchasePrice == 0 ? 0 : profit / (b.purchasePrice * b.equityShare),
      ));
    }
    for (final sec in s.securities) {
      final profit = sec.marketValue - sec.unitsCost;
      results.add(InvestmentResult(
        id: sec.id,
        name: sec.name,
        profit: profit,
        roi: sec.unitsCost == 0 ? 0 : profit / sec.unitsCost,
      ));
    }
    results.sort((a, b) => b.profit.compareTo(a.profit));
    final best = results.take(3).toList();
    final worst = results.reversed.take(3).toList();
    final notes = <String>[
      'Ended Year 20 Q4 with ${s.properties.length} properties, ${s.businesses.length} businesses, ${s.securities.length} financial lots.',
      'Passive income run-rate €${m.passiveIncome.toStringAsFixed(0)} / year.',
      if (_decliningYears(s) == 0)
        'Net worth never posted a down year — unusual, and likely luck on the cycle.'
      else
        '${_decliningYears(s)} calendar year(s) closed with lower net worth.',
    ];
    final risk = <String>[
      if (s.sawFailedInvestment) 'At least one investment failed outright.'
      else 'No total failures — still exposed to lease decay and credit.',
      if (s.sawDelay) 'Construction delays occurred.',
      if (s.sawPermitIssue) 'Permit issues interrupted a development.',
      if (s.sawDispute) 'Investor or operator disputes froze cash at least once.',
      if (s.sawDownturn) 'The book lived through an economic downturn.',
      'Ending LTV ${(m.ltv * 100).toStringAsFixed(0)}%, DSCR ${m.dscr.toStringAsFixed(2)}.',
    ];
    final report = EndGameReport(
      finalNetWorth: m.netWorth,
      finalPassiveIncome: m.passiveIncome,
      totalAssets: m.portfolioValue + s.cash,
      remainingDebt: m.debt,
      bestInvestments: best,
      worstInvestments: worst,
      majorDecisions: s.decisions.take(12).toList(),
      portfolioNotes: notes,
      riskNotes: risk,
      decliningYears: _decliningYears(s),
    );
    return s.copyWith(
      phase: GamePhase.ended,
      report: report,
      opportunities: const [],
      log: [...s.log, 'Campaign complete. No further turns.'],
    );
  }

  static ActionResult buy(
    GameState s,
    Opportunity o, {
    required OwnershipStructure ownership,
    required double loanAmount,
    BankDecision? preApproved,
  }) {
    if (s.phase != GamePhase.playing) {
      return ActionResult(state: s, message: 'The campaign has ended.', ok: false);
    }
    final rng = SimRng(s.rngState);
    BankDecision? decision = preApproved;
    if (loanAmount > 0) {
      decision = BankEngine.review(
        state: s,
        opportunity: o,
        requested: loanAmount,
        rng: rng,
      );
      if (!decision.approved) {
        return ActionResult(
          state: s.copyWith(rngState: rng.state, lastLoanDecision: decision),
          message: decision.reason,
          ok: false,
        );
      }
    }
    final down = o.askingPrice * o.equityShare - (decision?.offeredPrincipal ?? 0);
    if (s.cash + 0.01 < down) {
      return ActionResult(
        state: s.copyWith(rngState: rng.state),
        message: 'Not enough cash for the equity cheque (€${down.toStringAsFixed(0)}).',
        ok: false,
      );
    }

    var properties = [...s.properties];
    var businesses = [...s.businesses];
    var securities = [...s.securities];
    var loans = [...s.loans];
    String boughtId;

    if (o.kind == OpportunityKind.realEstate) {
      final asset = OpportunityEngine.toProperty(o, ownership, s.turn);
      properties.add(asset);
      boughtId = asset.id;
    } else if (o.kind == OpportunityKind.business) {
      final asset = OpportunityEngine.toBusiness(o, s.turn);
      businesses.add(asset);
      boughtId = asset.id;
    } else {
      final asset = OpportunityEngine.toSecurity(o, s.turn);
      securities.add(asset);
      boughtId = asset.id;
    }

    if (decision != null && decision.approved && decision.offeredPrincipal > 0) {
      loans.add(Loan(
        id: 'ln_${s.turn}_$boughtId',
        assetId: boughtId,
        kind: o.kind == OpportunityKind.business
            ? LoanKind.bankLoan
            : LoanKind.mortgage,
        principal: decision.offeredPrincipal,
        annualRate: decision.offeredRate,
        remainingQuarters: decision.termQuarters,
        originalPrincipal: decision.offeredPrincipal,
      ));
    }

    final opps = s.opportunities.where((e) => e.id != o.id).toList();
    final msg =
        'Acquired ${o.title} for €${o.askingPrice.toStringAsFixed(0)} (${ownership.label}).';
    final state = s.copyWith(
      cash: FinancialCalculator.money(s.cash - down),
      properties: properties,
      businesses: businesses,
      securities: securities,
      loans: loans,
      opportunities: opps,
      rngState: rng.state,
      lastLoanDecision: decision,
      clearLoanDecision: decision == null,
      decisions: [
        ...s.decisions,
        DecisionRecord(turn: s.turn, title: 'Bought ${o.title}', detail: msg),
      ],
      log: [...s.log, _fmt(s, msg)],
    );
    return ActionResult(state: state, message: msg);
  }

  static ActionResult sellAsset(GameState s, String id) {
    if (s.phase != GamePhase.playing) {
      return ActionResult(state: s, message: 'The campaign has ended.', ok: false);
    }
    final rng = SimRng(s.rngState);
    final spread = rng.range(0.92, 0.99);
    RealEstateAsset? p;
    BusinessAsset? b;
    SecurityHolding? sec;
    for (final x in s.properties) {
      if (x.id == id) p = x;
    }
    for (final x in s.businesses) {
      if (x.id == id) b = x;
    }
    for (final x in s.securities) {
      if (x.id == id) sec = x;
    }
    if (p == null && b == null && sec == null) {
      return ActionResult(state: s, message: 'Asset not found.', ok: false);
    }
    final value = p?.playerValue ?? b?.playerValue ?? sec!.marketValue;
    final proceeds = FinancialCalculator.money(value * spread);
    final leftoverLoans = s.loans.where((l) => l.assetId != id).toList();
    final due = s.loans.where((l) => l.assetId == id).fold<double>(0, (a, l) => a + l.principal);
    final name = p?.name ?? b?.name ?? sec!.name;
    final cash = FinancialCalculator.money(s.cash + proceeds - due);
    final msg =
        'Sold $name for €${proceeds.toStringAsFixed(0)}. Debt repaid €${due.toStringAsFixed(0)}.';
    return ActionResult(
      state: s.copyWith(
        cash: cash,
        properties: s.properties.where((e) => e.id != id).toList(),
        businesses: s.businesses.where((e) => e.id != id).toList(),
        securities: s.securities.where((e) => e.id != id).toList(),
        loans: leftoverLoans,
        rngState: rng.state,
        decisions: [
          ...s.decisions,
          DecisionRecord(turn: s.turn, title: 'Sold $name', detail: msg),
        ],
        log: [...s.log, _fmt(s, msg)],
      ),
      message: msg,
    );
  }

  static String _fmt(GameState s, String msg) => 'Y${s.year}Q${s.quarter} — $msg';
}
