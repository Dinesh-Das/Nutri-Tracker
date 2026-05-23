import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/models/indian_recipe.dart';

class RecipeCardWidget extends StatelessWidget {
  const RecipeCardWidget({
    super.key,
    required this.recipe,
    required this.onTap,
  });

  final IndianRecipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: recipe.thumbnailUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorWidget: (_, __, ___) =>
                    const Center(child: Icon(Icons.restaurant)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                recipe.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
