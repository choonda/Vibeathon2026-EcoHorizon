import 'package:flutter/material.dart';

class StarRatingWidget extends StatelessWidget {
  const StarRatingWidget({
    super.key,
    required this.rating,
  });

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        final active = index < rating;
        return Icon(
          active ? Icons.star : Icons.star_border,
          color: active ? Colors.amber : Colors.grey,
        );
      }),
    );
  }
}