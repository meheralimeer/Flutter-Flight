import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/meal.dart';
import '../services/meal_api_service.dart';
import '../utils/constants.dart';
import 'category_meals_screen.dart';
import 'meal_detail_screen.dart';
import 'search_screen.dart';

/// Home screen showing meal categories and a random meal.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MealApiService _api = MealApiService();
  late Future<List<MealCategory>> _categoriesFuture;
  late Future<Meal?> _randomMealFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _api.getCategories();
    _randomMealFuture = _api.getRandomMeal();
  }

  void _refreshRandom() {
    setState(() {
      _randomMealFuture = _api.getRandomMeal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            _buildRandomMealSection(),
            _buildCategoriesHeader(),
            _buildCategoriesGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          kDefaultPadding,
          kDefaultPadding,
          kDefaultPadding,
          8,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CookBook',
                    style: kTitleStyle.copyWith(
                      fontSize: 28,
                      color: kPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Powered by TheMealDB',
                    style: kCaptionStyle,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SearchScreen(),
                  ),
                );
              },
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.search,
                  color: kPrimaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRandomMealSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Try Something New', style: kSubtitleStyle),
                TextButton.icon(
                  onPressed: _refreshRandom,
                  icon: const Icon(
                    Icons.refresh,
                    size: 18,
                  ),
                  label: const Text('Shuffle'),
                  style: TextButton.styleFrom(
                    foregroundColor: kPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<Meal?>(
              future: _randomMealFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return _buildRandomPlaceholder();
                }
                if (snapshot.hasError || snapshot.data == null) {
                  return _buildRandomError();
                }
                return _buildRandomMealCard(snapshot.data!);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRandomPlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: kSecondaryColor,
        borderRadius: kBorderRadius,
      ),
      child: const Center(
        child: CircularProgressIndicator(color: kPrimaryColor),
      ),
    );
  }

  Widget _buildRandomError() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: kSecondaryColor,
        borderRadius: kBorderRadius,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off,
              color: kLightTextColor,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              'Could not load meal',
              style: kCaptionStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRandomMealCard(Meal meal) {
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
        height: 200,
        decoration: BoxDecoration(
          borderRadius: kBorderRadius,
          boxShadow: kCardShadow,
        ),
        child: ClipRRect(
          borderRadius: kBorderRadius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: meal.thumbnailUrl ?? '',
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  color: kSecondaryColor,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: kPrimaryColor,
                    ),
                  ),
                ),
                errorWidget: (_, _, _) => Container(
                  color: kSecondaryColor,
                  child: const Icon(Icons.broken_image),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (meal.category != null)
                          _buildTag(meal.category!),
                        if (meal.area != null) ...[
                          const SizedBox(width: 8),
                          _buildTag(meal.area!),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: kPrimaryColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCategoriesHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: kDefaultPadding,
        ),
        child: Text('Categories', style: kSubtitleStyle),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return FutureBuilder<List<MealCategory>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(
                color: kPrimaryColor,
              ),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return SliverFillRemaining(
            child: Center(
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
                    'Failed to load categories',
                    style: kCaptionStyle,
                  ),
                ],
              ),
            ),
          );
        }

        final categories = snapshot.data!;
        return SliverPadding(
          padding: const EdgeInsets.all(kDefaultPadding),
          sliver: SliverGrid(
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildCategoryCard(categories[index]);
              },
              childCount: categories.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(MealCategory category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryMealsScreen(
              categoryName: category.name,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: kBorderRadius,
          boxShadow: kCardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: category.thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    color: kSecondaryColor,
                  ),
                  errorWidget: (_, _, _) => Container(
                    color: kSecondaryColor,
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  child: Text(
                    category.name,
                    style: kBodyStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
