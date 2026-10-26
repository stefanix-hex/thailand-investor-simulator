import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/enums.dart';
import '../models/game_state.dart';
import '../models/metrics.dart';
import '../models/opportunity.dart';
import '../services/save_service.dart';
import '../simulation/financial_calculator.dart';
import '../simulation/quarter_engine.dart';

final gameProvider = NotifierProvider<GameNotifier, GameState>(GameNotifier.new);

final metricsProvider = Provider<Metrics>((ref) {
  return FinancialCalculator.compute(ref.watch(gameProvider));
});

class GameNotifier extends Notifier<GameState> {
  String? lastMessage;

  @override
  GameState build() {
    return GameState.titleScreen();
  }

  Future<void> persist() => SaveService.save(state);

  Future<void> newGame() async {
    state = QuarterEngine.startCampaign();
    lastMessage = 'New campaign. Year 1, Q1.';
    await persist();
  }

  Future<void> continueGame() async {
    final loaded = SaveService.load();
    if (loaded != null) state = loaded;
  }

  Future<void> closeQuarter() async {
    state = QuarterEngine.closeQuarter(state);
    lastMessage = state.phase == GamePhase.ended
        ? 'Year 20 Q4 closed. See the end-game report.'
        : 'Advanced to ${state.periodLabel}.';
    await persist();
  }

  Future<ActionResult> acquire(
    Opportunity opportunity, {
    required OwnershipStructure ownership,
    required double loanAmount,
  }) async {
    final result = QuarterEngine.buy(
      state,
      opportunity,
      ownership: ownership,
      loanAmount: loanAmount,
    );
    state = result.state;
    lastMessage = result.message;
    await persist();
    return result;
  }

  Future<ActionResult> sell(String id) async {
    final result = QuarterEngine.sellAsset(state, id);
    state = result.state;
    lastMessage = result.message;
    await persist();
    return result;
  }
}
