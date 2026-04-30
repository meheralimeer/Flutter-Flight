import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/meal.dart';
import '../services/meal_api_service.dart';
import '../utils/constants.dart';
import 'meal_detail_screen.dart';

/// Search screen for finding meals by name.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final MealApiService _api = MealApiService();
  final TextEditingController _searchController =
      TextEditingController();
  Timer? _debounceTimer;
  List<Meal> _results = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasSearched = false;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasSearched = true;
    });

    try {
      final results = await _api.searchMealsByName(query.trim());
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Search failed. Check your connection.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: kTextColor,
        title: Text('Search Meals', style: kSubtitleStyle),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search by meal name...',
          hintStyle: kCaptionStyle,
          prefixIcon: const Icon(
            Icons.search,
            color: kPrimaryColor,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: kLightTextColor,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: kCardColor,
          border: OutlineInputBorder(
            borderRadius: kBorderRadius,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: kBorderRadius,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: kBorderRadius,
            borderSide: const BorderSide(
              color: kPrimaryColor,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: kPrimaryColor),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 48,
              color: kLightTextColor,
            ),
            const SizedBox(height: 8),
            Text(_errorMessage!, style: kCaptionStyle),
          ],
        ),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant,
              size: 64,
              color: kPrimaryColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'Search for your favorite meals',
              style: kCaptionStyle,
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: kPrimaryColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text('No meals found', style: kCaptionStyle),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
      ),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        return _buildMealCard(_results[index]);
      },
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
        margin: const EdgeInsets.only(bottom: 12),
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
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  width: 100,
                  height: 100,
                  color: kSecondaryColor,
                ),
                errorWidget: (_, _, _) => Container(
                  width: 100,
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
                    Row(
                      children: [
                        if (meal.category != null)
                          Text(
                            meal.category!,
                            style: kCaptionStyle.copyWith(
                              fontSize: 12,
                              color: kPrimaryColor,
                            ),
                          ),
                        if (meal.area != null) ...[
                          Text(
                            ' • ',
                            style: kCaptionStyle.copyWith(
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            meal.area!,
                            style: kCaptionStyle.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
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
