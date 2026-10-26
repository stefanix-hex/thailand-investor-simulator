import 'package:flutter_test/flutter_test.dart';
import 'package:thailand_investor_simulator/models/game_state.dart';
import 'package:thailand_investor_simulator/simulation/financial_calculator.dart';
import 'package:thailand_investor_simulator/simulation/quarter_engine.dart';

void main() {
  test('opening book is 200k cash and 200k net worth', () {
    final s = QuarterEngine.startCampaign(seed: 42);
    final m = FinancialCalculator.compute(s);
    expect(s.cash, 200000);
    expect(m.debt, 0);
    expect(m.netWorth, 200000);
    expect(s.year, 1);
    expect(s.quarter, 1);
    expect(s.opportunities, isNotEmpty);
    expect(s.currentEvent, isNotNull);
  });

  test('closing a quarter advances time', () {
    var s = QuarterEngine.startCampaign(seed: 7);
    s = QuarterEngine.closeQuarter(s);
    expect(s.year, 1);
    expect(s.quarter, 2);
  });

  test('title state is not playable until start', () {
    final s = GameState.titleScreen();
    expect(s.phase.name, 'title');
  });
}
