import 'enums.dart';

class Investor {
  const Investor({
    required this.id,
    required this.name,
    required this.quality,
    required this.conflictProne,
  });

  final String id;
  final String name;
  /// 0-1. Higher is more reliable.
  final double quality;
  final bool conflictProne;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quality': quality,
        'conflictProne': conflictProne,
      };

  factory Investor.fromJson(Map<String, dynamic> json) => Investor(
        id: json['id'] as String,
        name: json['name'] as String,
        quality: (json['quality'] as num).toDouble(),
        conflictProne: json['conflictProne'] as bool,
      );
}

class Loan {
  const Loan({
    required this.id,
    required this.assetId,
    required this.kind,
    required this.principal,
    required this.annualRate,
    required this.remainingQuarters,
    required this.originalPrincipal,
    this.interestOnly = false,
  });

  final String id;
  final String assetId;
  final LoanKind kind;
  final double principal;
  final double annualRate;
  final int remainingQuarters;
  final double originalPrincipal;
  final bool interestOnly;

  double get quarterlyRate => annualRate / 4;

  double get quarterlyPayment {
    if (principal <= 0) return 0;
    if (interestOnly || remainingQuarters <= 0) {
      return principal * quarterlyRate;
    }
    final r = quarterlyRate;
    if (r == 0) return principal / remainingQuarters;
    final pow = _pow(1 + r, remainingQuarters);
    return principal * r * pow / (pow - 1);
  }

  Loan copyWith({
    double? principal,
    int? remainingQuarters,
  }) {
    return Loan(
      id: id,
      assetId: assetId,
      kind: kind,
      principal: principal ?? this.principal,
      annualRate: annualRate,
      remainingQuarters: remainingQuarters ?? this.remainingQuarters,
      originalPrincipal: originalPrincipal,
      interestOnly: interestOnly,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'assetId': assetId,
        'kind': kind.name,
        'principal': principal,
        'annualRate': annualRate,
        'remainingQuarters': remainingQuarters,
        'originalPrincipal': originalPrincipal,
        'interestOnly': interestOnly,
      };

  factory Loan.fromJson(Map<String, dynamic> json) => Loan(
        id: json['id'] as String,
        assetId: json['assetId'] as String,
        kind: LoanKind.values.byName(json['kind'] as String),
        principal: (json['principal'] as num).toDouble(),
        annualRate: (json['annualRate'] as num).toDouble(),
        remainingQuarters: json['remainingQuarters'] as int,
        originalPrincipal: (json['originalPrincipal'] as num).toDouble(),
        interestOnly: json['interestOnly'] as bool? ?? false,
      );
}

class BankDecision {
  const BankDecision({
    required this.approved,
    required this.reason,
    this.maxLtv = 0,
    this.offeredRate = 0,
    this.offeredPrincipal = 0,
    this.termQuarters = 0,
  });

  final bool approved;
  final String reason;
  final double maxLtv;
  final double offeredRate;
  final double offeredPrincipal;
  final int termQuarters;
}

double _pow(double x, int n) {
  var r = 1.0;
  for (var i = 0; i < n; i++) {
    r *= x;
  }
  return r;
}
