import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/utils/app_color.dart';

// ═══════════════════════════════════════════════
//  MODEL
// ═══════════════════════════════════════════════
class TiffinModel {
  int id;
  String name;
  String college;
  String mealType; // Veg / Non-Veg / Mixed
  String mealTime; // Breakfast / Lunch / Dinner
  String duration; // Daily / Weekly / Monthly
  double price;
  String description;
  bool isActive;

  TiffinModel({
    required this.id,
    required this.name,
    required this.college,
    required this.mealType,
    required this.mealTime,
    required this.duration,
    required this.price,
    required this.description,
    this.isActive = true,
  });
}

enum _RightMode { create, edit, view }

// ═══════════════════════════════════════════════
//  TIFFIN CARD
// ═══════════════════════════════════════════════
class TiffinCard extends StatefulWidget {
  const TiffinCard({super.key});

  @override
  State<TiffinCard> createState() => _TiffinCardState();
}

class _TiffinCardState extends State<TiffinCard> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  String? _selectedCollege;
  String _mealType = 'Veg';
  String _mealTime = 'Lunch';
  String _duration = 'Monthly';
  bool _isActive = true;

  // ── Constants ──
  final List<String> _colleges = [
    'IIT Delhi',
    'AIIMS Delhi',
    "St. Xavier's College",
    'Delhi University',
  ];
  final List<String> _mealTypes = ['Veg', 'Non-Veg', 'Mixed'];
  final List<String> _mealTimes = ['Breakfast', 'Lunch', 'Dinner'];
  final List<String> _durations = ['Daily', 'Weekly', 'Monthly'];

  int _nextId = 4;
  final List<TiffinModel> _tiffins = [
    TiffinModel(
      id: 1,
      name: 'Veg Deluxe Thali',
      college: 'IIT Delhi',
      mealType: 'Veg',
      mealTime: 'Lunch',
      duration: 'Monthly',
      price: 2500,
      description:
      '4 rotis, dal, sabzi, rice, salad, curd, and sweet.',
    ),
    TiffinModel(
      id: 2,
      name: 'Chicken Combo',
      college: 'AIIMS Delhi',
      mealType: 'Non-Veg',
      mealTime: 'Dinner',
      duration: 'Monthly',
      price: 3200,
      description:
      'Chicken curry, 3 rotis, rice, salad, and dessert.',
    ),
    TiffinModel(
      id: 3,
      name: 'Breakfast Light',
      college: "St. Xavier's College",
      mealType: 'Veg',
      mealTime: 'Breakfast',
      duration: 'Weekly',
      price: 600,
      description: 'Poha/upma + tea/coffee + fruit.',
      isActive: false,
    ),
  ];

  TiffinModel? _selected;
  _RightMode _mode = _RightMode.create;
  String _search = '';
  bool _gridView = false;

  List<TiffinModel> get _filtered {
    if (_search.trim().isEmpty) return _tiffins;
    final q = _search.toLowerCase();
    return _tiffins
        .where((t) =>
    t.name.toLowerCase().contains(q) ||
        t.college.toLowerCase().contains(q) ||
        t.mealType.toLowerCase().contains(q) ||
        t.mealTime.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
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
      _nameCtrl.clear();
      _priceCtrl.clear();
      _descCtrl.clear();
      _selectedCollege = null;
      _mealType = 'Veg';
      _mealTime = 'Lunch';
      _duration = 'Monthly';
      _isActive = true;
    });
  }

  void _startEdit(TiffinModel t) {
    setState(() {
      _mode = _RightMode.edit;
      _selected = t;
      _nameCtrl.text = t.name;
      _priceCtrl.text = t.price.toStringAsFixed(0);
      _descCtrl.text = t.description;
      _selectedCollege = t.college;
      _mealType = t.mealType;
      _mealTime = t.mealTime;
      _duration = t.duration;
      _isActive = t.isActive;
    });
  }

  void _startView(TiffinModel t) {
    setState(() {
      _mode = _RightMode.view;
      _selected = t;
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      if (_mode == _RightMode.edit && _selected != null) {
        _selected!
          ..name = _nameCtrl.text.trim()
          ..college = _selectedCollege!
          ..mealType = _mealType
          ..mealTime = _mealTime
          ..duration = _duration
          ..price = double.parse(_priceCtrl.text.trim())
          ..description = _descCtrl.text.trim()
          ..isActive = _isActive;
      } else {
        _tiffins.insert(
          0,
          TiffinModel(
            id: _nextId++,
            name: _nameCtrl.text.trim(),
            college: _selectedCollege!,
            mealType: _mealType,
            mealTime: _mealTime,
            duration: _duration,
            price: double.parse(_priceCtrl.text.trim()),
            description: _descCtrl.text.trim(),
            isActive: _isActive,
          ),
        );
      }
    });

    Fluttertoast.showToast(
      msg: _mode == _RightMode.edit
          ? 'Tiffin updated.'
          : 'Tiffin added.',
      backgroundColor: AppColor.primary,
      textColor: AppColor.white,
    );

    _startCreate();
  }

  void _delete(TiffinModel t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Tiffin',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColor.black)),
        content: Text('Delete "${t.name}"?',
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
                _tiffins.removeWhere((x) => x.id == t.id);
                if (_selected?.id == t.id) _startCreate();
              });
              Navigator.pop(ctx);
              Fluttertoast.showToast(
                msg: 'Tiffin deleted.',
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
    final total = _tiffins.length;
    final veg = _tiffins.where((t) => t.mealType == 'Veg').length;
    final nonVeg = _tiffins.where((t) => t.mealType == 'Non-Veg').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Tiffin Management',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.black),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _startCreate,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Tiffin'),
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
            _statPill('Veg: $veg', const Color(0xFF059669)),
            _statPill('Non-Veg: $nonVeg', const Color(0xFFDC2626)),
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
                      hintText: 'Search tiffins...',
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

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final t = _filtered[i];
        final isSelected = _selected?.id == t.id;
        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _startView(t),
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
                    color: AppColor.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.lunch_dining_rounded,
                      color: AppColor.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(t.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.black)),
                          ),
                          const SizedBox(width: 6),
                          _mealTypeBadge(t.mealType),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                          '${t.college} • ${t.mealTime} • ₹${t.price.toStringAsFixed(0)}/${_durationShort(t.duration)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                _statusDot(t.isActive),
                IconButton(
                  onPressed: () => _startEdit(t),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  color: AppColor.primary,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () => _delete(t),
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
            childAspectRatio: 1.35,
          ),
          itemCount: _filtered.length,
          itemBuilder: (context, i) {
            final t = _filtered[i];
            final isSelected = _selected?.id == t.id;
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _startView(t),
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
                            color: AppColor.primary.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.lunch_dining_rounded,
                              size: 18, color: AppColor.primary),
                        ),
                        const Spacer(),
                        _statusDot(t.isActive),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(t.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColor.black)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _mealTypeBadge(t.mealType),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColor.primary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(t.mealTime,
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(t.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('₹${t.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColor.primary)),
                        Row(
                          children: [
                            InkWell(
                              onTap: () => _startEdit(t),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.edit_outlined,
                                    size: 16, color: AppColor.primary),
                              ),
                            ),
                            InkWell(
                              onTap: () => _delete(t),
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

  Widget _mealTypeBadge(String type) {
    final color = type == 'Veg'
        ? const Color(0xFF059669)
        : (type == 'Non-Veg'
        ? const Color(0xFFDC2626)
        : const Color(0xFFD97706));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration:
            BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(type,
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }

  Widget _statusDot(bool active) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
        active ? const Color(0xFF059669) : const Color(0xFFDC2626),
      ),
    );
  }

  String _durationShort(String d) {
    switch (d) {
      case 'Daily':
        return 'day';
      case 'Weekly':
        return 'week';
      default:
        return 'mo';
    }
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lunch_dining_outlined,
              size: 48, color: AppColor.primary.withOpacity(0.3)),
          const SizedBox(height: 10),
          const Text('No tiffins found',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.black)),
          const SizedBox(height: 4),
          Text(
            _search.isEmpty
                ? 'Click "Add Tiffin" to create one'
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
    final t = _selected!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Tiffin Details',
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
                color: AppColor.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.lunch_dining_rounded,
                  color: AppColor.primary, size: 36),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(t.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.black)),
          ),
          const SizedBox(height: 8),
          Center(child: _mealTypeBadge(t.mealType)),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: t.isActive
                    ? const Color(0xFF059669).withOpacity(0.12)
                    : const Color(0xFFDC2626).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                t.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: t.isActive
                      ? const Color(0xFF059669)
                      : const Color(0xFFDC2626),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _viewRow(Icons.school_outlined, 'College', t.college),
          _viewRow(Icons.restaurant_outlined, 'Meal Time', t.mealTime),
          _viewRow(Icons.calendar_month_outlined, 'Plan Duration',
              t.duration),
          _viewRow(
              Icons.currency_rupee_outlined,
              'Price',
              '₹${t.price.toStringAsFixed(0)} / ${_durationShort(t.duration)}'),
          const SizedBox(height: 4),
          const Text('Description',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColor.black)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColor.bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.border),
            ),
            child: Text(t.description,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                    height: 1.5)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _startEdit(t),
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
                  onPressed: () => _delete(t),
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
                    isEdit ? 'Edit Tiffin' : 'Create Tiffin',
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

            // Tiffin Name
            _label('Tiffin Name'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameCtrl,
              decoration: _inputDecoration('e.g. Veg Deluxe Thali'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (v.trim().length < 2) return 'Minimum 2 characters';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // College dropdown
            _label('College'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedCollege,
              decoration: _inputDecoration('Select college'),
              items: _colleges
                  .map((c) => DropdownMenuItem(
                value: c,
                child: Text(c,
                    style: const TextStyle(fontSize: 13)),
              ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCollege = v),
              validator: (v) =>
              v == null ? 'College is required' : null,
            ),
            const SizedBox(height: 14),

            // Meal Type + Meal Time
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label('Meal Type'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _mealType,
                        decoration:
                        _inputDecoration('Select type'),
                        items: _mealTypes
                            .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(m,
                              style: const TextStyle(
                                  fontSize: 13)),
                        ))
                            .toList(),
                        onChanged: (v) => setState(
                                () => _mealType = v ?? 'Veg'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label('Meal Time'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _mealTime,
                        decoration:
                        _inputDecoration('Select time'),
                        items: _mealTimes
                            .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(m,
                              style: const TextStyle(
                                  fontSize: 13)),
                        ))
                            .toList(),
                        onChanged: (v) => setState(
                                () => _mealTime = v ?? 'Lunch'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Duration + Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label('Duration'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _duration,
                        decoration:
                        _inputDecoration('Select duration'),
                        items: _durations
                            .map((d) => DropdownMenuItem(
                          value: d,
                          child: Text(d,
                              style: const TextStyle(
                                  fontSize: 13)),
                        ))
                            .toList(),
                        onChanged: (v) => setState(
                                () => _duration = v ?? 'Monthly'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label('Price (₹)'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('e.g. 2500'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Required';
                          }
                          final p = double.tryParse(v.trim());
                          if (p == null || p <= 0) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Description
            _label('Description'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration:
              _inputDecoration('What\'s included in the tiffin?'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Status toggle
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColor.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColor.border),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Active',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColor.black)),
                  ),
                  Switch(
                    value: _isActive,
                    activeColor: AppColor.primary,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                ],
              ),
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
                      isEdit ? 'Update Tiffin' : 'Create Tiffin',
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