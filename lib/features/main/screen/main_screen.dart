import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/utils/app_color.dart';
import '../../auth/screen/auth_screen.dart';

// ── Import all your card widgets (adjust paths if needed) ──
import '../../category/widget/category_card.dart';
import '../../college/widget/college_card.dart';
import '../../dashboard/widget/dashboard_card.dart';
import '../../order/order_card.dart';
import '../../owner/widget/owner_card.dart';
import '../../room/widget/room_card.dart';
import '../../tiffin/widget/tiffin_card.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // 0 = Dashboard, 1 = Category, 2 = College, 3 = Room,
  // 4 = Tiffin, 5 = Owner, 6 = Order
  int _selectedIndex = 0;

  // Sidebar menu (label + icon)
  final List<_MenuItem> _menu = const [
    _MenuItem('Dashboard', Icons.dashboard_rounded),
    _MenuItem('Category', Icons.category_rounded),
    _MenuItem('College', Icons.school_rounded),
    _MenuItem('Room', Icons.meeting_room_rounded),
    _MenuItem('Tiffin', Icons.lunch_dining_rounded),
    _MenuItem('Owner', Icons.person_rounded),
    _MenuItem('Order', Icons.receipt_long_rounded),
  ];

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userEmail');

    Fluttertoast.showToast(
      msg: 'Logged out successfully.',
      backgroundColor: AppColor.primary,
      textColor: AppColor.white,
      gravity: ToastGravity.BOTTOM,
    );

    // Widget route — no named routes needed
    Get.offAll(() => const AuthScreen());
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 760;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.white,
        elevation: 0,
        leading: isNarrow
            ? IconButton(
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: const Icon(Icons.menu),
        )
            : null,
        title: const Row(
          children: [
            Icon(Icons.school_rounded, size: 22),
            SizedBox(width: 10),
            Text(
              'College Admin',
              style:
              TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: isNarrow
          ? Drawer(child: SafeArea(child: _buildSidebar(isDrawer: true)))
          : null,
      body: SafeArea(
        child: isNarrow
            ? _buildContent()
            : Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSidebar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  SIDEBAR
  // ═══════════════════════════════════════════════
  Widget _buildSidebar({bool isDrawer = false}) {
    return Container(
      width: isDrawer ? 280 : 210,
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border(right: BorderSide(color: AppColor.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Brand header
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColor.border)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.school_rounded,
                      color: AppColor.primary, size: 18),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'COLLEGE ADMIN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontSize: 12,
                      color: AppColor.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _menu.length,
              itemBuilder: (context, i) {
                final item = _menu[i];
                final isSelected = _selectedIndex == i;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 2),
                  child: Material(
                    color: isSelected
                        ? AppColor.primary.withOpacity(0.10)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        setState(() => _selectedIndex = i);
                        // Close drawer if open
                        if (_scaffoldKey.currentState?.isDrawerOpen ==
                            true) {
                          Navigator.pop(context);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 18,
                              color: isSelected
                                  ? AppColor.primary
                                  : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColor.primary
                                    : AppColor.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColor.border)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColor.primary.withOpacity(0.12),
                  child: Icon(Icons.person,
                      size: 16, color: AppColor.primary),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Admin',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColor.black)),
                      Text('admin@gmail.com',
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  CONTENT ROUTER — switches card based on selection
  // ═══════════════════════════════════════════════
  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return DashboardCard(
          onNavigate: (i) => setState(() => _selectedIndex = i),
        );
      case 1:
        return const CategoryCard();
      case 2:
        return const CollegeCard();
      case 3:
        return const RoomCard();
      case 4:
        return const TiffinCard();
      case 5:
        return const OwnerCard();
      case 6:
        return const OrderCard();
      default:
        return DashboardCard(
          onNavigate: (i) => setState(() => _selectedIndex = i),
        );
    }
  }
}

// ═══════════════════════════════════════════════
//  MENU ITEM MODEL
// ═══════════════════════════════════════════════
class _MenuItem {
  final String label;
  final IconData icon;
  const _MenuItem(this.label, this.icon);
}