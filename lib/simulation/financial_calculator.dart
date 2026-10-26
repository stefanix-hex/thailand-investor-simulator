import '../models/assets.dart';
import '../models/enums.dart';
import '../models/game_state.dart';
import '../models/metrics.dart';

class FinancialCalculator {
  static double money(double v) => (v * 100).round() / 100;

  static double portfolioValue(GameState s) {
    var v = 0.0;
    for (final p in s.properties) {
      v += p.playerValue;
    }
    for (final b in s.businesses) {
      v += b.playerValue;
    }
    for (final sec in s.securities) {
      v += sec.marketValue;
    }
    return v;
  }

  static double debt(GameState s) {
    var d = 0.0;
    for (final l in s.loans) {
      d += l.principal;
    }
    return d;
  }

  static double netWorth(GameState s) => s.cash + portfolioValue(s) - debt(s);

  static double quarterlyPropertyNoi(RealEstateAsset p) {
    if (!p.producesIncome) return 0;
    final gross = p.currentValue * p.grossYield * p.occupancy / 4;
    final opex = gross * p.opexRatio;
    var compliance = 0.0;
    if (p.ownership == OwnershipStructure.spv) {
      compliance = p.currentValue * 0.002 / 4;
    }
    return (gross - opex - compliance) * p.equityShare;
  }

  static double quarterlyBusinessNoi(BusinessAsset b) {
    if (!b.producesIncome) return 0;
    return b.revenueRunRate * b.margin / 4 * b.equityShare;
  }

  static double quarterlyDividends(GameState s) {
    var d = 0.0;
    for (final sec in s.securities) {
      d += sec.marketValue * sec.dividendYield / 4;
    }
    return d;
  }

  static double quarterlyNoi(GameState s) {
    var n = quarterlyDividends(s);
    for (final p in s.properties) {
      n += quarterlyPropertyNoi(p);
    }
    for (final b in s.businesses) {
      n += quarterlyBusinessNoi(b);
    }
    return n;
  }

  static double quarterlyDebtService(GameState s) {
    var d = 0.0;
    for (final l in s.loans) {
      d += l.quarterlyPayment;
    }
    return d;
  }

  static Metrics compute(GameState s) {
    final port = portfolioValue(s);
    final d = debt(s);
    final noiQ = quarterlyNoi(s);
    final ds = quarterlyDebtService(s);
    final equity = s.cash + port - d;
    final invested = _costBasis(s);
    final hospitality = s.properties.where((p) => p.isHospitality && !p.failed);
    var occ = 0.0;
    var adr = 0.0;
    var rooms = 0;
    for (final p in hospitality) {
      occ += p.occupancy * p.rooms;
      adr += p.adr * p.rooms;
      rooms += p.rooms;
    }
    final occupancyRate = rooms == 0 ? 0.0 : occ / rooms;
    final avgAdr = rooms == 0 ? 0.0 : adr / rooms;
    return Metrics(
      cash: s.cash,
      portfolioValue: port,
      debt: d,
      netWorth: s.cash + port - d,
      passiveIncome: noiQ * 4,
      ltv: port <= 0 ? 0 : d / port,
      dscr: ds <= 0 ? 99 : noiQ / ds,
      roi: invested <= 0 ? 0 : (noiQ * 4) / invested,
      roe: equity <= 0 ? 0 : (noiQ * 4) / equity,
      occupancyRate: occupancyRate,
      adr: avgAdr,
      revpar: occupancyRate * avgAdr,
      quarterlyNoi: noiQ,
      quarterlyDebtService: ds,
    );
  }

  static double _costBasis(GameState s) {
    var c = 0.0;
    for (final p in s.properties) {
      c += p.purchasePrice * p.equityShare;
    }
    for (final b in s.businesses) {
      c += b.purchasePrice * b.equityShare;
    }
    for (final sec in s.securities) {
      c += sec.unitsCost;
    }
    return c;
  }
}
