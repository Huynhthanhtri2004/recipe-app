import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/Models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _userModel;
  bool _isLoading = false;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isAdmin => _userModel?.isAdmin ?? false;

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Tạo user trong Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Tạo user model
      final UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        role: 'user', // Mặc định là user
        createdAt: DateTime.now(),
      );

      // Lưu thông tin user vào Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set(newUser.toMap());

      _userModel = newUser;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Đăng nhập với Firebase Auth
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Lấy thông tin user từ Firestore
      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (doc.exists) {
        _userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _userModel = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      await _firestore.collection('users').doc(uid).update({'role': newRole});
      if (_userModel?.uid == uid) {
        _userModel = _userModel?.copyWith(role: newRole);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchUserData() async {
    try {
      if (_auth.currentUser != null) {
        final DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();

        if (doc.exists) {
          _userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
          notifyListeners();
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Hàm tạo tài khoản admin
  Future<void> createAdminAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Tạo user trong Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Tạo user model với role admin
      final UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        role: 'admin', // Đặt role là admin
        createdAt: DateTime.now(),
      );

      // Lưu thông tin user vào Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set(newUser.toMap());

      _userModel = newUser;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
} 