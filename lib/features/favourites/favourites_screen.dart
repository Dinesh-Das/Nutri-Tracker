import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/models/favourite_item.dart';
import 'package:nutri_tracker/services/firestore_service.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null)
      return const Scaffold(body: Center(child: Text('Please sign in.')));
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favourites'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Saved Recipes'), Tab(text: 'Saved Foods')],
          ),
        ),
        body: StreamBuilder<List<FavouriteItem>>(
          stream: FirestoreService().watchFavourites(uid),
          builder: (context, snapshot) {
            final items = snapshot.data ?? [];
            return TabBarView(
              children: [
                _FavouriteGrid(
                    items: items.where((i) => i.type == 'recipe').toList(),
                    uid: uid),
                _FavouriteGrid(
                    items: items.where((i) => i.type == 'food').toList(),
                    uid: uid),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FavouriteGrid extends StatelessWidget {
  const _FavouriteGrid({required this.items, required this.uid});

  final List<FavouriteItem> items;
  final String uid;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No favourites yet. Explore recipes!'));
    }
    return RefreshIndicator(
      onRefresh: () async {},
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.78,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: item.imageUrl.isEmpty
                      ? const Center(child: Icon(Icons.restaurant))
                      : CachedNetworkImage(
                          imageUrl: item.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(item.name,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
                Row(
                  children: [
                    if (item.calories != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text('${item.calories} kcal'),
                      ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.favorite),
                      onPressed: () =>
                          FirestoreService().removeFavourite(uid, item.id),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
