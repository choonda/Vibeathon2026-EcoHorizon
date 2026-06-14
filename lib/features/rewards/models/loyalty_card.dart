/// Represents a linked fuel loyalty card (e.g. Petronas Mesra, Shell BonusLink).
class LoyaltyCard {
  const LoyaltyCard({
    required this.carrier,
    required this.cardNumber,
    required this.status,
    required this.pointsMultiplier,
  });

  /// Brand / issuing carrier of the card, e.g. "Petronas Mesra".
  final String carrier;

  /// Masked or full card number, e.g. "6012 **** **** 3801".
  final String cardNumber;

  /// Verification status: "verified" | "locked" | "pending".
  final String status;

  /// Multiplier applied on top of the base petrol-point earn rate.
  final double pointsMultiplier;

  // ── Convenience getters ────────────────────────────────────────────────────

  bool get isVerified => status.toLowerCase() == 'verified';

  // ── Mock data ──────────────────────────────────────────────────────────────

  static const List<LoyaltyCard> mockCards = [
    LoyaltyCard(
      carrier: 'Petronas Mesra',
      cardNumber: '6012 **** **** 3801',
      status: 'verified',
      pointsMultiplier: 1.5,
    ),
    LoyaltyCard(
      carrier: 'Shell BonusLink',
      cardNumber: '9800 **** **** 2247',
      status: 'locked',
      pointsMultiplier: 1.2,
    ),
  ];

  // ── Immutable update ───────────────────────────────────────────────────────

  LoyaltyCard copyWith({
    String? carrier,
    String? cardNumber,
    String? status,
    double? pointsMultiplier,
  }) {
    return LoyaltyCard(
      carrier: carrier ?? this.carrier,
      cardNumber: cardNumber ?? this.cardNumber,
      status: status ?? this.status,
      pointsMultiplier: pointsMultiplier ?? this.pointsMultiplier,
    );
  }
}
