import '../data/catalogs.dart';
import '../models/assets.dart';
import '../models/enums.dart';
import '../models/finance.dart';
import '../models/game_state.dart';
import '../models/opportunity.dart';
import 'financial_calculator.dart';
import 'rng.dart';
import 'risk_engine.dart';

class OpportunityEngine {
  static List<Opportunity> generate(GameState state, SimRng rng) {
    final inflation = _priceLevel(state);
    final list = <Opportunity>[];
    final count = 4 + rng.nextInt(3);
    for (var i = 0; i < count; i++) {
      final roll = rng.nextDouble();
      if (roll < 0.55) {
        list.add(_realEstate(state, rng, inflation, i));
      } else if (roll < 0.8) {
        list.add(_business(state, rng, inflation, i));
      } else {
        list.add(_security(state, rng, inflation, i));
      }
    }
    return list;
  }

  static double _priceLevel(GameState s) {
    return (1 + s.market.inflation).clamp(1, 3) *
        (1 + (s.year - 1) * 0.018) *
        s.market.constructionCostIndex.clamp(0.9, 1.6);
  }

  static Opportunity _realEstate(
    GameState state,
    SimRng rng,
    double inflation,
    int i,
  ) {
    final kinds = PropertyKind.values;
    var kind = rng.pick(kinds);
    if (state.year < 4 &&
        (kind == PropertyKind.hotel ||
            kind == PropertyKind.resort ||
            kind == PropertyKind.mixedUse) &&
        rng.chance(0.7)) {
      kind = rng.pick([
        PropertyKind.bangkokCondo,
        PropertyKind.pattayaApartment,
        PropertyKind.phuketVilla,
      ]);
    }
    final loc = switch (kind) {
      PropertyKind.bangkokCondo ||
      PropertyKind.mixedUse =>
        Location.bangkok,
      PropertyKind.phuketVilla || PropertyKind.resort =>
        rng.chance(0.7) ? Location.phuket : Location.samui,
      PropertyKind.pattayaApartment => Location.pattaya,
      PropertyKind.commercial => rng.pick([
          Location.bangkok,
          Location.phuket,
          Location.pattaya,
          Location.chiangMai,
        ]),
      PropertyKind.hotel => rng.pick([
          Location.bangkok,
          Location.phuket,
          Location.pattaya,
          Location.chiangMai,
        ]),
    };
    final name = switch (kind) {
      PropertyKind.bangkokCondo => rng.pick(Catalogs.condos),
      PropertyKind.phuketVilla => rng.pick(Catalogs.villas),
      PropertyKind.pattayaApartment => rng.pick(Catalogs.apartments),
      PropertyKind.commercial => rng.pick(Catalogs.commercials),
      PropertyKind.hotel => rng.pick(Catalogs.hotels),
      PropertyKind.resort => rng.pick(Catalogs.resorts),
      PropertyKind.mixedUse => rng.pick(Catalogs.mixed),
    };
    final base = switch (kind) {
      PropertyKind.bangkokCondo => rng.range(80000, 250000),
      PropertyKind.phuketVilla => rng.range(180000, 620000),
      PropertyKind.pattayaApartment => rng.range(48000, 160000),
      PropertyKind.commercial => rng.range(200000, 780000),
      PropertyKind.hotel => rng.range(420000, 1800000),
      PropertyKind.resort => rng.range(800000, 2800000),
      PropertyKind.mixedUse => rng.range(500000, 1900000),
    };
    final cycle = state.market.propertyCycle[loc] ?? 1;
    final price = FinancialCalculator.money(base * inflation * cycle);
    final development = (kind == PropertyKind.hotel ||
            kind == PropertyKind.resort ||
            kind == PropertyKind.mixedUse) &&
        rng.chance(0.28);
    final ownership = _ownerships(kind, rng);
    Investor? partner;
    var equity = 1.0;
    var voting = 1.0;
    if (ownership.contains(OwnershipStructure.jointVenture)) {
      partner = Investor(
        id: 'p_${state.turn}_$i',
        name: rng.pick(Catalogs.partners),
        quality: rng.range(0.35, 0.92),
        conflictProne: rng.chance(0.35),
      );
      equity = rng.range(0.45, 0.7);
      voting = rng.chance(0.5) ? equity : rng.range(0.3, 0.55);
    }
    final hospitality =
        kind == PropertyKind.hotel || kind == PropertyKind.resort;
    final risk = RiskEngine.score(
      location: loc,
      leverage: 0.4,
      market: state.market,
      development: development,
      partnerQuality: partner?.quality ?? 1,
      ownership: ownership.first,
      hospitality: hospitality,
    );
    final rooms = hospitality ? 12 + rng.nextInt(80) : 0;
    final adr = hospitality ? rng.range(45, 180) : 0.0;
    final yield_ = hospitality
        ? rng.range(0.07, 0.12)
        : rng.range(0.045, 0.085);
    return Opportunity(
      id: 'opp_${state.turn}_re_$i',
      kind: OpportunityKind.realEstate,
      title: name,
      summary: development
          ? 'Off-plan ${kind.name} in ${loc.label}. Income starts after completion; permits and costs can slip.'
          : '${kind.name} in ${loc.label}. Stabilized occupancy assumed at ${(rng.range(0.72, 0.92) * 100).toStringAsFixed(0)}%.',
      askingPrice: price,
      location: loc,
      riskLevel: RiskEngine.levelFor(risk),
      riskScore: risk,
      propertyKind: kind,
      ownershipOptions: ownership,
      grossYield: yield_,
      opexRatio: hospitality ? rng.range(0.42, 0.58) : rng.range(0.22, 0.4),
      occupancy: rng.range(0.7, 0.92) * state.market.tourismDemand.clamp(0.7, 1.1),
      adr: adr,
      rooms: rooms,
      isDevelopment: development,
      constructionQuarters: development ? 4 + rng.nextInt(8) : 0,
      partner: partner,
      equityShare: equity,
      votingShare: voting,
    );
  }

  static List<OwnershipStructure> _ownerships(PropertyKind kind, SimRng rng) {
    if (kind == PropertyKind.bangkokCondo ||
        kind == PropertyKind.pattayaApartment) {
      return [
        OwnershipStructure.condoFreehold,
        OwnershipStructure.leasehold,
        if (rng.chance(0.4)) OwnershipStructure.spv,
      ];
    }
    return [
      OwnershipStructure.leasehold,
      OwnershipStructure.jointVenture,
      OwnershipStructure.spv,
    ];
  }

  static Opportunity _business(
    GameState state,
    SimRng rng,
    double inflation,
    int i,
  ) {
    final kind = rng.pick(BusinessKind.values);
    final loc = switch (kind) {
      BusinessKind.restaurant => rng.pick([
          Location.bangkok,
          Location.pattaya,
          Location.chiangMai,
        ]),
      BusinessKind.wellness => rng.pick([Location.bangkok, Location.phuket]),
      BusinessKind.tourismCompany => rng.pick([
          Location.phuket,
          Location.samui,
          Location.bangkok,
        ]),
      BusinessKind.boatRental => rng.pick([Location.phuket, Location.samui, Location.pattaya]),
    };
    final name = switch (kind) {
      BusinessKind.restaurant => rng.pick(Catalogs.restaurants),
      BusinessKind.wellness => rng.pick(Catalogs.wellness),
      BusinessKind.tourismCompany => rng.pick(Catalogs.tourism),
      BusinessKind.boatRental => rng.pick(Catalogs.boats),
    };
    final price = FinancialCalculator.money(switch (kind) {
          BusinessKind.restaurant => rng.range(40000, 150000),
          BusinessKind.wellness => rng.range(60000, 210000),
          BusinessKind.tourismCompany => rng.range(80000, 320000),
          BusinessKind.boatRental => rng.range(50000, 190000),
        } *
        inflation);
    final partner = rng.chance(0.45)
        ? Investor(
            id: 'bp_${state.turn}_$i',
            name: rng.pick(Catalogs.partners),
            quality: rng.range(0.3, 0.9),
            conflictProne: rng.chance(0.4),
          )
        : null;
    final equity = partner == null ? 1.0 : rng.range(0.5, 0.75);
    final risk = RiskEngine.score(
      location: loc,
      leverage: 0.25,
      market: state.market,
      development: false,
      partnerQuality: partner?.quality ?? 1,
      ownership: partner == null
          ? OwnershipStructure.spv
          : OwnershipStructure.jointVenture,
      hospitality: true,
    );
    final rev = price * rng.range(0.7, 1.4);
    return Opportunity(
      id: 'opp_${state.turn}_biz_$i',
      kind: OpportunityKind.business,
      title: name,
      summary:
          '${kind.name} in ${loc.label}. Operating business with partner and demand risk.',
      askingPrice: price,
      location: loc,
      riskLevel: RiskEngine.levelFor(risk),
      riskScore: risk,
      businessKind: kind,
      ownershipOptions: partner == null
          ? const [OwnershipStructure.spv]
          : const [OwnershipStructure.jointVenture],
      margin: rng.range(0.08, 0.22),
      revenueRunRate: rev,
      partner: partner,
      equityShare: equity,
      votingShare: partner == null ? 1 : rng.range(0.4, 0.7),
    );
  }

  static Opportunity _security(
    GameState state,
    SimRng rng,
    double inflation,
    int i,
  ) {
    final kind = rng.pick(SecurityKind.values);
    final lot = FinancialCalculator.money(switch (kind) {
          SecurityKind.bond => rng.range(10000, 40000),
          SecurityKind.reit => rng.range(8000, 35000),
          SecurityKind.dividendStock => rng.range(5000, 30000),
        } *
        inflation);
    final yld = switch (kind) {
      SecurityKind.bond => state.market.interestRate + rng.range(-0.005, 0.008),
      SecurityKind.reit => rng.range(0.045, 0.08),
      SecurityKind.dividendStock => rng.range(0.03, 0.06),
    };
    final name = switch (kind) {
      SecurityKind.bond => 'Thai Govt Bond ${state.year}Q${state.quarter}',
      SecurityKind.reit => 'Bangkok Hospitality REIT lot',
      SecurityKind.dividendStock => 'SET Dividend Basket',
    };
    return Opportunity(
      id: 'opp_${state.turn}_sec_$i',
      kind: OpportunityKind.security,
      title: name,
      summary: 'Liquid financial asset. Lower operational risk, market-priced each quarter.',
      askingPrice: lot,
      location: Location.nationwide,
      riskLevel: kind == SecurityKind.bond ? RiskLevel.low : RiskLevel.medium,
      riskScore: kind == SecurityKind.bond ? 0.18 : 0.42,
      securityKind: kind,
      dividendYield: yld,
    );
  }

  static RealEstateAsset toProperty(
    Opportunity o,
    OwnershipStructure ownership,
    int turn,
  ) {
    return RealEstateAsset(
      id: 're_$turn${o.id}',
      name: o.title,
      kind: o.propertyKind!,
      location: o.location,
      ownership: ownership,
      purchasePrice: o.askingPrice,
      currentValue: o.askingPrice,
      acquiredTurn: turn,
      occupancy: o.occupancy.clamp(0.4, 0.98),
      grossYield: o.grossYield,
      opexRatio: o.opexRatio,
      riskScore: o.riskScore,
      riskLevel: o.riskLevel,
      adr: o.adr,
      rooms: o.rooms,
      leaseQuartersRemaining:
          ownership == OwnershipStructure.leasehold ? 120 : 0,
      equityShare: o.equityShare,
      votingShare: o.votingShare,
      partner: o.partner,
      isDevelopment: o.isDevelopment,
      constructionQuartersRemaining: o.constructionQuarters,
    );
  }

  static BusinessAsset toBusiness(Opportunity o, int turn) {
    return BusinessAsset(
      id: 'biz_$turn${o.id}',
      name: o.title,
      kind: o.businessKind!,
      location: o.location,
      purchasePrice: o.askingPrice,
      currentValue: o.askingPrice,
      acquiredTurn: turn,
      revenueRunRate: o.revenueRunRate,
      margin: o.margin,
      riskScore: o.riskScore,
      riskLevel: o.riskLevel,
      equityShare: o.equityShare,
      partner: o.partner,
    );
  }

  static SecurityHolding toSecurity(Opportunity o, int turn) {
    return SecurityHolding(
      id: 'sec_$turn${o.id}',
      kind: o.securityKind!,
      name: o.title,
      unitsCost: o.askingPrice,
      marketValue: o.askingPrice,
      dividendYield: o.dividendYield,
      acquiredTurn: turn,
    );
  }
}
