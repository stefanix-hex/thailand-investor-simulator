import '../models/enums.dart';
import '../models/market.dart';

class RiskEngine {
  static RiskLevel levelFor(double score) {
    if (score < 0.34) return RiskLevel.low;
    if (score < 0.66) return RiskLevel.medium;
    return RiskLevel.high;
  }

  static double score({
    required Location location,
    required double leverage,
    required MarketConditions market,
    required bool development,
    required double partnerQuality,
    required OwnershipStructure ownership,
    required bool hospitality,
  }) {
    var s = 0.25;
    s += switch (location) {
      Location.bangkok => 0.05,
      Location.phuket => 0.12,
      Location.pattaya => 0.16,
      Location.chiangMai => 0.10,
      Location.samui => 0.18,
      Location.nationwide => 0.08,
    };
    s += leverage * 0.22;
    s += market.politicalRisk * 0.2;
    s += market.regulatoryTightness * 0.12;
    s += (1.2 - market.tourismDemand).clamp(0, 1) * (hospitality ? 0.18 : 0.06);
    if (development) s += 0.18;
    s += (1 - partnerQuality) * 0.15;
    s += switch (ownership) {
      OwnershipStructure.condoFreehold => 0.02,
      OwnershipStructure.leasehold => 0.12,
      OwnershipStructure.jointVenture => 0.14,
      OwnershipStructure.spv => 0.08,
    };
    return s.clamp(0.05, 0.97);
  }
}
