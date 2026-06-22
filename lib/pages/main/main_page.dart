import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../devices/devices_page.dart';
import '../guard/guard_page.dart';
import '../home/home_page.dart';
import '../profile/profile_page.dart';
import '../records/records_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    RecordsPage(),
    GuardPage(),
    DevicesPage(),
    ProfilePage(),
  ];

  Widget _buildNavItem(String name, int index) {
    final isSelected = _currentIndex == index;
    return Image.asset(
      'assets/images/tabbar_${name}_${isSelected ? 'press' : 'normal'}.png',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.colorTheme,
        unselectedItemColor: AppColors.color999999,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
            icon: _buildNavItem('homepage', 0),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: _buildNavItem('records', 1),
            label: '记录',
          ),
          BottomNavigationBarItem(
            icon: _buildNavItem('guard', 2),
            label: '守护模式',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                _buildNavItem('devices', 3),
                if (_currentIndex != 3)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            label: '设备',
          ),
          BottomNavigationBarItem(
            icon: _buildNavItem('profile', 4),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
