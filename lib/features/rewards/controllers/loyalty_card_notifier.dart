import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/loyalty_card.dart';

// ── Provider ───────────────────────────────────────────────────────────────────

final loyaltyCardProvider =
    StateNotifierProvider<LoyaltyCardNotifier, List<LoyaltyCard>>((ref) {
  return LoyaltyCardNotifier()..loadMockCards();
});

// ── StateNotifier ──────────────────────────────────────────────────────────────

class LoyaltyCardNotifier extends StateNotifier<List<LoyaltyCard>> {
  LoyaltyCardNotifier() : super(const []);

  /// Seeds the list with the predefined Petronas Mesra & Shell BonusLink cards.
  void loadMockCards() {
    state = LoyaltyCard.mockCards;
  }

  /// Adds a new card to the wallet.
  void addCard(LoyaltyCard card) {
    state = [...state, card];
  }

  /// Removes a card by its card number.
  void removeCard(String cardNumber) {
    state = state.where((c) => c.cardNumber != cardNumber).toList();
  }

  /// Updates the status of an existing card (e.g. "locked" → "verified").
  void updateStatus(String cardNumber, String newStatus) {
    state = [
      for (final card in state)
        if (card.cardNumber == cardNumber)
          card.copyWith(status: newStatus)
        else
          card,
    ];
  }
}
