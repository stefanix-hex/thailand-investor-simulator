import 'assets.dart';
import 'enums.dart';
import 'finance.dart';
import 'market.dart';
import 'opportunity.dart';

class GameState {
  const GameState({
    required this.seed,
    required this.rngState,
    required this.year,
    required this.quarter,
    required this.cash,
    required this.properties,
    required this.businesses,
    required this.securities,
    required this.loans,
    required this.market,
    required this.opportunities,
    required this.eventHistory,
    required this.activeEffects,
    required this.decisions,
    required this.log,
    required this.netWorthHistory,
    required this.yearEndNetWorth,
    required this.phase,
    this.currentEvent,
    this.report,
    this.lastLoanDecision,
    this.forcedStressApplied = false,
    this.sawFailedInvestment = false,
    this.sawDelay = false,
    this.sawPermitIssue = false,
    this.sawDispute = false,
    this.sawDownturn = false,
  });

  final int seed;
  final int rngState;
  final int year;
  final int quarter;
  final double cash;
  final List<RealEstateAsset> properties;
  final List<BusinessAsset> businesses;
  final List<SecurityHolding> securities;
  final List<Loan> loans;
  final MarketConditions market;
  final List<Opportunity> opportunities;
  final List<MarketEvent> eventHistory;
  final List<MarketEvent> activeEffects;
  final List<DecisionRecord> decisions;
  final List<String> log;
  final List<double> netWorthHistory;
  final Map<int, double> yearEndNetWorth;
  final GamePhase phase;
  final MarketEvent? currentEvent;
  final EndGameReport? report;
  final BankDecision? lastLoanDecision;
  final bool forcedStressApplied;
  final bool sawFailedInvestment;
  final bool sawDelay;
  final bool sawPermitIssue;
  final bool sawDispute;
  final bool sawDownturn;

  int get turn => (year - 1) * 4 + quarter;
  bool get isFinalQuarter => year == 20 && quarter == 4;
  String get periodLabel => 'Year $year  ·  Q$quarter';

  factory GameState.titleScreen() {
    return GameState(
      seed: 0,
      rngState: 0,
      year: 1,
      quarter: 1,
      cash: 200000,
      properties: const [],
      businesses: const [],
      securities: const [],
      loans: const [],
      market: MarketConditions.initial(),
      opportunities: const [],
      eventHistory: const [],
      activeEffects: const [],
      decisions: const [],
      log: const [],
      netWorthHistory: const [200000],
      yearEndNetWorth: const {},
      phase: GamePhase.title,
    );
  }

  factory GameState.newCampaign({int seed = 1}) {
    return GameState(
      seed: seed,
      rngState: seed,
      year: 1,
      quarter: 1,
      cash: 200000,
      properties: const [],
      businesses: const [],
      securities: const [],
      loans: const [],
      market: MarketConditions.initial(),
      opportunities: const [],
      eventHistory: const [],
      activeEffects: const [],
      decisions: const [],
      log: const [
        'Campaign opened with €200,000 cash and a clean balance sheet.',
      ],
      netWorthHistory: const [200000],
      yearEndNetWorth: const {},
      phase: GamePhase.playing,
    );
  }

  GameState copyWith({
    int? rngState,
    int? year,
    int? quarter,
    double? cash,
    List<RealEstateAsset>? properties,
    List<BusinessAsset>? businesses,
    List<SecurityHolding>? securities,
    List<Loan>? loans,
    MarketConditions? market,
    List<Opportunity>? opportunities,
    List<MarketEvent>? eventHistory,
    List<MarketEvent>? activeEffects,
    List<DecisionRecord>? decisions,
    List<String>? log,
    List<double>? netWorthHistory,
    Map<int, double>? yearEndNetWorth,
    GamePhase? phase,
    MarketEvent? currentEvent,
    bool clearEvent = false,
    EndGameReport? report,
    BankDecision? lastLoanDecision,
    bool clearLoanDecision = false,
    bool? forcedStressApplied,
    bool? sawFailedInvestment,
    bool? sawDelay,
    bool? sawPermitIssue,
    bool? sawDispute,
    bool? sawDownturn,
  }) {
    return GameState(
      seed: seed,
      rngState: rngState ?? this.rngState,
      year: year ?? this.year,
      quarter: quarter ?? this.quarter,
      cash: cash ?? this.cash,
      properties: properties ?? this.properties,
      businesses: businesses ?? this.businesses,
      securities: securities ?? this.securities,
      loans: loans ?? this.loans,
      market: market ?? this.market,
      opportunities: opportunities ?? this.opportunities,
      eventHistory: eventHistory ?? this.eventHistory,
      activeEffects: activeEffects ?? this.activeEffects,
      decisions: decisions ?? this.decisions,
      log: log ?? this.log,
      netWorthHistory: netWorthHistory ?? this.netWorthHistory,
      yearEndNetWorth: yearEndNetWorth ?? this.yearEndNetWorth,
      phase: phase ?? this.phase,
      currentEvent: clearEvent ? null : (currentEvent ?? this.currentEvent),
      report: report ?? this.report,
      lastLoanDecision:
          clearLoanDecision ? null : (lastLoanDecision ?? this.lastLoanDecision),
      forcedStressApplied: forcedStressApplied ?? this.forcedStressApplied,
      sawFailedInvestment: sawFailedInvestment ?? this.sawFailedInvestment,
      sawDelay: sawDelay ?? this.sawDelay,
      sawPermitIssue: sawPermitIssue ?? this.sawPermitIssue,
      sawDispute: sawDispute ?? this.sawDispute,
      sawDownturn: sawDownturn ?? this.sawDownturn,
    );
  }

  Map<String, dynamic> toJson() => {
        'seed': seed,
        'rngState': rngState,
        'year': year,
        'quarter': quarter,
        'cash': cash,
        'properties': properties.map((e) => e.toJson()).toList(),
        'businesses': businesses.map((e) => e.toJson()).toList(),
        'securities': securities.map((e) => e.toJson()).toList(),
        'loans': loans.map((e) => e.toJson()).toList(),
        'market': market.toJson(),
        'opportunities': opportunities.map((e) => e.toJson()).toList(),
        'eventHistory': eventHistory.map((e) => e.toJson()).toList(),
        'activeEffects': activeEffects.map((e) => e.toJson()).toList(),
        'decisions': decisions.map((e) => e.toJson()).toList(),
        'log': log,
        'netWorthHistory': netWorthHistory,
        'yearEndNetWorth': {
          for (final e in yearEndNetWorth.entries) '${e.key}': e.value,
        },
        'phase': phase.name,
        'currentEvent': currentEvent?.toJson(),
        'report': report?.toJson(),
        'forcedStressApplied': forcedStressApplied,
        'sawFailedInvestment': sawFailedInvestment,
        'sawDelay': sawDelay,
        'sawPermitIssue': sawPermitIssue,
        'sawDispute': sawDispute,
        'sawDownturn': sawDownturn,
      };

  factory GameState.fromJson(Map<String, dynamic> json) {
    final yearEnds = <int, double>{};
    final rawYears = Map<String, dynamic>.from(json['yearEndNetWorth'] as Map);
    for (final e in rawYears.entries) {
      yearEnds[int.parse(e.key)] = (e.value as num).toDouble();
    }
    return GameState(
      seed: json['seed'] as int,
      rngState: json['rngState'] as int,
      year: json['year'] as int,
      quarter: json['quarter'] as int,
      cash: (json['cash'] as num).toDouble(),
      properties: [
        for (final p in json['properties'] as List)
          RealEstateAsset.fromJson(Map<String, dynamic>.from(p as Map)),
      ],
      businesses: [
        for (final p in json['businesses'] as List)
          BusinessAsset.fromJson(Map<String, dynamic>.from(p as Map)),
      ],
      securities: [
        for (final p in json['securities'] as List)
          SecurityHolding.fromJson(Map<String, dynamic>.from(p as Map)),
      ],
      loans: [
        for (final p in json['loans'] as List)
          Loan.fromJson(Map<String, dynamic>.from(p as Map)),
      ],
      market: MarketConditions.fromJson(
        Map<String, dynamic>.from(json['market'] as Map),
      ),
      opportunities: [
        for (final p in json['opportunities'] as List)
          Opportunity.fromJson(Map<String, dynamic>.from(p as Map)),
      ],
      eventHistory: [
        for (final p in json['eventHistory'] as List)
          MarketEvent.fromJson(Map<String, dynamic>.from(p as Map)),
      ],
      activeEffects: [
        for (final p in json['activeEffects'] as List)
          MarketEvent.fromJson(Map<String, dynamic>.from(p as Map)),
      ],
      decisions: [
        for (final p in json['decisions'] as List)
          DecisionRecord.fromJson(Map<String, dynamic>.from(p as Map)),
      ],
      log: List<String>.from(json['log'] as List),
      netWorthHistory: [
        for (final n in json['netWorthHistory'] as List) (n as num).toDouble(),
      ],
      yearEndNetWorth: yearEnds,
      phase: GamePhase.values.byName(json['phase'] as String),
      currentEvent: json['currentEvent'] == null
          ? null
          : MarketEvent.fromJson(
              Map<String, dynamic>.from(json['currentEvent'] as Map),
            ),
      report: json['report'] == null
          ? null
          : EndGameReport.fromJson(
              Map<String, dynamic>.from(json['report'] as Map),
            ),
      forcedStressApplied: json['forcedStressApplied'] as bool? ?? false,
      sawFailedInvestment: json['sawFailedInvestment'] as bool? ?? false,
      sawDelay: json['sawDelay'] as bool? ?? false,
      sawPermitIssue: json['sawPermitIssue'] as bool? ?? false,
      sawDispute: json['sawDispute'] as bool? ?? false,
      sawDownturn: json['sawDownturn'] as bool? ?? false,
    );
  }
}
