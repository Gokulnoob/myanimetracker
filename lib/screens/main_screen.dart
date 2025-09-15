import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';
import 'lists/my_lists_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const MyListsScreen(),
    const ProfileScreen(),
  ];

  final List<GButton> _navItems = [
    const GButton(
      icon: Icons.home_outlined,
      text: 'Home',
    ),
    const GButton(
      icon: Icons.search_outlined,
      text: 'Search',
    ),
    const GButton(
      icon: Icons.list_alt_outlined,
      text: 'My Lists',
    ),
    const GButton(
      icon: Icons.person_outline,
      text: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: TabBarView(
          controller: _tabController,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(.1),
              )
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
              child: GNav(
                rippleColor: Theme.of(context).primaryColor.withOpacity(0.1),
                hoverColor: Theme.of(context).primaryColor.withOpacity(0.1),
                gap: 8,
                activeColor: Theme.of(context).primaryColor,
                iconSize: 24,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                duration: const Duration(milliseconds: 400),
                tabBackgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.1),
                color: Colors.grey,
                curve: Curves.easeOutExpo,
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
                tabs: _navItems,
                selectedIndex: _currentIndex,
                onTabChange: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  _tabController.animateTo(index);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
