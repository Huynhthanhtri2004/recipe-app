import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/Provider/favorite_provider.dart';
import 'package:recipe_app/Utils/constants.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = FavoriteProvider.of(context);
    final favoriteItems = provider.favorites;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
        elevation: 0,
        title: Text(
          "Favorites",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      ),
      body: favoriteItems.isEmpty
          ? Center(
        child: Text(
          "No Favorites yet",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      )
          : ListView.builder(
        itemCount: favoriteItems.length,
        itemBuilder: (context, index) {
          String favorite = favoriteItems[index];
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection("RecipeApp")
                .doc(favorite)
                .get(),
            builder: (context, snapshot) {
              // Kiểm tra mounted trước khi xây dựng
              if (!mounted) return const SizedBox.shrink();
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text("Error loading favorites"));
              }
              var favoriteItem = snapshot.data!;
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).cardColor,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 100,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(favoriteItem['image']),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                favoriteItem['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.onBackground,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(
                                    Iconsax.flash_1,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  Text(
                                    "${favoriteItem['cal']} Cal",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const Text(
                                    ".",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Icon(
                                    Iconsax.clock,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "${favoriteItem['time']} Min",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // delete
                  Positioned(
                    top: 50,
                    right: 35,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          provider.toggleFavorite(favoriteItem);
                        });
                      },
                      child: const Icon(
                        Iconsax.trash,
                        color: Colors.red,
                        size: 25,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}