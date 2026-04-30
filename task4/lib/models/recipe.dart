enum Difficulty { easy, medium, hard }

class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final int timeInMinutes;
  final Difficulty difficulty;
  final List<String> ingredients;
  final List<String> steps;
  final String category;
  bool isFavorite;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.timeInMinutes,
    required this.difficulty,
    required this.ingredients,
    required this.steps,
    required this.category,
    this.isFavorite = false,
  });

  String get difficultyString {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }
}
