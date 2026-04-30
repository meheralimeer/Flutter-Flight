import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/meal.dart';
import '../services/meal_api_service.dart';
import '../services/preferences_service.dart';
import '../utils/constants.dart';
import '../widgets/badge.dart';
import '../widgets/section_header.dart';

/// Displays full meal details fetched from TheMealDB API.
class MealDetailScreen extends StatefulWidget {
  final String mealId;

  const MealDetailScreen({super.key, required this.mealId});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final MealApiService _api = MealApiService();
  final PreferencesService _prefs = PreferencesService();
  late Future<Meal?> _mealFuture;
  bool _isFavorite = false;
  final List<bool> _ingredientsChecked = [];

  @override
  void initState() {
    super.initState();
    _mealFuture = _loadMeal();
    _checkFavorite();
  }

  Future<Meal?> _loadMeal() async {
    final meal = await _api.getMealById(widget.mealId);
    if (meal != null) {
      setState(() {
        _ingredientsChecked.clear();
        for (var _ in meal.ingredientLines) {
          _ingredientsChecked.add(false);
        }
      });
    }
    return meal;
  }

  Future<void> _checkFavorite() async {
    final fav = await _prefs.isFavorite(widget.mealId);
    setState(() {
      _isFavorite = fav;
    });
  }

  Future<void> _toggleFavorite() async {
    await _prefs.toggleFavorite(widget.mealId);
    await _checkFavorite();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: FutureBuilder<Meal?>(
        future: _mealFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: kPrimaryColor,
              ),
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            return _buildError();
          }

          return _buildContent(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildError() {
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
          Text('Failed to load meal', style: kCaptionStyle),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _mealFuture = _loadMeal();
              });
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Meal meal) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroImage(meal),
          Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMealInfo(meal),
                const Divider(height: 32),
                _buildIngredientsSection(meal),
                _buildInstructionsSection(meal),
                if (meal.youtubeUrl != null &&
                    meal.youtubeUrl!.isNotEmpty)
                  _buildYoutubeLink(meal),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(Meal meal) {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: meal.thumbnailUrl ?? '',
          height: 350,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (_, _) => Container(
            height: 350,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (_, _, _) => Container(
            height: 350,
            color: Colors.grey[300],
            child: const Icon(Icons.error),
          ),
        ),
        // Gradient overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.5),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: kTextColor,
                    ),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: Icon(
                      _isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          _isFavorite ? Colors.red : kTextColor,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMealInfo(Meal meal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(meal.name, style: kTitleStyle),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (meal.category != null)
              CustomBadge(
                icon: Icons.restaurant_menu,
                text: meal.category!,
                color: kPrimaryColor,
              ),
            if (meal.area != null)
              CustomBadge(
                icon: Icons.flag,
                text: meal.area!,
                color: kAccentColor,
              ),
            ...meal.tagList.map(
              (tag) => CustomBadge(
                icon: Icons.tag,
                text: tag,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIngredientsSection(Meal meal) {
    final items = meal.ingredientLines;
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Ingredients'),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: items.length,
          itemBuilder: (context, index) {
            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                items[index],
                style: kBodyStyle.copyWith(
                  decoration:
                      index < _ingredientsChecked.length &&
                              _ingredientsChecked[index]
                          ? TextDecoration.lineThrough
                          : null,
                  color:
                      index < _ingredientsChecked.length &&
                              _ingredientsChecked[index]
                          ? kLightTextColor
                          : kTextColor,
                ),
              ),
              value: index < _ingredientsChecked.length
                  ? _ingredientsChecked[index]
                  : false,
              activeColor: kPrimaryColor,
              onChanged: (bool? value) {
                if (index < _ingredientsChecked.length) {
                  setState(() {
                    _ingredientsChecked[index] = value!;
                  });
                }
              },
              controlAffinity: ListTileControlAffinity.leading,
            );
          },
        ),
      ],
    );
  }

  Widget _buildInstructionsSection(Meal meal) {
    final steps = meal.instructionSteps;
    if (steps.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Instructions'),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: steps.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: kPrimaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        steps[index],
                        style: kBodyStyle,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildYoutubeLink(Meal meal) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Video Tutorial'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              borderRadius: kBorderRadius,
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.play_circle_fill,
                  color: Colors.red,
                  size: 36,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Watch on YouTube',
                        style: kBodyStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        meal.youtubeUrl!,
                        style: kCaptionStyle.copyWith(
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
