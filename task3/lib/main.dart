import 'package:flutter/material.dart';
import 'screens/recipe_detail_screen.dart';
import 'utils/sample_data.dart';
import 'utils/constants.dart';

void main() {
  runApp(const CookBookApp());
}

class CookBookApp extends StatelessWidget {
  const CookBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CookBook',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
        useMaterial3: true,
      ),
      home: RecipeDetailScreen(recipe: kSampleRecipes[0]),
    );
  }
}
