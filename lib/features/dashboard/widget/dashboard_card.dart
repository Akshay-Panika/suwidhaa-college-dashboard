import 'package:flutter/material.dart';
import '../../../core/utils/app_color.dart';

class DashboardCard extends StatefulWidget {
  final ValueChanged<int>? onNavigate;
  const DashboardCard({super.key, this.onNavigate});

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  // ── Dummy aggregate data (replace with API / GetX later) ──
  int get _totalCategories => 6;
  int get _totalColleges => 3;
  int get _totalRooms => 12;
  int get _totalTiffins => 8;
  int get _totalOwners => 4;
  int get _totalOrders => 24;
  double get _totalRevenue => 185000;
  int get _pendingOrders => 5;

  // Weekly order counts (Mon–Sun)
  final List<int> _weeklyOrders = const [3, 5, 2, 6, 4, 8, 7];

  final List<_RecentOrder> _recentOrders = const [
    _RecentOrder('ORD-1004', 'Isha Reddy', 'Premium Veg Combo', 2800,
        'Delivered', Color(0xFF059669)),
    _RecentOrder('ORD-1003', 'Kabir Mehta', 'Breakfast Light', 1200,
        'Pending', Color(0xFFD97706)),
    _RecentOrder('ORD-1002', 'Diya Patel', 'Chicken Combo', 3200,
        'Confirmed', Color(0xFF2563EB)),
    _RecentOrder('ORD-1001', 'Aarav Sharma', 'Veg Deluxe Thali', 2500,
        'Delivered', Color(0xFF059669)),
    _RecentOrder('ORD-1000', 'Rohan Joshi', 'Veg Deluxe Thali', 2500,
        'Cancelled', Color(0xFFDC2626)),
  ];

  final List<_TopCollege> _topColleges = const [
    _TopCollege('IIT Delhi', 6, 8, Color(0xFF6D28D9)),
    _TopCollege('AIIMS Delhi', 4, 5, Color(0xFF059669)),
    _TopCollege("St. Xavier's College", 3, 4, Color(0xFF2563EB)),
    _TopCollege('Delhi University', 2, 3, Color(0xFFD97706)),
  ];

  void _navigate(int index) => widget.onNavigate?.call(index);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWelcomeBanner(),
          const SizedBox(height: 20),
          _buildStatsGrid(),
          const SizedBox(height: 20),
          _buildQuickActions(),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 750) {
                return Column(
                  children: [
                    _buildWeeklyChart(),
                    const SizedBox(height: 16),
                    _buildRecentOrders(),
                    const SizedBox(height: 16),
                    _buildTopColleges(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildWeeklyChart()),
                  const SizedBox(width: 16),
                  Expanded(flex: 4, child: _buildRecentOrders()),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          if (MediaQuery.of(context).size.width >= 750)
            _buildTopColleges(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  WELCOME BANNER
  // ═══════════════════════════════════════════════
  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColor.primary, const Color(0xFF6D28D9)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back, Admin 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Here\'s what\'s happening across your college today.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _bannerChip(
                        Icons.receipt_long_rounded, '$_totalOrders Orders'),
                    _bannerChip(Icons.currency_rupee_rounded,
                        '₹${(_totalRevenue / 1000).toStringAsFixed(0)}K'),
                    _bannerChip(Icons.pending_actions_rounded,
                        '$_pendingOrders Pending'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.insights_rounded,
                color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _bannerChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 5),
          Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  STATS GRID
  // ═══════════════════════════════════════════════
  Widget _buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth > 900
            ? 6
            : (constraints.maxWidth > 600 ? 6 : 4);
        final items = [
          _statTile(
            icon: Icons.category_rounded,
            label: 'Categories',
            value: '$_totalCategories',
            color: AppColor.primary,
            onTap: () => _navigate(1),
          ),
          _statTile(
            icon: Icons.school_rounded,
            label: 'Colleges',
            value: '$_totalColleges',
            color: const Color(0xFF2563EB),
            onTap: () => _navigate(2),
          ),
          _statTile(
            icon: Icons.meeting_room_rounded,
            label: 'Rooms',
            value: '$_totalRooms',
            color: const Color(0xFF059669),
            onTap: () => _navigate(3),
          ),
          _statTile(
            icon: Icons.lunch_dining_rounded,
            label: 'Tiffins',
            value: '$_totalTiffins',
            color: const Color(0xFFD97706),
            onTap: () => _navigate(4),
          ),
          _statTile(
            icon: Icons.person_rounded,
            label: 'Owners',
            value: '$_totalOwners',
            color: const Color(0xFF9333EA),
            onTap: () => _navigate(5),
          ),
          _statTile(
            icon: Icons.receipt_long_rounded,
            label: 'Orders',
            value: '$_totalOrders',
            color: const Color(0xFFDC2626),
            onTap: () => _navigate(6),
          ),
        ];

        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: cols == 1 ? 3.2 : 1.9,
          children: items,
        );
      },
    );
  }

  Widget _statTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Material(
      color: AppColor.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColor.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: color)),
                    Text(label,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 12, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  WEEKLY CHART
  // ═══════════════════════════════════════════════
  Widget _buildWeeklyChart() {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final maxVal = _weeklyOrders.reduce((a, b) => a > b ? a : b).toDouble();
    final total = _weeklyOrders.fold<int>(0, (s, v) => s + v);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Weekly Orders',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColor.black)),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Total: $total',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColor.primary)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Last 7 days',
              style:
              TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) {
                final val = _weeklyOrders[i];
                final fraction = maxVal == 0 ? 0.0 : val / maxVal;
                final isToday = i == 6;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('$val',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isToday
                                ? AppColor.primary
                                : Colors.grey.shade600)),
                    const SizedBox(height: 4),
                    Container(
                      width: 22,
                      height: 12 + (110 * fraction),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isToday
                              ? [
                            AppColor.primary,
                            const Color(0xFF6D28D9)
                          ]
                              : [
                            AppColor.primary.withOpacity(0.6),
                            AppColor.primary.withOpacity(0.25)
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(days[i],
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isToday
                                ? AppColor.primary
                                : Colors.grey.shade600)),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  RECENT ORDERS
  // ═══════════════════════════════════════════════
  Widget _buildRecentOrders() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Recent Orders',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColor.black)),
              ),
              TextButton(
                onPressed: () => _navigate(6),
                style: TextButton.styleFrom(
                  foregroundColor: AppColor.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('View all',
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._recentOrders.map(_recentOrderRow),
        ],
      ),
    );
  }

  Widget _recentOrderRow(_RecentOrder o) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: o.statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.receipt_long_rounded,
                size: 16, color: o.statusColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(o.orderNo,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColor.black)),
                Text('${o.student} • ${o.tiffin}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 10, color: Colors.grey.shade600)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: o.statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(o.status,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: o.statusColor)),
          ),
          const SizedBox(width: 8),
          Text('₹${o.amount.toStringAsFixed(0)}',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColor.black)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  TOP COLLEGES
  // ═══════════════════════════════════════════════
  Widget _buildTopColleges() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Colleges',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColor.black)),
          const SizedBox(height: 12),
          ..._topColleges.map((c) {
            final maxRooms = _topColleges
                .map((e) => e.rooms)
                .reduce((a, b) => a > b ? a : b);
            final fraction = maxRooms == 0 ? 0.0 : c.rooms / maxRooms;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: c.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          c.name[0],
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: c.color),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(c.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColor.black)),
                      ),
                      Text('${c.rooms} rooms • ${c.tiffins} tiffins',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 6,
                      backgroundColor: AppColor.bg,
                      valueColor: AlwaysStoppedAnimation<Color>(c.color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  QUICK ACTIONS
  // ═══════════════════════════════════════════════
  Widget _buildQuickActions() {
    final actions = [
      _QuickAction('Add Category', Icons.category_rounded,
          const Color(0xFF6D28D9), 1),
      _QuickAction('Add College', Icons.school_rounded,
          const Color(0xFF2563EB), 2),
      _QuickAction('Add Room', Icons.meeting_room_rounded,
          const Color(0xFF059669), 3),
      _QuickAction('Add Tiffin', Icons.lunch_dining_rounded,
          const Color(0xFFD97706), 4),
      _QuickAction('Add Owner', Icons.person_rounded,
          const Color(0xFF9333EA), 5),
      _QuickAction('Add Order', Icons.receipt_long_rounded,
          const Color(0xFFDC2626), 6),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColor.black)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: actions.map((a) {
              return InkWell(
                onTap: () => _navigate(a.targetIndex),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: a.color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: a.color.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(a.icon, size: 16, color: a.color),
                      const SizedBox(width: 8),
                      Text(a.label,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: a.color)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  HELPER CLASSES
// ═══════════════════════════════════════════════
class _RecentOrder {
  final String orderNo;
  final String student;
  final String tiffin;
  final double amount;
  final String status;
  final Color statusColor;

  const _RecentOrder(this.orderNo, this.student, this.tiffin, this.amount,
      this.status, this.statusColor);
}

class _TopCollege {
  final String name;
  final int rooms;
  final int tiffins;
  final Color color;

  const _TopCollege(this.name, this.rooms, this.tiffins, this.color);
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final int targetIndex;

  const _QuickAction(this.label, this.icon, this.color, this.targetIndex);
}