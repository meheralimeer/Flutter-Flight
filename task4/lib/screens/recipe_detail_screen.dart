import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/recipe.dart';
import '../utils/constants.dart';
import '../widgets/badge.dart';
import '../widgets/rating_stars.dart';
import '../widgets/section_header.dart';
import '../services/preferences_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final PreferencesService _prefs = PreferencesService();
  bool _isFavorite = false;
  final List<bool> _ingredientsChecked = [];

  @override
  void initState() {
    super.initState();
    _checkFavorite();
    for (var _ in widget.recipe.ingredients) {
      _ingredientsChecked.add(false);
    }
  }

  Future<void> _checkFavorite() async {
    final fav = await _prefs.isFavorite(widget.recipe.id);
    setState(() {
      _isFavorite = fav;
    });
  }

  Future<void> _toggleFavorite() async {
    await _prefs.toggleFavorite(widget.recipe.id);
    await _checkFavorite();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroImage(context),
            Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRecipeInfo(),
                  const Divider(height: 32),
                  _buildIngredientsSection(),
                  _buildStepsSection(),
                  const SizedBox(height: 100), // Space for sticky bottom bar
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomActionBar(),
    );
  }

  Widget _buildHeroImage(BuildContext context) {
    return Stack(
      children: [
        Hero(
          tag: widget.recipe.id,
          child: CachedNetworkImage(
            imageUrl: widget.recipe.imageUrl,
            height: 350,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 350,
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              height: 350,
              color: Colors.grey[300],
              child: const Icon(Icons.error),
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
                    icon: const Icon(Icons.arrow_back, color: kTextColor),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : kTextColor,
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

  Widget _buildRecipeInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.recipe.title, style: kTitleStyle),
        const SizedBox(height: 8),
        RatingStars(
          rating: widget.recipe.rating,
          reviewCount: widget.recipe.reviewCount,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            CustomBadge(
              icon: Icons.timer_outlined,
              text: '${widget.recipe.timeInMinutes} min',
              color: kPrimaryColor,
            ),
            const SizedBox(width: 12),
            CustomBadge(
              icon: Icons.signal_cellular_alt,
              text: widget.recipe.difficultyString,
              color: _getDifficultyColor(widget.recipe.difficulty),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.recipe.description,
          style: kBodyStyle.copyWith(color: kLightTextColor),
        ),
      ],
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Ingredients'),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: widget.recipe.ingredients.length,
          itemBuilder: (context, index) {
            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                widget.recipe.ingredients[index],
                style: kBodyStyle.copyWith(
                  decoration: _ingredientsChecked[index]
                      ? TextDecoration.lineThrough
                      : null,
                  color: _ingredientsChecked[index]
                      ? kLightTextColor
                      : kTextColor,
                ),
              ),
              value: _ingredientsChecked[index],
              activeColor: kPrimaryColor,
              onChanged: (bool? value) {
                setState(() {
                  _ingredientsChecked[index] = value!;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            );
          },
        ),
      ],
    );
  }

  Widget _buildStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Instructions'),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: widget.recipe.steps.length,
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
                        widget.recipe.steps[index],
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

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Start Cooking',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimaryColor,
                  side: const BorderSide(color: kPrimaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Edit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
    }
  }
}
