import 'assets.dart';
import 'enums.dart';
import 'finance.dart';

enum OpportunityKind { realEstate, business, security }

class Opportunity {
  const Opportunity({
    required this.id,
    required this.kind,
    required this.title,
    required this.summary,
    required this.askingPrice,
    required this.location,
    required this.riskLevel,
    required this.riskScore,
    this.propertyKind,
    this.businessKind,
    this.securityKind,
    this.ownershipOptions = const [],
    this.grossYield = 0,
    this.opexRatio = 0.35,
    this.occupancy = 0.8,
    this.adr = 0,
    this.rooms = 0,
    this.margin = 0.12,
    this.revenueRunRate = 0,
    this.dividendYield = 0,
    this.isDevelopment = false,
    this.constructionQuarters = 0,
    this.partner,
    this.equityShare = 1,
    this.votingShare = 1,
  });

  final String id;
  final OpportunityKind kind;
  final String title;
  final String summary;
  final double askingPrice;
  final Location location;
  final RiskLevel riskLevel;
  final double riskScore;
  final PropertyKind? propertyKind;
  final BusinessKind? businessKind;
  final SecurityKind? securityKind;
  final List<OwnershipStructure> ownershipOptions;
  final double grossYield;
  final double opexRatio;
  final double occupancy;
  final double adr;
  final int rooms;
  final double margin;
  final double revenueRunRate;
  final double dividendYield;
  final bool isDevelopment;
  final int constructionQuarters;
  final Investor? partner;
  final double equityShare;
  final double votingShare;

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'title': title,
        'summary': summary,
        'askingPrice': askingPrice,
        'location': location.name,
        'riskLevel': riskLevel.name,
        'riskScore': riskScore,
        'propertyKind': propertyKind?.name,
        'businessKind': businessKind?.name,
        'securityKind': securityKind?.name,
        'ownershipOptions': ownershipOptions.map((e) => e.name).toList(),
        'grossYield': grossYield,
        'opexRatio': opexRatio,
        'occupancy': occupancy,
        'adr': adr,
        'rooms': rooms,
        'margin': margin,
        'revenueRunRate': revenueRunRate,
        'dividendYield': dividendYield,
        'isDevelopment': isDevelopment,
        'constructionQuarters': constructionQuarters,
        'partner': partner?.toJson(),
        'equityShare': equityShare,
        'votingShare': votingShare,
      };

  factory Opportunity.fromJson(Map<String, dynamic> json) => Opportunity(
        id: json['id'] as String,
        kind: OpportunityKind.values.byName(json['kind'] as String),
        title: json['title'] as String,
        summary: json['summary'] as String,
        askingPrice: (json['askingPrice'] as num).toDouble(),
        location: Location.values.byName(json['location'] as String),
        riskLevel: RiskLevel.values.byName(json['riskLevel'] as String),
        riskScore: (json['riskScore'] as num).toDouble(),
        propertyKind: json['propertyKind'] == null
            ? null
            : PropertyKind.values.byName(json['propertyKind'] as String),
        businessKind: json['businessKind'] == null
            ? null
            : BusinessKind.values.byName(json['businessKind'] as String),
        securityKind: json['securityKind'] == null
            ? null
            : SecurityKind.values.byName(json['securityKind'] as String),
        ownershipOptions: [
          for (final n in json['ownershipOptions'] as List? ?? const [])
            OwnershipStructure.values.byName(n as String),
        ],
        grossYield: (json['grossYield'] as num?)?.toDouble() ?? 0,
        opexRatio: (json['opexRatio'] as num?)?.toDouble() ?? 0.35,
        occupancy: (json['occupancy'] as num?)?.toDouble() ?? 0.8,
        adr: (json['adr'] as num?)?.toDouble() ?? 0,
        rooms: json['rooms'] as int? ?? 0,
        margin: (json['margin'] as num?)?.toDouble() ?? 0.12,
        revenueRunRate: (json['revenueRunRate'] as num?)?.toDouble() ?? 0,
        dividendYield: (json['dividendYield'] as num?)?.toDouble() ?? 0,
        isDevelopment: json['isDevelopment'] as bool? ?? false,
        constructionQuarters: json['constructionQuarters'] as int? ?? 0,
        partner: json['partner'] == null
            ? null
            : Investor.fromJson(Map<String, dynamic>.from(json['partner'] as Map)),
        equityShare: (json['equityShare'] as num?)?.toDouble() ?? 1,
        votingShare: (json['votingShare'] as num?)?.toDouble() ?? 1,
      );
}

class DecisionRecord {
  const DecisionRecord({
    required this.turn,
    required this.title,
    required this.detail,
  });

  final int turn;
  final String title;
  final String detail;

  Map<String, dynamic> toJson() => {
        'turn': turn,
        'title': title,
        'detail': detail,
      };

  factory DecisionRecord.fromJson(Map<String, dynamic> json) => DecisionRecord(
        turn: json['turn'] as int,
        title: json['title'] as String,
        detail: json['detail'] as String,
      );
}

class InvestmentResult {
  const InvestmentResult({
    required this.id,
    required this.name,
    required this.profit,
    required this.roi,
  });

  final String id;
  final String name;
  final double profit;
  final double roi;
}

class EndGameReport {
  const EndGameReport({
    required this.finalNetWorth,
    required this.finalPassiveIncome,
    required this.totalAssets,
    required this.remainingDebt,
    required this.bestInvestments,
    required this.worstInvestments,
    required this.majorDecisions,
    required this.portfolioNotes,
    required this.riskNotes,
    required this.decliningYears,
  });

  final double finalNetWorth;
  final double finalPassiveIncome;
  final double totalAssets;
  final double remainingDebt;
  final List<InvestmentResult> bestInvestments;
  final List<InvestmentResult> worstInvestments;
  final List<DecisionRecord> majorDecisions;
  final List<String> portfolioNotes;
  final List<String> riskNotes;
  final int decliningYears;

  Map<String, dynamic> toJson() => {
        'finalNetWorth': finalNetWorth,
        'finalPassiveIncome': finalPassiveIncome,
        'totalAssets': totalAssets,
        'remainingDebt': remainingDebt,
        'bestInvestments': [
          for (final i in bestInvestments)
            {'id': i.id, 'name': i.name, 'profit': i.profit, 'roi': i.roi},
        ],
        'worstInvestments': [
          for (final i in worstInvestments)
            {'id': i.id, 'name': i.name, 'profit': i.profit, 'roi': i.roi},
        ],
        'majorDecisions': majorDecisions.map((e) => e.toJson()).toList(),
        'portfolioNotes': portfolioNotes,
        'riskNotes': riskNotes,
        'decliningYears': decliningYears,
      };

  factory EndGameReport.fromJson(Map<String, dynamic> json) => EndGameReport(
        finalNetWorth: (json['finalNetWorth'] as num).toDouble(),
        finalPassiveIncome: (json['finalPassiveIncome'] as num).toDouble(),
        totalAssets: (json['totalAssets'] as num).toDouble(),
        remainingDebt: (json['remainingDebt'] as num).toDouble(),
        bestInvestments: [
          for (final i in json['bestInvestments'] as List)
            InvestmentResult(
              id: i['id'] as String,
              name: i['name'] as String,
              profit: (i['profit'] as num).toDouble(),
              roi: (i['roi'] as num).toDouble(),
            ),
        ],
        worstInvestments: [
          for (final i in json['worstInvestments'] as List)
            InvestmentResult(
              id: i['id'] as String,
              name: i['name'] as String,
              profit: (i['profit'] as num).toDouble(),
              roi: (i['roi'] as num).toDouble(),
            ),
        ],
        majorDecisions: [
          for (final d in json['majorDecisions'] as List)
            DecisionRecord.fromJson(Map<String, dynamic>.from(d as Map)),
        ],
        portfolioNotes: List<String>.from(json['portfolioNotes'] as List),
        riskNotes: List<String>.from(json['riskNotes'] as List),
        decliningYears: json['decliningYears'] as int? ?? 0,
      );
}
