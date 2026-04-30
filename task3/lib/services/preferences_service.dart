import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _favoritesKey = 'favorites';
  static const String _isDarkThemeKey = 'isDarkTheme';

  Future<void> toggleFavorite(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_favoritesKey) ?? [];
    
    if (favorites.contains(recipeId)) {
      favorites.remove(recipeId);
    } else {
      favorites.add(recipeId);
    }
    
    await prefs.setStringList(_favoritesKey, favorites);
  }

  Future<bool> isFavorite(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_favoritesKey) ?? [];
    return favorites.contains(recipeId);
  }

  Future<void> setThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isDarkThemeKey, isDark);
  }

  Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isDarkThemeKey) ?? false;
  }
}
