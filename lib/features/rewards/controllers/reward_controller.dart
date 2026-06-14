import 'package:flutter_riverpod/flutter_riverpod.dart';

class RewardState {
  const RewardState({
    required this.stars,
    required this.rewardPoints,
  });

  factory RewardState.initial() {
    return const RewardState(stars: 0, rewardPoints: 0);
  }

  final int stars;
  final int rewardPoints;

  RewardState copyWith({int? stars, int? rewardPoints}) {
    return RewardState(
      stars: stars ?? this.stars,
      rewardPoints: rewardPoints ?? this.rewardPoints,
    );
  }
}

final rewardControllerProvider =
    StateNotifierProvider<RewardController, RewardState>((ref) {
  return RewardController();
});

class RewardController extends StateNotifier<RewardState> {
  RewardController() : super(RewardState.initial());

  void settleReward({
    required int starRating,
    required int ecoScore,
    required double carbonSavedKg,
  }) {
    final baseByStar = switch (starRating) {
      3 => 50,
      2 => 30,
      _ => 10,
    };

    final ecoBonus = (ecoScore ~/ 10).clamp(0, 20);
    final carbonBonus = (carbonSavedKg * 2).round().clamp(0, 30);

    state = RewardState(
      stars: starRating.clamp(0, 3),
      rewardPoints: baseByStar + ecoBonus + carbonBonus,
    );
  }

  void settleDemoReward() {
    settleReward(starRating: 3, ecoScore: 88, carbonSavedKg: 2.4);
  }
}