import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/Models/user_model.dart';
import 'package:recipe_app/Provider/auth_provider.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              UserModel user = UserModel.fromMap(data);

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.profileImage != null
                      ? NetworkImage(user.profileImage!)
                      : null,
                  child: user.profileImage == null
                      ? Text(user.name[0].toUpperCase())
                      : null,
                ),
                title: Text(user.name),
                subtitle: Text(user.email),
                trailing: DropdownButton<String>(
                  value: user.role,
                  items: const [
                    DropdownMenuItem(
                      value: 'user',
                      child: Text('User'),
                    ),
                    DropdownMenuItem(
                      value: 'admin',
                      child: Text('Admin'),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      context
                          .read<AuthProvider>()
                          .updateUserRole(user.uid, newValue);
                    }
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
} 