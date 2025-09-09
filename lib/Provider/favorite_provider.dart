import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteProvider extends ChangeNotifier {
  List<String> _favoriteIds = [];
  List<String> get favorites => _favoriteIds;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FavoriteProvider() {
    loadFavorites();
  }

  void toggleFavorite(DocumentSnapshot product) async {
    final productId = product.id;
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
      await _removeFavorite(productId);
    } else {
      _favoriteIds.add(productId);
      await _addFavorite(productId);
    }
    if (hasListeners) {
      notifyListeners();
    }
  }

  bool isExist(DocumentSnapshot product) {
    return _favoriteIds.contains(product.id);
  }

  Future<void> _addFavorite(String productId) async {
    try {
      await _firestore.collection("userFavorite").doc(productId).set({
        'isFavorite': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding favorite: $e');
    }
  }

  Future<void> _removeFavorite(String productId) async {
    try {
      await _firestore.collection("userFavorite").doc(productId).delete();
    } catch (e) {
      print('Error removing favorite: $e');
    }
  }

  Future<void> loadFavorites() async {
    try {
      final snapshot = await _firestore.collection("userFavorite").get();
      _favoriteIds = snapshot.docs.map((doc) => doc.id).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  static FavoriteProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<FavoriteProvider>(context, listen: listen);
  }
}