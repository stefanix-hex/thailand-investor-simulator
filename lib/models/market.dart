import 'enums.dart';

class MarketConditions {
  const MarketConditions({
    required this.interestRate,
    required this.inflation,
    required this.eurThb,
    required this.tourismDemand,
    required this.politicalRisk,
    required this.constructionCostIndex,
    required this.regulatoryTightness,
    required this.propertyCycle,
    this.creditAvailability = 1.0,
  });

  /// Annual policy-like rate, e.g. 0.035.
  final double interestRate;
  final double inflation;
  final double eurThb;
  final double tourismDemand;
  final double politicalRisk;
  final double constructionCostIndex;
  final double regulatoryTightness;
  final Map<Location, double> propertyCycle;
  final double creditAvailability;

  factory MarketConditions.initial() {
    return MarketConditions(
      interestRate: 0.032,
      inflation: 0.022,
      eurThb: 38.4,
      tourismDemand: 1.0,
      politicalRisk: 0.22,
      constructionCostIndex: 1.0,
      regulatoryTightness: 0.35,
      creditAvailability: 1.0,
      propertyCycle: {
        for (final loc in Location.values) loc: 1.0,
      },
    );
  }

  MarketConditions copyWith({
    double? interestRate,
    double? inflation,
    double? eurThb,
    double? tourismDemand,
    double? politicalRisk,
    double? constructionCostIndex,
    double? regulatoryTightness,
    Map<Location, double>? propertyCycle,
    double? creditAvailability,
  }) {
    return MarketConditions(
      interestRate: interestRate ?? this.interestRate,
      inflation: inflation ?? this.inflation,
      eurThb: eurThb ?? this.eurThb,
      tourismDemand: tourismDemand ?? this.tourismDemand,
      politicalRisk: politicalRisk ?? this.politicalRisk,
      constructionCostIndex: constructionCostIndex ?? this.constructionCostIndex,
      regulatoryTightness: regulatoryTightness ?? this.regulatoryTightness,
      propertyCycle: propertyCycle ?? Map.of(this.propertyCycle),
      creditAvailability: creditAvailability ?? this.creditAvailability,
    );
  }

  Map<String, dynamic> toJson() => {
        'interestRate': interestRate,
        'inflation': inflation,
        'eurThb': eurThb,
        'tourismDemand': tourismDemand,
        'politicalRisk': politicalRisk,
        'constructionCostIndex': constructionCostIndex,
        'regulatoryTightness': regulatoryTightness,
        'creditAvailability': creditAvailability,
        'propertyCycle': {
          for (final e in propertyCycle.entries) e.key.name: e.value,
        },
      };

  factory MarketConditions.fromJson(Map<String, dynamic> json) {
    final raw = Map<String, dynamic>.from(json['propertyCycle'] as Map);
    return MarketConditions(
      interestRate: (json['interestRate'] as num).toDouble(),
      inflation: (json['inflation'] as num).toDouble(),
      eurThb: (json['eurThb'] as num).toDouble(),
      tourismDemand: (json['tourismDemand'] as num).toDouble(),
      politicalRisk: (json['politicalRisk'] as num).toDouble(),
      constructionCostIndex: (json['constructionCostIndex'] as num).toDouble(),
      regulatoryTightness: (json['regulatoryTightness'] as num).toDouble(),
      creditAvailability: (json['creditAvailability'] as num?)?.toDouble() ?? 1,
      propertyCycle: {
        for (final loc in Location.values)
          loc: (raw[loc.name] as num?)?.toDouble() ?? 1.0,
      },
    );
  }
}

class MarketEvent {
  const MarketEvent({
    required this.id,
    required this.title,
    required this.body,
    required this.tone,
    required this.quartersRemaining,
    this.location,
    this.tags = const [],
  });

  final String id;
  final String title;
  final String body;
  final EventTone tone;
  final int quartersRemaining;
  final Location? location;
  final List<String> tags;

  MarketEvent copyWith({int? quartersRemaining}) {
    return MarketEvent(
      id: id,
      title: title,
      body: body,
      tone: tone,
      quartersRemaining: quartersRemaining ?? this.quartersRemaining,
      location: location,
      tags: tags,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'tone': tone.name,
        'quartersRemaining': quartersRemaining,
        'location': location?.name,
        'tags': tags,
      };

  factory MarketEvent.fromJson(Map<String, dynamic> json) {
    return MarketEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      tone: EventTone.values.byName(json['tone'] as String),
      quartersRemaining: json['quartersRemaining'] as int,
      location: json['location'] == null
          ? null
          : Location.values.byName(json['location'] as String),
      tags: List<String>.from(json['tags'] as List? ?? const []),
    );
  }
}
