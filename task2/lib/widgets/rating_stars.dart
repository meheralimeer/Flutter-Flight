import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final double itemSize;

  const RatingStars({
    super.key,
    required this.rating,
    this.reviewCount,
    this.itemSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RatingBarIndicator(
          rating: rating,
          itemBuilder: (context, index) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          itemCount: 5,
          itemSize: itemSize,
          direction: Axis.horizontal,
        ),
        if (reviewCount != null) ...[
          const SizedBox(width: 8),
          Text(
            '($reviewCount)',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }
}
