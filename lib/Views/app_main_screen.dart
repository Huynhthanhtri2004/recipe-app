import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/Views/admin_screen.dart';
import 'package:recipe_app/Views/favorite_screen.dart';
import 'package:recipe_app/Views/my_app_home_screen.dart';
import 'package:recipe_app/Views/profile_screen.dart';
import 'meal_plan_screen.dart';
import 'package:recipe_app/Provider/auth_provider.dart' as my_auth;


class AppMainScreen extends StatefulWidget {
  const AppMainScreen({super.key});

  @override
  State<AppMainScreen> createState() => _AppMainScreenState();
}

class _AppMainScreenState extends State<AppMainScreen> {
  int selectedIndex = 0;
  late final List<Widget> page;

  @override
  void initState() {
    super.initState();
    page = [
      const MyAppHomeScreen(),
      const FavoriteScreen(),
      const MealPlanScreen(),
      const ProfileScreen(),
    ];
  }

  // Thêm phương thức để giữ trạng thái khi rebuild
  @override
  void didChangeDependencies() {
    final previousIndex = selectedIndex;
    super.didChangeDependencies();
    // Khôi phục trạng thái sau khi rebuild
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          selectedIndex = previousIndex;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authProvider = context.watch<my_auth.AuthProvider>();
    final isAdmin = authProvider.isAdmin;


    // Nếu là admin, thêm màn hình Admin vào danh sách
    if (isAdmin && page.length == 4) {
      page.add(const AdminScreen());
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        elevation: 0,
        iconSize: 24,
        currentIndex: selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.secondary,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 0 ? Iconsax.home_15 : Iconsax.home_1,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 1 ? Iconsax.heart5 : Iconsax.heart,
            ),
            label: "Favorite",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 2 ? Iconsax.calendar_25 : Iconsax.calendar_2,
            ),
            label: "Meal Plan",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 3 ? Iconsax.profile_circle5 : Iconsax.profile_circle,
            ),
            label: "Profile",
          ),
          if (isAdmin)
            BottomNavigationBarItem(
              icon: Icon(
                selectedIndex == 4 ? Iconsax.shield_tick5 : Iconsax.shield_tick,
              ),
              label: "Admin",
            ),
        ],
      ),

      body: IndexedStack(
        index: selectedIndex,
        children: page,
      ),
    );
  }

  Widget navBarPage(IconData iconName) {
    return Center(
      child: Icon(
        iconName,
        size: 100,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}