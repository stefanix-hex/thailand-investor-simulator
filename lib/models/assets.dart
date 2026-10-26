import 'enums.dart';
import 'finance.dart';

class RealEstateAsset {
  const RealEstateAsset({
    required this.id,
    required this.name,
    required this.kind,
    required this.location,
    required this.ownership,
    required this.purchasePrice,
    required this.currentValue,
    required this.acquiredTurn,
    required this.occupancy,
    required this.grossYield,
    required this.opexRatio,
    required this.riskScore,
    required this.riskLevel,
    this.adr = 0,
    this.rooms = 0,
    this.leaseQuartersRemaining = 0,
    this.equityShare = 1,
    this.votingShare = 1,
    this.partner,
    this.isDevelopment = false,
    this.constructionQuartersRemaining = 0,
    this.permitBlocked = false,
    this.failed = false,
    this.failReason,
    this.disputeActive = false,
    this.notes = const [],
  });

  final String id;
  final String name;
  final PropertyKind kind;
  final Location location;
  final OwnershipStructure ownership;
  final double purchasePrice;
  final double currentValue;
  final int acquiredTurn;
  final double occupancy;
  final double grossYield;
  final double opexRatio;
  final double riskScore;
  final RiskLevel riskLevel;
  final double adr;
  final int rooms;
  final int leaseQuartersRemaining;
  final double equityShare;
  final double votingShare;
  final Investor? partner;
  final bool isDevelopment;
  final int constructionQuartersRemaining;
  final bool permitBlocked;
  final bool failed;
  final String? failReason;
  final bool disputeActive;
  final List<String> notes;

  bool get producesIncome =>
      !failed && !isDevelopment && !permitBlocked && !disputeActive;

  bool get isHospitality =>
      kind == PropertyKind.hotel || kind == PropertyKind.resort;

  double get playerValue => currentValue * equityShare;

  RealEstateAsset copyWith({
    double? currentValue,
    double? occupancy,
    double? adr,
    double? grossYield,
    int? leaseQuartersRemaining,
    int? constructionQuartersRemaining,
    bool? permitBlocked,
    bool? failed,
    String? failReason,
    bool? disputeActive,
    bool? isDevelopment,
    double? riskScore,
    RiskLevel? riskLevel,
    List<String>? notes,
  }) {
    return RealEstateAsset(
      id: id,
      name: name,
      kind: kind,
      location: location,
      ownership: ownership,
      purchasePrice: purchasePrice,
      currentValue: currentValue ?? this.currentValue,
      acquiredTurn: acquiredTurn,
      occupancy: occupancy ?? this.occupancy,
      grossYield: grossYield ?? this.grossYield,
      opexRatio: opexRatio,
      riskScore: riskScore ?? this.riskScore,
      riskLevel: riskLevel ?? this.riskLevel,
      adr: adr ?? this.adr,
      rooms: rooms,
      leaseQuartersRemaining:
          leaseQuartersRemaining ?? this.leaseQuartersRemaining,
      equityShare: equityShare,
      votingShare: votingShare,
      partner: partner,
      isDevelopment: isDevelopment ?? this.isDevelopment,
      constructionQuartersRemaining: constructionQuartersRemaining ??
          this.constructionQuartersRemaining,
      permitBlocked: permitBlocked ?? this.permitBlocked,
      failed: failed ?? this.failed,
      failReason: failReason ?? this.failReason,
      disputeActive: disputeActive ?? this.disputeActive,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'kind': kind.name,
        'location': location.name,
        'ownership': ownership.name,
        'purchasePrice': purchasePrice,
        'currentValue': currentValue,
        'acquiredTurn': acquiredTurn,
        'occupancy': occupancy,
        'grossYield': grossYield,
        'opexRatio': opexRatio,
        'riskScore': riskScore,
        'riskLevel': riskLevel.name,
        'adr': adr,
        'rooms': rooms,
        'leaseQuartersRemaining': leaseQuartersRemaining,
        'equityShare': equityShare,
        'votingShare': votingShare,
        'partner': partner?.toJson(),
        'isDevelopment': isDevelopment,
        'constructionQuartersRemaining': constructionQuartersRemaining,
        'permitBlocked': permitBlocked,
        'failed': failed,
        'failReason': failReason,
        'disputeActive': disputeActive,
        'notes': notes,
      };

  factory RealEstateAsset.fromJson(Map<String, dynamic> json) =>
      RealEstateAsset(
        id: json['id'] as String,
        name: json['name'] as String,
        kind: PropertyKind.values.byName(json['kind'] as String),
        location: Location.values.byName(json['location'] as String),
        ownership:
            OwnershipStructure.values.byName(json['ownership'] as String),
        purchasePrice: (json['purchasePrice'] as num).toDouble(),
        currentValue: (json['currentValue'] as num).toDouble(),
        acquiredTurn: json['acquiredTurn'] as int,
        occupancy: (json['occupancy'] as num).toDouble(),
        grossYield: (json['grossYield'] as num).toDouble(),
        opexRatio: (json['opexRatio'] as num).toDouble(),
        riskScore: (json['riskScore'] as num).toDouble(),
        riskLevel: RiskLevel.values.byName(json['riskLevel'] as String),
        adr: (json['adr'] as num?)?.toDouble() ?? 0,
        rooms: json['rooms'] as int? ?? 0,
        leaseQuartersRemaining: json['leaseQuartersRemaining'] as int? ?? 0,
        equityShare: (json['equityShare'] as num?)?.toDouble() ?? 1,
        votingShare: (json['votingShare'] as num?)?.toDouble() ?? 1,
        partner: json['partner'] == null
            ? null
            : Investor.fromJson(Map<String, dynamic>.from(json['partner'] as Map)),
        isDevelopment: json['isDevelopment'] as bool? ?? false,
        constructionQuartersRemaining:
            json['constructionQuartersRemaining'] as int? ?? 0,
        permitBlocked: json['permitBlocked'] as bool? ?? false,
        failed: json['failed'] as bool? ?? false,
        failReason: json['failReason'] as String?,
        disputeActive: json['disputeActive'] as bool? ?? false,
        notes: List<String>.from(json['notes'] as List? ?? const []),
      );
}

class BusinessAsset {
  const BusinessAsset({
    required this.id,
    required this.name,
    required this.kind,
    required this.location,
    required this.purchasePrice,
    required this.currentValue,
    required this.acquiredTurn,
    required this.revenueRunRate,
    required this.margin,
    required this.riskScore,
    required this.riskLevel,
    this.equityShare = 1,
    this.partner,
    this.failed = false,
    this.failReason,
    this.disputeActive = false,
    this.notes = const [],
  });

  final String id;
  final String name;
  final BusinessKind kind;
  final Location location;
  final double purchasePrice;
  final double currentValue;
  final int acquiredTurn;
  final double revenueRunRate;
  final double margin;
  final double riskScore;
  final RiskLevel riskLevel;
  final double equityShare;
  final Investor? partner;
  final bool failed;
  final String? failReason;
  final bool disputeActive;
  final List<String> notes;

  bool get producesIncome => !failed && !disputeActive;

  double get playerValue => currentValue * equityShare;

  BusinessAsset copyWith({
    double? currentValue,
    double? revenueRunRate,
    double? margin,
    bool? failed,
    String? failReason,
    bool? disputeActive,
    double? riskScore,
    RiskLevel? riskLevel,
    List<String>? notes,
  }) {
    return BusinessAsset(
      id: id,
      name: name,
      kind: kind,
      location: location,
      purchasePrice: purchasePrice,
      currentValue: currentValue ?? this.currentValue,
      acquiredTurn: acquiredTurn,
      revenueRunRate: revenueRunRate ?? this.revenueRunRate,
      margin: margin ?? this.margin,
      riskScore: riskScore ?? this.riskScore,
      riskLevel: riskLevel ?? this.riskLevel,
      equityShare: equityShare,
      partner: partner,
      failed: failed ?? this.failed,
      failReason: failReason ?? this.failReason,
      disputeActive: disputeActive ?? this.disputeActive,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'kind': kind.name,
        'location': location.name,
        'purchasePrice': purchasePrice,
        'currentValue': currentValue,
        'acquiredTurn': acquiredTurn,
        'revenueRunRate': revenueRunRate,
        'margin': margin,
        'riskScore': riskScore,
        'riskLevel': riskLevel.name,
        'equityShare': equityShare,
        'partner': partner?.toJson(),
        'failed': failed,
        'failReason': failReason,
        'disputeActive': disputeActive,
        'notes': notes,
      };

  factory BusinessAsset.fromJson(Map<String, dynamic> json) => BusinessAsset(
        id: json['id'] as String,
        name: json['name'] as String,
        kind: BusinessKind.values.byName(json['kind'] as String),
        location: Location.values.byName(json['location'] as String),
        purchasePrice: (json['purchasePrice'] as num).toDouble(),
        currentValue: (json['currentValue'] as num).toDouble(),
        acquiredTurn: json['acquiredTurn'] as int,
        revenueRunRate: (json['revenueRunRate'] as num).toDouble(),
        margin: (json['margin'] as num).toDouble(),
        riskScore: (json['riskScore'] as num).toDouble(),
        riskLevel: RiskLevel.values.byName(json['riskLevel'] as String),
        equityShare: (json['equityShare'] as num?)?.toDouble() ?? 1,
        partner: json['partner'] == null
            ? null
            : Investor.fromJson(Map<String, dynamic>.from(json['partner'] as Map)),
        failed: json['failed'] as bool? ?? false,
        failReason: json['failReason'] as String?,
        disputeActive: json['disputeActive'] as bool? ?? false,
        notes: List<String>.from(json['notes'] as List? ?? const []),
      );
}

class SecurityHolding {
  const SecurityHolding({
    required this.id,
    required this.kind,
    required this.name,
    required this.unitsCost,
    required this.marketValue,
    required this.dividendYield,
    required this.acquiredTurn,
  });

  final String id;
  final SecurityKind kind;
  final String name;
  final double unitsCost;
  final double marketValue;
  final double dividendYield;
  final int acquiredTurn;

  SecurityHolding copyWith({double? marketValue, double? dividendYield}) {
    return SecurityHolding(
      id: id,
      kind: kind,
      name: name,
      unitsCost: unitsCost,
      marketValue: marketValue ?? this.marketValue,
      dividendYield: dividendYield ?? this.dividendYield,
      acquiredTurn: acquiredTurn,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'name': name,
        'unitsCost': unitsCost,
        'marketValue': marketValue,
        'dividendYield': dividendYield,
        'acquiredTurn': acquiredTurn,
      };

  factory SecurityHolding.fromJson(Map<String, dynamic> json) =>
      SecurityHolding(
        id: json['id'] as String,
        kind: SecurityKind.values.byName(json['kind'] as String),
        name: json['name'] as String,
        unitsCost: (json['unitsCost'] as num).toDouble(),
        marketValue: (json['marketValue'] as num).toDouble(),
        dividendYield: (json['dividendYield'] as num).toDouble(),
        acquiredTurn: json['acquiredTurn'] as int,
      );
}
