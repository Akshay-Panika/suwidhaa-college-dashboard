import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/utils/app_color.dart';

// ═══════════════════════════════════════════════
//  MODEL
// ═══════════════════════════════════════════════
class OrderModel {
  int id;
  String orderNo;
  String studentName;
  String college;
  String owner;
  String tiffin;
  int quantity;
  double totalAmount;
  DateTime orderDate;
  String status; // Pending / Confirmed / Delivered / Cancelled

  OrderModel({
    required this.id,
    required this.orderNo,
    required this.studentName,
    required this.college,
    required this.owner,
    required this.tiffin,
    required this.quantity,
    required this.totalAmount,
    required this.orderDate,
    this.status = 'Pending',
  });

  bool get isPending => status == 'Pending';
  bool get isConfirmed => status == 'Confirmed';
  bool get isDelivered => status == 'Delivered';
  bool get isCancelled => status == 'Cancelled';
}

enum _RightMode { create, edit, view }

// ═══════════════════════════════════════════════
//  ORDER CARD
// ═══════════════════════════════════════════════
class OrderCard extends StatefulWidget {
  const OrderCard({super.key});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  final _formKey = GlobalKey<FormState>();
  final _orderNoCtrl = TextEditingController();
  final _studentCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  String? _selectedCollege;
  String? _selectedOwner;
  String? _selectedTiffin;
  String _status = 'Pending';
  DateTime _orderDate = DateTime.now();

  // ── Constants ──
  final List<String> _colleges = [
    'IIT Delhi',
    'AIIMS Delhi',
    "St. Xavier's College",
    'Delhi University',
  ];
  final List<String> _owners = [
    'Ramesh Kumar',
    'Suresh Sharma',
    'Priya Verma',
    'Anil Gupta',
  ];
  final List<String> _tiffins = [
    'Veg Deluxe Thali',
    'Chicken Combo',
    'Breakfast Light',
    'Premium Veg Combo',
  ];
  final List<String> _statuses = [
    'Pending',
    'Confirmed',
    'Delivered',
    'Cancelled',
  ];

  int _nextId = 5;
  int _nextOrderNo = 1005;

  final List<OrderModel> _orders = [
    OrderModel(
      id: 1,
      orderNo: 'ORD-1001',
      studentName: 'Aarav Sharma',
      college: 'IIT Delhi',
      owner: 'Ramesh Kumar',
      tiffin: 'Veg Deluxe Thali',
      quantity: 1,
      totalAmount: 2500,
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
      status: 'Delivered',
    ),
    OrderModel(
      id: 2,
      orderNo: 'ORD-1002',
      studentName: 'Diya Patel',
      college: 'AIIMS Delhi',
      owner: 'Suresh Sharma',
      tiffin: 'Chicken Combo',
      quantity: 1,
      totalAmount: 3200,
      orderDate: DateTime.now().subtract(const Duration(days: 1)),
      status: 'Confirmed',
    ),
    OrderModel(
      id: 3,
      orderNo: 'ORD-1003',
      studentName: 'Kabir Mehta',
      college: "St. Xavier's College",
      owner: 'Priya Verma',
      tiffin: 'Breakfast Light',
      quantity: 2,
      totalAmount: 1200,
      orderDate: DateTime.now(),
      status: 'Pending',
    ),
    OrderModel(
      id: 4,
      orderNo: 'ORD-1004',
      studentName: 'Isha Reddy',
      college: 'Delhi University',
      owner: 'Anil Gupta',
      tiffin: 'Premium Veg Combo',
      quantity: 1,
      totalAmount: 2800,
      orderDate: DateTime.now().subtract(const Duration(days: 3)),
      status: 'Cancelled',
    ),
  ];

  OrderModel? _selected;
  _RightMode _mode = _RightMode.create;
  String _search = '';
  bool _gridView = false;

  List<OrderModel> get _filtered {
    if (_search.trim().isEmpty) return _orders;
    final q = _search.toLowerCase();
    return _orders
        .where((o) =>
    o.orderNo.toLowerCase().contains(q) ||
        o.studentName.toLowerCase().contains(q) ||
        o.tiffin.toLowerCase().contains(q) ||
        o.owner.toLowerCase().contains(q) ||
        o.status.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _orderNoCtrl.dispose();
    _studentCtrl.dispose();
    _qtyCtrl.dispose();
    _amountCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════
  //  ACTIONS
  // ═══════════════════════════════════════════════
  void _startCreate() {
    setState(() {
      _mode = _RightMode.create;
      _selected = null;
      _orderNoCtrl.text = 'ORD-$_nextOrderNo';
      _studentCtrl.clear();
      _qtyCtrl.text = '1';
      _amountCtrl.clear();
      _selectedCollege = null;
      _selectedOwner = null;
      _selectedTiffin = null;
      _status = 'Pending';
      _orderDate = DateTime.now();
    });
  }

  void _startEdit(OrderModel o) {
    setState(() {
      _mode = _RightMode.edit;
      _selected = o;
      _orderNoCtrl.text = o.orderNo;
      _studentCtrl.text = o.studentName;
      _qtyCtrl.text = o.quantity.toString();
      _amountCtrl.text = o.totalAmount.toStringAsFixed(0);
      _selectedCollege = o.college;
      _selectedOwner = o.owner;
      _selectedTiffin = o.tiffin;
      _status = o.status;
      _orderDate = o.orderDate;
    });
  }

  void _startView(OrderModel o) {
    setState(() {
      _mode = _RightMode.view;
      _selected = o;
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      if (_mode == _RightMode.edit && _selected != null) {
        _selected!
          ..orderNo = _orderNoCtrl.text.trim()
          ..studentName = _studentCtrl.text.trim()
          ..college = _selectedCollege!
          ..owner = _selectedOwner!
          ..tiffin = _selectedTiffin!
          ..quantity = int.parse(_qtyCtrl.text.trim())
          ..totalAmount = double.parse(_amountCtrl.text.trim())
          ..orderDate = _orderDate
          ..status = _status;
      } else {
        _orders.insert(
          0,
          OrderModel(
            id: _nextId++,
            orderNo: _orderNoCtrl.text.trim(),
            studentName: _studentCtrl.text.trim(),
            college: _selectedCollege!,
            owner: _selectedOwner!,
            tiffin: _selectedTiffin!,
            quantity: int.parse(_qtyCtrl.text.trim()),
            totalAmount: double.parse(_amountCtrl.text.trim()),
            orderDate: _orderDate,
            status: _status,
          ),
        );
        _nextOrderNo++;
      }
    });

    Fluttertoast.showToast(
      msg: _mode == _RightMode.edit ? 'Order updated.' : 'Order added.',
      backgroundColor: AppColor.primary,
      textColor: AppColor.white,
    );

    _startCreate();
  }

  void _updateStatus(OrderModel o, String newStatus) {
    setState(() => o.status = newStatus);
    Fluttertoast.showToast(
      msg: 'Status → $newStatus',
      backgroundColor: _statusColor(newStatus),
      textColor: AppColor.white,
    );
  }

  void _delete(OrderModel o) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Order',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColor.black)),
        content: Text('Delete order "${o.orderNo}"?',
            style: const TextStyle(fontSize: 14, color: Colors.grey)),
        actionsPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _orders.removeWhere((x) => x.id == o.id);
                if (_selected?.id == o.id) _startCreate();
              });
              Navigator.pop(ctx);
              Fluttertoast.showToast(
                msg: 'Order deleted.',
                backgroundColor: AppColor.red,
                textColor: AppColor.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.red,
              foregroundColor: AppColor.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── Date picker ──
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _orderDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppColor.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _orderDate = picked);
  }

  String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFD97706); // amber
      case 'Confirmed':
        return const Color(0xFF2563EB); // blue
      case 'Delivered':
        return const Color(0xFF059669); // green
      case 'Cancelled':
        return const Color(0xFFDC2626); // red
      default:
        return AppColor.primary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.schedule_rounded;
      case 'Confirmed':
        return Icons.check_circle_outline_rounded;
      case 'Delivered':
        return Icons.local_shipping_rounded;
      case 'Cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  // ═══════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    return Column(
                      children: [
                        Expanded(flex: 2, child: _buildLeftList()),
                        const SizedBox(height: 12),
                        Expanded(flex: 3, child: _buildRightPanel()),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _buildLeftList()),
                      const SizedBox(width: 20),
                      SizedBox(width: 400, child: _buildRightPanel()),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  HEADER + STAT PILLS
  // ═══════════════════════════════════════════════
  Widget _buildHeader() {
    final total = _orders.length;
    final pending =
        _orders.where((o) => o.status == 'Pending').length;
    final delivered =
        _orders.where((o) => o.status == 'Delivered').length;
    final revenue = _orders
        .where((o) => o.status != 'Cancelled')
        .fold<double>(0, (s, o) => s + o.totalAmount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Order Management',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.black),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _startCreate,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Order'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: AppColor.white,
                elevation: 0,
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _statPill('Total: $total', AppColor.primary),
            _statPill('Pending: $pending', const Color(0xFFD97706)),
            _statPill('Delivered: $delivered', const Color(0xFF059669)),
            _statPill('Revenue: ₹${revenue.toStringAsFixed(0)}',
                const Color(0xFF2563EB)),
          ],
        ),
      ],
    );
  }

  Widget _statPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color)),
    );
  }

  // ═══════════════════════════════════════════════
  //  LEFT SIDE — LIST / GRID
  // ═══════════════════════════════════════════════
  Widget _buildLeftList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _search = v),
                    decoration: InputDecoration(
                      hintText: 'Search orders...',
                      hintStyle: TextStyle(
                          color: Colors.grey.shade500, fontSize: 13),
                      prefixIcon: Icon(Icons.search,
                          size: 20, color: Colors.grey.shade600),
                      filled: true,
                      fillColor: AppColor.bg,
                      isDense: true,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColor.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColor.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: AppColor.primary, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColor.bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColor.border),
                  ),
                  child: Row(
                    children: [
                      _viewToggleBtn(Icons.view_list_rounded, !_gridView,
                              () => setState(() => _gridView = false)),
                      _viewToggleBtn(Icons.grid_view_rounded, _gridView,
                              () => setState(() => _gridView = true)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColor.border),
          Expanded(
            child: _filtered.isEmpty
                ? _emptyState()
                : (_gridView ? _buildGrid() : _buildList()),
          ),
        ],
      ),
    );
  }

  Widget _viewToggleBtn(IconData icon, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColor.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            size: 18,
            color: active ? AppColor.white : Colors.grey.shade600),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(status), size: 10, color: color),
          const SizedBox(width: 4),
          Text(status,
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final o = _filtered[i];
        final isSelected = _selected?.id == o.id;
        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _startView(o),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColor.primary.withOpacity(0.05)
                  : AppColor.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColor.primary : AppColor.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _statusColor(o.status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.receipt_long_rounded,
                      color: _statusColor(o.status), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(o.orderNo,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.black)),
                          ),
                          const SizedBox(width: 6),
                          _statusBadge(o.status),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('${o.studentName} • ${o.tiffin}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text('₹${o.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColor.primary)),
                IconButton(
                  onPressed: () => _startEdit(o),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  color: AppColor.primary,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () => _delete(o),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  color: AppColor.red,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth > 700
            ? 3
            : (constraints.maxWidth > 450 ? 2 : 1);
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.15,
          ),
          itemCount: _filtered.length,
          itemBuilder: (context, i) {
            final o = _filtered[i];
            final isSelected = _selected?.id == o.id;
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _startView(o),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColor.primary.withOpacity(0.05)
                      : AppColor.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColor.primary : AppColor.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _statusColor(o.status)
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.receipt_long_rounded,
                              size: 18,
                              color: _statusColor(o.status)),
                        ),
                        const Spacer(),
                        _statusBadge(o.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(o.orderNo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColor.black)),
                    const SizedBox(height: 2),
                    Text(o.studentName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600)),
                    Text(o.tiffin,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColor.black)),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('₹${o.totalAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColor.primary)),
                        Text('×${o.quantity}',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600)),
                        Row(
                          children: [
                            InkWell(
                              onTap: () => _startEdit(o),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.edit_outlined,
                                    size: 16, color: AppColor.primary),
                              ),
                            ),
                            InkWell(
                              onTap: () => _delete(o),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.delete_outline,
                                    size: 16, color: AppColor.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 48, color: AppColor.primary.withOpacity(0.3)),
          const SizedBox(height: 10),
          const Text('No orders found',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.black)),
          const SizedBox(height: 4),
          Text(
            _search.isEmpty
                ? 'Click "Add Order" to create one'
                : 'Try a different search term',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  RIGHT SIDE — FORM / VIEW
  // ═══════════════════════════════════════════════
  Widget _buildRightPanel() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.border),
      ),
      child:
      _mode == _RightMode.view ? _buildViewCard() : _buildFormCard(),
    );
  }

  Widget _buildViewCard() {
    final o = _selected!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Order Details',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColor.black)),
              ),
              IconButton(
                onPressed: _startCreate,
                icon: const Icon(Icons.close, size: 18),
                tooltip: 'Close',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _statusColor(o.status).withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.receipt_long_rounded,
                  color: _statusColor(o.status), size: 36),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(o.orderNo,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.black)),
          ),
          const SizedBox(height: 8),
          Center(child: _statusBadge(o.status)),
          const SizedBox(height: 20),

          // Quick status change buttons
          const Text('Update Status',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColor.black)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _statuses.map((s) {
              final isCurrent = s == o.status;
              final color = _statusColor(s);
              return GestureDetector(
                onTap: isCurrent
                    ? null
                    : () => _updateStatus(o, s),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? color
                        : color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: color.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(s),
                          size: 12,
                          color: isCurrent ? Colors.white : color),
                      const SizedBox(width: 4),
                      Text(s,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color:
                              isCurrent ? Colors.white : color)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          _viewRow(Icons.person_outline, 'Student', o.studentName),
          _viewRow(Icons.school_outlined, 'College', o.college),
          _viewRow(Icons.storefront_outlined, 'Owner', o.owner),
          _viewRow(Icons.lunch_dining_outlined, 'Tiffin', o.tiffin),
          _viewRow(Icons.numbers_outlined, 'Quantity', '×${o.quantity}'),
          _viewRow(Icons.currency_rupee_outlined, 'Total Amount',
              '₹${o.totalAmount.toStringAsFixed(0)}'),
          _viewRow(
              Icons.calendar_today_outlined, 'Order Date', _fmtDate(o.orderDate)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _startEdit(o),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.primary,
                    side: BorderSide(color: AppColor.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _delete(o),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.red,
                    side: BorderSide(color: AppColor.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _viewRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColor.border),
            ),
            child: Icon(icon, size: 16, color: AppColor.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColor.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    final isEdit = _mode == _RightMode.edit;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    isEdit ? 'Edit Order' : 'Create Order',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColor.black),
                  ),
                ),
                if (isEdit)
                  IconButton(
                    onPressed: _startCreate,
                    icon: const Icon(Icons.close, size: 18),
                    tooltip: 'Cancel edit',
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Order No + Date
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label('Order Number'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _orderNoCtrl,
                        decoration: _inputDecoration('ORD-1001'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Required'
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label('Order Date'),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 13),
                          decoration: BoxDecoration(
                            color: AppColor.bg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColor.border),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_outlined,
                                  size: 14,
                                  color: Colors.grey.shade600),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(_fmtDate(_orderDate),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColor.black)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Student name
            _label('Student Name'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _studentCtrl,
              decoration: _inputDecoration('e.g. Aarav Sharma'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (v.trim().length < 2) return 'Minimum 2 characters';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // College
            _label('College'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedCollege,
              decoration: _inputDecoration('Select college'),
              items: _colleges
                  .map((c) => DropdownMenuItem(
                value: c,
                child:
                Text(c, style: const TextStyle(fontSize: 13)),
              ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCollege = v),
              validator: (v) =>
              v == null ? 'College is required' : null,
            ),
            const SizedBox(height: 14),

            // Owner + Tiffin
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label('Owner'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedOwner,
                        decoration: _inputDecoration('Select'),
                        items: _owners
                            .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c,
                              style:
                              const TextStyle(fontSize: 13)),
                        ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedOwner = v),
                        validator: (v) =>
                        v == null ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label('Tiffin'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedTiffin,
                        decoration: _inputDecoration('Select'),
                        items: _tiffins
                            .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c,
                              overflow: TextOverflow.ellipsis,
                              style:
                              const TextStyle(fontSize: 13)),
                        ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedTiffin = v),
                        validator: (v) =>
                        v == null ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Quantity + Amount
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label('Quantity'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _qtyCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('1'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Required';
                          }
                          final n = int.tryParse(v.trim());
                          if (n == null || n <= 0) return 'Invalid';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label('Total Amount (₹)'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _amountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('e.g. 2500'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Required';
                          }
                          final p = double.tryParse(v.trim());
                          if (p == null || p < 0) return 'Invalid';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Status
            _label('Status'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: _inputDecoration('Select status'),
              items: _statuses
                  .map((s) => DropdownMenuItem(
                value: s,
                child: Row(
                  children: [
                    Icon(_statusIcon(s),
                        size: 14, color: _statusColor(s)),
                    const SizedBox(width: 6),
                    Text(s,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _statusColor(s))),
                  ],
                ),
              ))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _status = v ?? 'Pending'),
            ),
            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                if (isEdit)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _startCreate,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        side: BorderSide(color: AppColor.border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                if (isEdit) const SizedBox(width: 8),
                Expanded(
                  flex: isEdit ? 2 : 1,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: AppColor.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      isEdit ? 'Update Order' : 'Create Order',
                      style:
                      const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColor.black),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle:
    TextStyle(color: Colors.grey.shade500, fontSize: 13),
    filled: true,
    fillColor: AppColor.bg,
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColor.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColor.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColor.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColor.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColor.red),
    ),
  );
}