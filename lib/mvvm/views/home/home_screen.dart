import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/mvvm/viewmodels/auth/auth_cubit.dart';
import 'package:frontend/mvvm/viewmodels/user_cubit.dart';
import 'package:frontend/mvvm/views/home/calendar/calendar_screen.dart';
import 'package:frontend/mvvm/views/home/focus/statistics_screen.dart';
import 'package:frontend/mvvm/views/home/index/index_screen.dart';
import 'package:frontend/mvvm/views/home/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final GlobalKey<IndexScreenState> _indexKey = GlobalKey<IndexScreenState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    final uid = context.read<AuthCubit>().state.uid;
    if (uid != null) {
      context.read<UserCubit>().getProfile(uid);
    }
    
    _screens = [
      IndexScreen(key: _indexKey),
      const CalendarScreen(),
      const StatisticsScreen(),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.surface,
        elevation: 0,
        notchMargin: 8,
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Nhóm trái
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem('assets/icons/home.svg', 'Index', 0),
                  _buildNavItem('assets/icons/calendar.svg', 'Calendar', 1),
                ],
              ),
            ),

            const SizedBox(width: 64), // chừa chỗ cho FAB

            // Nhóm phải
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem('assets/icons/clock.svg', 'Focus', 2),
                  _buildNavItem('assets/icons/user.svg', 'Profile', 3),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        height: 64,
        width: 64,
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.primary,
          onPressed: () {
            if (_selectedIndex == 0) {
              // 👇 gọi hàm show form trong IndexScreen
              _indexKey.currentState?.showAddTaskSheet();
            } else {
              _onItemTapped(0); // quay về Index nếu đang tab khác
            }
          },
          shape: const CircleBorder(),
          elevation: 6,
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  Widget _buildNavItem(String assetPath, String label, int index) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? Colors.white : Colors.white54;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            assetPath,
            height: 24,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
