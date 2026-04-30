/// Represents a meal from TheMealDB API.
class Meal {
  final String id;
  final String name;
  final String? category;
  final String? area;
  final String? instructions;
  final String? thumbnailUrl;
  final String? tags;
  final String? youtubeUrl;
  final String? source;
  final List<String> ingredients;
  final List<String> measures;

  const Meal({
    required this.id,
    required this.name,
    this.category,
    this.area,
    this.instructions,
    this.thumbnailUrl,
    this.tags,
    this.youtubeUrl,
    this.source,
    this.ingredients = const [],
    this.measures = const [],
  });

  /// Creates a [Meal] from TheMealDB JSON response.
  factory Meal.fromJson(Map<String, dynamic> json) {
    final ingredients = <String>[];
    final measures = <String>[];

    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'] as String?;
      final measure = json['strMeasure$i'] as String?;

      if (ingredient != null && ingredient.trim().isNotEmpty) {
        ingredients.add(ingredient.trim());
        measures.add(measure?.trim() ?? '');
      }
    }

    return Meal(
      id: json['idMeal'] as String,
      name: json['strMeal'] as String,
      category: json['strCategory'] as String?,
      area: json['strArea'] as String?,
      instructions: json['strInstructions'] as String?,
      thumbnailUrl: json['strMealThumb'] as String?,
      tags: json['strTags'] as String?,
      youtubeUrl: json['strYoutube'] as String?,
      source: json['strSource'] as String?,
      ingredients: ingredients,
      measures: measures,
    );
  }

  /// Returns combined ingredient-measure pairs for display.
  List<String> get ingredientLines {
    final lines = <String>[];
    for (int i = 0; i < ingredients.length; i++) {
      final measure = i < measures.length ? measures[i] : '';
      if (measure.isNotEmpty) {
        lines.add('$measure ${ingredients[i]}');
      } else {
        lines.add(ingredients[i]);
      }
    }
    return lines;
  }

  /// Returns instruction steps split by newlines.
  List<String> get instructionSteps {
    if (instructions == null || instructions!.isEmpty) return [];
    return instructions!
        .split(RegExp(r'\r?\n'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Returns tag list.
  List<String> get tagList {
    if (tags == null || tags!.isEmpty) return [];
    return tags!.split(',').map((t) => t.trim()).toList();
  }
}

/// Represents a meal category from TheMealDB API.
class MealCategory {
  final String id;
  final String name;
  final String thumbnailUrl;
  final String description;

  const MealCategory({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    required this.description,
  });

  factory MealCategory.fromJson(Map<String, dynamic> json) {
    return MealCategory(
      id: json['idCategory'] as String,
      name: json['strCategory'] as String,
      thumbnailUrl: json['strCategoryThumb'] as String,
      description: json['strCategoryDescription'] as String,
    );
  }
}
