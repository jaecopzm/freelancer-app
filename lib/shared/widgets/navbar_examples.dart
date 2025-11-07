import 'package:flutter/material.dart';
import 'custom_navbar.dart';
import 'advanced_navbar.dart';
import 'custom_bottom_navbar.dart';

class NavBarExamples extends StatefulWidget {
  const NavBarExamples({super.key});

  @override
  State<NavBarExamples> createState() => _NavBarExamplesState();
}

class _NavBarExamplesState extends State<NavBarExamples> {
  int _currentBottomIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Example 1: Simple Custom NavBar
      appBar: const CustomNavBar(
        title: 'Beautiful NavBar',
        showBackButton: true,
        actions: [IconButton(icon: Icon(Icons.more_vert), onPressed: null)],
      ),

      body: const Center(
        child: Text(
          'Beautiful NavBar Examples',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),

      // Example: Custom Bottom NavBar
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentBottomIndex,
        onTap: (index) => setState(() => _currentBottomIndex = index),
        items: const [
          BottomNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
          ),
          BottomNavItem(
            icon: Icons.search_outlined,
            activeIcon: Icons.search,
            label: 'Search',
          ),
          BottomNavItem(
            icon: Icons.favorite_outline,
            activeIcon: Icons.favorite,
            label: 'Favorites',
          ),
          BottomNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Example with Advanced NavBar
class AdvancedNavBarExample extends StatefulWidget {
  const AdvancedNavBarExample({super.key});

  @override
  State<AdvancedNavBarExample> createState() => _AdvancedNavBarExampleState();
}

class _AdvancedNavBarExampleState extends State<AdvancedNavBarExample> {
  int _currentBottomIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdvancedNavBar(
        title: 'Freelance Companion',
        notificationCount: 3,
        onSearchTap: () {
          // Handle search
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Search tapped')));
        },
        onNotificationTap: () {
          // Handle notifications
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Notifications tapped')));
        },
        onMenuItemSelected: (value) {
          switch (value) {
            case 'profile':
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Profile selected')));
              break;
            case 'settings':
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings selected')),
              );
              break;
            case 'logout':
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Logout selected')));
              break;
          }
        },
      ),

      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, size: 100, color: Colors.amber),
            SizedBox(height: 20),
            Text(
              'Advanced NavBar with Features',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Search • Notifications • Profile Menu',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),

      // Example: Floating Bottom NavBar
      bottomNavigationBar: FloatingBottomNavBar(
        currentIndex: _currentBottomIndex,
        onTap: (index) => setState(() => _currentBottomIndex = index),
        items: const [
          BottomNavItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Dashboard',
          ),
          BottomNavItem(
            icon: Icons.work_outline,
            activeIcon: Icons.work,
            label: 'Projects',
          ),
          BottomNavItem(
            icon: Icons.people_outline,
            activeIcon: Icons.people,
            label: 'Clients',
          ),
          BottomNavItem(
            icon: Icons.analytics_outlined,
            activeIcon: Icons.analytics,
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}

// Example with different color schemes
class ColoredNavBarExample extends StatelessWidget {
  const ColoredNavBarExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomNavBar(
        title: 'Custom Colors',
        backgroundColor: Color(0xFF2E8B57), // Sea Green
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      body: const Center(
        child: Text('Custom Colored NavBar', style: TextStyle(fontSize: 20)),
      ),

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (index) {},
        backgroundColor: const Color(0xFF2E8B57),
        selectedColor: Colors.white,
        unselectedColor: Colors.white70,
        items: const [
          BottomNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
          ),
          BottomNavItem(
            icon: Icons.business_outlined,
            activeIcon: Icons.business,
            label: 'Business',
          ),
          BottomNavItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
