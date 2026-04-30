import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/meal.dart';
import '../services/meal_api_service.dart';
import '../utils/constants.dart';
import 'meal_detail_screen.dart';

/// Displays all meals in a given category.
class CategoryMealsScreen extends StatefulWidget {
  final String categoryName;

  const CategoryMealsScreen({
    super.key,
    required this.categoryName,
  });

  @override
  State<CategoryMealsScreen> createState() =>
      _CategoryMealsScreenState();
}

class _CategoryMealsScreenState extends State<CategoryMealsScreen> {
  final MealApiService _api = MealApiService();
  late Future<List<Meal>> _mealsFuture;

  @override
  void initState() {
    super.initState();
    _mealsFuture = _api.filterByCategory(widget.categoryName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: kTextColor,
        title: Text(
          widget.categoryName,
          style: kSubtitleStyle,
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Meal>>(
        future: _mealsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: kPrimaryColor,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: kLightTextColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load meals',
                    style: kCaptionStyle,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _mealsFuture = _api.filterByCategory(
                          widget.categoryName,
                        );
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final meals = snapshot.data ?? [];
          if (meals.isEmpty) {
            return Center(
              child: Text(
                'No meals found',
                style: kCaptionStyle,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(kDefaultPadding),
            itemCount: meals.length,
            itemBuilder: (context, index) {
              return _buildMealCard(meals[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildMealCard(Meal meal) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MealDetailScreen(mealId: meal.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: kBorderRadius,
          boxShadow: kCardShadow,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: meal.thumbnailUrl ?? '',
                width: 120,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  width: 120,
                  height: 100,
                  color: kSecondaryColor,
                ),
                errorWidget: (_, _, _) => Container(
                  width: 120,
                  height: 100,
                  color: kSecondaryColor,
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(kSmallPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: kBodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to view recipe',
                      style: kCaptionStyle.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: kLightTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
