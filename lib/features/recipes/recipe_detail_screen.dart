import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_tracker/models/favourite_item.dart';
import 'package:nutri_tracker/models/indian_recipe.dart';
import 'package:nutri_tracker/routes/app_routes.dart';
import 'package:nutri_tracker/services/firestore_service.dart';
import 'package:nutri_tracker/services/recipe_api_service.dart';
import 'package:nutri_tracker/widgets/cached_app_image.dart';
import 'package:share_plus/share_plus.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key, required this.recipe});

  final IndianRecipe recipe;

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final _api = RecipeApiService();
  IndianRecipe? _recipe;

  @override
  void initState() {
    super.initState();
    if (widget.recipe.instructions.isEmpty) {
      _api.getRecipeById(widget.recipe.id).then((value) {
        if (mounted) setState(() => _recipe = value);
      });
    } else {
      _recipe = widget.recipe;
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = _recipe;
    if (recipe == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final steps = recipe.instructions
        .split(RegExp(r'\r?\n|(?<=\.)\s+'))
        .where((step) => step.trim().isNotEmpty)
        .toList();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(recipe.name),
              background: CachedAppImage(imageUrl: recipe.thumbnailUrl),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () async {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid == null) return;
                  await FirestoreService().saveFavourite(
                    uid,
                    FavouriteItem(
                      id: 'recipe_${recipe.id}',
                      type: 'recipe',
                      name: recipe.name,
                      imageUrl: recipe.thumbnailUrl,
                      sourceId: recipe.id,
                    ),
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Saved to favourites')),
                    );
                  }
                },
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Wrap(
                  spacing: 8,
                  children: [
                    if (recipe.category.isNotEmpty)
                      Chip(label: Text(recipe.category)),
                    if (recipe.area.isNotEmpty) Chip(label: Text(recipe.area)),
                    const Chip(label: Text('~35 min')),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Ingredients',
                    style: Theme.of(context).textTheme.titleLarge),
                for (final ingredient in recipe.ingredients)
                  CheckboxListTile(
                    value: false,
                    onChanged: (_) {},
                    title:
                        Text('${ingredient.measure} ${ingredient.name}'.trim()),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                const SizedBox(height: 16),
                Text('Steps', style: Theme.of(context).textTheme.titleLarge),
                for (var i = 0; i < steps.length; i++)
                  ListTile(
                    leading: CircleAvatar(child: Text('${i + 1}')),
                    title: Text(steps[i]),
                  ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => context.push(
                    AppRoutes.aiCoach,
                    extra:
                        'What are the nutritional benefits of ${recipe.name}?',
                  ),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Get Nutrition Info'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Share.share('${recipe.name}\n${recipe.youtubeUrl ?? ''}');
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share Recipe'),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
