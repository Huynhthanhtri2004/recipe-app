import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/Provider/favorite_provider.dart';
import 'package:recipe_app/Provider/quantity.dart';
import 'package:recipe_app/Utils/constants.dart';
import 'package:recipe_app/Widget/my_icon_button.dart';
import 'package:recipe_app/Widget/quantity_incerment_decrement.dart';

class RecipeDetailScreen extends StatefulWidget {
  final DocumentSnapshot<Object?> documentSnapshot;
  const RecipeDetailScreen({super.key, required this.documentSnapshot});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  int _selectedRating = 0;

  @override
  void initState() {
    final amounts = widget.documentSnapshot['ingredientsAmount'] ?? [];
    final baseAmounts = amounts.map<double>((amount) {
      return double.tryParse(amount.toString()) ?? 0.0;
    }).toList();

    Provider.of<QuantityProvider>(context, listen: false)
        .setBaseIngredientAmounts(baseAmounts);

    super.initState();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit a review')),
      );
      return;
    }

    if (_selectedRating == 0 || _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating and comment')),
      );
      return;
    }

    try {
      final reviewData = {
        'userId': user.uid,
        'userName': user.displayName ?? user.email ?? 'Anonymous',
        'rating': _selectedRating,
        'comment': _commentController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      };


      // Lưu bình luận vào sub-collection 'reviews' của món ăn
      await FirebaseFirestore.instance
          .collection('RecipeApp')
          .doc(widget.documentSnapshot.id)
          .collection('reviews')
          .add(reviewData);

      // Cập nhật rating trung bình và số lượng reviews
      await _updateRecipeRating();

      _commentController.clear();
      setState(() {
        _selectedRating = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully')),
      );
      if (mounted) {
        _commentController.clear();
        setState(() {
          _selectedRating = 0;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting review: $e')),
      );
    }
  }


  Future<void> _updateRecipeRating() async {
    final reviewsSnapshot = await FirebaseFirestore.instance
        .collection('RecipeApp')
        .doc(widget.documentSnapshot.id)
        .collection('reviews')
        .get();

    if (reviewsSnapshot.docs.isEmpty) return;

    double totalRating = 0;
    for (var doc in reviewsSnapshot.docs) {
      totalRating += (doc['rating'] as num).toDouble();
    }
    final averageRating = totalRating / reviewsSnapshot.docs.length;

    await FirebaseFirestore.instance
        .collection('RecipeApp')
        .doc(widget.documentSnapshot.id)
        .update({
      'rating': averageRating.toStringAsFixed(1),
      'reviews': reviewsSnapshot.docs.length,
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = FavoriteProvider.of(context);
    final quantityProvider = Provider.of<QuantityProvider>(context);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: startCookingAndFavoriteButton(provider),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Hero(
                  tag: widget.documentSnapshot['image'],
                  child: Container(
                    height: MediaQuery.of(context).size.height / 2.1,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(widget.documentSnapshot['image']),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  right: 10,
                  child: Row(
                    children: [
                      MyIconButton(
                        icon: Iconsax.arrow_left,
                        pressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Spacer(),
                      MyIconButton(
                        icon: Iconsax.notification,
                        pressed: () {},
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: MediaQuery.of(context).size.width,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.documentSnapshot['name'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Iconsax.flash_1,
                        size: 20,
                        color: Colors.grey,
                      ),
                      Text(
                        "${widget.documentSnapshot['cal']} Cal",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
                        size: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "${widget.documentSnapshot['time']} Min",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Iconsax.star1,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.documentSnapshot['rating'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      Text(
                        "/5",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "${widget.documentSnapshot['reviews'].toString()} Reviews",
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ingredients",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "How many servings?",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      QuantityIncrementDecrement(
                        currentNumber: quantityProvider.currentNumber,
                        onAdd: () => quantityProvider.increaseQuantity(),
                        onRemov: () => quantityProvider.decreaseQuanity(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: (widget.documentSnapshot['ingredientsImage'] as List<dynamic>?)
                                ?.map<Widget>((imageUrl) => Container(
                              height: 60,
                              width: 60,
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(imageUrl),
                                ),
                              ),
                            ))
                                ?.toList() ??
                                [],
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: (widget.documentSnapshot['ingredientsName'] as List<dynamic>?)
                                ?.map<Widget>((ingredient) => SizedBox(
                              height: 60,
                              child: Center(
                                child: Text(
                                  ingredient,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).colorScheme.onBackground,
                                  ),
                                ),
                              ),
                            ))
                                ?.toList() ??
                                [],
                          ),
                          const Spacer(),
                          Column(
                            children: quantityProvider.updateIngredientAmounts
                                .map<Widget>((amount) => SizedBox(
                              height: 60,
                              child: Center(
                                child: Text(
                                  "${amount}gam",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).colorScheme.onBackground,
                                  ),
                                ),
                              ),
                            ))
                                .toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Phần đánh giá và bình luận
                  Text(
                    "Reviews",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Đánh giá sao
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _selectedRating ? Iconsax.star1 : Iconsax.star,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  // Nhập bình luận
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: "Write your review...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kprimaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("Submit Review"),
                  ),
                  const SizedBox(height: 20),
                  // Danh sách bình luận
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('RecipeApp')
                        .doc(widget.documentSnapshot.id)
                        .collection('reviews')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text("Error loading reviews"));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("No reviews yet"));
                      }

                      return Column(
                        children: snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      data['userName'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onBackground,
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: List.generate(5, (index) {
                                        return Icon(
                                          index < data['rating'] ? Iconsax.star1 : Iconsax.star,
                                          color: Colors.amber,
                                          size: 16,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  data['comment'],
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onBackground,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  data['timestamp'] != null
                                      ? (data['timestamp'] as Timestamp).toDate().toString()
                                      : 'Just now',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  FloatingActionButton startCookingAndFavoriteButton(FavoriteProvider provider) {
    return FloatingActionButton.extended(
      backgroundColor: Colors.transparent,
      elevation: 0,
      onPressed: () {},
      label: Row(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kprimaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
              foregroundColor: Colors.white,
            ),
            onPressed: () {},
            child: const Text(
              "Start Cooking",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(width: 13),
          IconButton(
            style: IconButton.styleFrom(
              shape: const CircleBorder(),
              side: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[700]!
                    : Colors.grey.shade300,
                width: 2,
              ),
            ),
            onPressed: () {
              provider.toggleFavorite(widget.documentSnapshot);
            },
            icon: Icon(
              provider.isExist(widget.documentSnapshot)
                  ? Iconsax.heart5
                  : Iconsax.heart,
              color: provider.isExist(widget.documentSnapshot)
                  ? Colors.red
                  : Theme.of(context).colorScheme.onBackground,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}