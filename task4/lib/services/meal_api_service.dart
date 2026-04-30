import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal.dart';

/// Service for interacting with TheMealDB API.
///
/// Base URL: https://www.themealdb.com/api/json/v1/1/
/// Uses the free tier test API key `1`.
class MealApiService {
  static const String _baseUrl =
      'https://www.themealdb.com/api/json/v1/1';

  final http.Client _client;

  MealApiService({http.Client? client})
      : _client = client ?? http.Client();

  /// Searches meals by name.
  /// Endpoint: search.php?s={query}
  Future<List<Meal>> searchMealsByName(String query) async {
    final uri = Uri.parse('$_baseUrl/search.php?s=$query');
    final response = await _client.get(uri);
    return _parseMeals(response);
  }

  /// Lists all meals by first letter.
  /// Endpoint: search.php?f={letter}
  Future<List<Meal>> listMealsByLetter(String letter) async {
    final uri = Uri.parse('$_baseUrl/search.php?f=$letter');
    final response = await _client.get(uri);
    return _parseMeals(response);
  }

  /// Looks up full meal details by ID.
  /// Endpoint: lookup.php?i={id}
  Future<Meal?> getMealById(String id) async {
    final uri = Uri.parse('$_baseUrl/lookup.php?i=$id');
    final response = await _client.get(uri);
    final meals = _parseMeals(response);
    return meals.isNotEmpty ? meals.first : null;
  }

  /// Gets a single random meal.
  /// Endpoint: random.php
  Future<Meal?> getRandomMeal() async {
    final uri = Uri.parse('$_baseUrl/random.php');
    final response = await _client.get(uri);
    final meals = _parseMeals(response);
    return meals.isNotEmpty ? meals.first : null;
  }

  /// Lists all meal categories with descriptions.
  /// Endpoint: categories.php
  Future<List<MealCategory>> getCategories() async {
    final uri = Uri.parse('$_baseUrl/categories.php');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load categories');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final categories = data['categories'] as List<dynamic>?;
    if (categories == null) return [];

    return categories
        .map(
          (c) => MealCategory.fromJson(c as Map<String, dynamic>),
        )
        .toList();
  }

  /// Filters meals by category.
  /// Endpoint: filter.php?c={category}
  Future<List<Meal>> filterByCategory(String category) async {
    final uri = Uri.parse('$_baseUrl/filter.php?c=$category');
    final response = await _client.get(uri);
    return _parseFilteredMeals(response);
  }

  /// Filters meals by area/cuisine.
  /// Endpoint: filter.php?a={area}
  Future<List<Meal>> filterByArea(String area) async {
    final uri = Uri.parse('$_baseUrl/filter.php?a=$area');
    final response = await _client.get(uri);
    return _parseFilteredMeals(response);
  }

  /// Filters meals by main ingredient.
  /// Endpoint: filter.php?i={ingredient}
  Future<List<Meal>> filterByIngredient(String ingredient) async {
    final uri = Uri.parse('$_baseUrl/filter.php?i=$ingredient');
    final response = await _client.get(uri);
    return _parseFilteredMeals(response);
  }

  /// Lists all available categories (simple list).
  /// Endpoint: list.php?c=list
  Future<List<String>> listAllCategories() async {
    final uri = Uri.parse('$_baseUrl/list.php?c=list');
    final response = await _client.get(uri);

    if (response.statusCode != 200) return [];

    final data = json.decode(response.body) as Map<String, dynamic>;
    final meals = data['meals'] as List<dynamic>?;
    if (meals == null) return [];

    return meals
        .map((m) => (m as Map<String, dynamic>)['strCategory'] as String)
        .toList();
  }

  /// Lists all available areas/cuisines.
  /// Endpoint: list.php?a=list
  Future<List<String>> listAllAreas() async {
    final uri = Uri.parse('$_baseUrl/list.php?a=list');
    final response = await _client.get(uri);

    if (response.statusCode != 200) return [];

    final data = json.decode(response.body) as Map<String, dynamic>;
    final meals = data['meals'] as List<dynamic>?;
    if (meals == null) return [];

    return meals
        .map((m) => (m as Map<String, dynamic>)['strArea'] as String)
        .toList();
  }

  /// Parses full meal objects from API response.
  List<Meal> _parseMeals(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception('Failed to load meals');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final meals = data['meals'] as List<dynamic>?;
    if (meals == null) return [];

    return meals
        .map((m) => Meal.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  /// Parses filtered meal results (only id, name, thumbnail).
  List<Meal> _parseFilteredMeals(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception('Failed to load meals');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final meals = data['meals'] as List<dynamic>?;
    if (meals == null) return [];

    return meals.map((m) {
      final json = m as Map<String, dynamic>;
      return Meal(
        id: json['idMeal'] as String,
        name: json['strMeal'] as String,
        thumbnailUrl: json['strMealThumb'] as String?,
      );
    }).toList();
  }
}
