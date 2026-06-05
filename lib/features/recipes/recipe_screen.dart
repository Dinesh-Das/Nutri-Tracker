import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_tracker/models/indian_recipe.dart';
import 'package:nutri_tracker/routes/app_routes.dart';
import 'package:nutri_tracker/services/recipe_api_service.dart';
import 'package:nutri_tracker/widgets/cached_app_image.dart';
import 'package:nutri_tracker/widgets/recipe_card_widget.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final _service = RecipeApiService();
  final _search = TextEditingController();
  late Future<List<IndianRecipe>> _classics;
  Future<List<IndianRecipe>>? _results;
  IndianRecipe? _featured;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _classics = _service.fetchIndianRecipes();
    _service.randomIndianRecipe().then((value) {
      if (mounted) setState(() => _featured = value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _search,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Search recipes',
            ),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            children: [
              Chip(label: Text('All')),
              Chip(label: Text('Vegetarian')),
              Chip(label: Text('Breakfast')),
              Chip(label: Text('Curry')),
              Chip(label: Text('Rice')),
              Chip(label: Text('Dessert')),
            ],
          ),
          if (_featured != null) ...[
            const SizedBox(height: 12),
            _FeaturedRecipe(recipe: _featured!, onTap: () => _open(_featured!)),
          ],
          const SizedBox(height: 16),
          Text('Indian Classics',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          SizedBox(
            height: 220,
            child: FutureBuilder<List<IndianRecipe>>(
              future: _classics,
              builder: (context, snapshot) {
                final recipes = snapshot.data ?? [];
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recipes.length,
                  itemBuilder: (context, index) => SizedBox(
                    width: 170,
                    child: RecipeCardWidget(
                      recipe: recipes[index],
                      onTap: () => _open(recipes[index]),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text('By Category', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Chicken', 'Lamb', 'Vegetarian', 'Seafood', 'Dessert']
                .map((category) => ActionChip(
                      label: Text(category),
                      onPressed: () {
                        _search.text = category;
                        _onSearchChanged(category);
                      },
                    ))
                .toList(),
          ),
          if (_results != null) ...[
            const SizedBox(height: 16),
            FutureBuilder<List<IndianRecipe>>(
              future: _results,
              builder: (context, snapshot) {
                final recipes = snapshot.data ?? [];
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (recipes.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('No matching recipes found.')),
                  );
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) => RecipeCardWidget(
                    recipe: recipes[index],
                    onTap: () => _open(recipes[index]),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() {
        _results =
            value.trim().isEmpty ? null : _service.searchRecipes(value.trim());
      });
    });
  }

  void _open(IndianRecipe recipe) {
    context.push(AppRoutes.recipeDetail, extra: recipe);
  }
}

class _FeaturedRecipe extends StatelessWidget {
  const _FeaturedRecipe({required this.recipe, required this.onTap});

  final IndianRecipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            CachedAppImage(
              imageUrl: recipe.thumbnailUrl,
              height: 210,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.65)
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 16,
              right: 16,
              child: Text(
                recipe.name,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
