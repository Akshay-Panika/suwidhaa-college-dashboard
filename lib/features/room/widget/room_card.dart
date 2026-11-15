import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/utils/app_color.dart';

// ═══════════════════════════════════════════════
//  MODEL
// ═══════════════════════════════════════════════
class RoomModel {
  int id;
  String roomNumber;
  String college;
  int floor;
  String type; // Single / Double / Triple / Dormitory
  double rent;
  int capacity;
  int occupied;
  bool isActive;

  RoomModel({
    required this.id,
    required this.roomNumber,
    required this.college,
    required this.floor,
    required this.type,
    required this.rent,
    required this.capacity,
    required this.occupied,
    this.isActive = true,
  });

  bool get isFull => occupied >= capacity;
}

enum _RightMode { create, edit, view }

// ═══════════════════════════════════════════════
//  ROOM CARD
// ═══════════════════════════════════════════════
class RoomCard extends StatefulWidget {
  const RoomCard({super.key});

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  final _formKey = GlobalKey<FormState>();
  final _roomNoCtrl = TextEditingController();
  final _floorCtrl = TextEditingController();
  final _rentCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _occupiedCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  String? _selectedCollege;
  String _selectedType = 'Single';
  bool _isActive = true;

  // ── Constants ──
  final List<String> _colleges = [
    'IIT Delhi',
    'AIIMS Delhi',
    "St. Xavier's College",
    'Delhi University',
  ];
  final List<String> _types = ['Single', 'Double', 'Triple', 'Dormitory'];

  int _nextId = 4;
  final List<RoomModel> _rooms = [
    RoomModel(
      id: 1,
      roomNumber: 'A-101',
      college: 'IIT Delhi',
      floor: 1,
      type: 'Single',
      rent: 8000,
      capacity: 1,
      occupied: 1,
    ),
    RoomModel(
      id: 2,
      roomNumber: 'A-102',
      college: 'IIT Delhi',
      floor: 1,
      type: 'Double',
      rent: 6000,
      capacity: 2,
      occupied: 1,
    ),
    RoomModel(
      id: 3,
      roomNumber: 'B-201',
      college: 'AIIMS Delhi',
      floor: 2,
      type: 'Triple',
      rent: 4500,
      capacity: 3,
      occupied: 3,
      isActive: false,
    ),
  ];

  RoomModel? _selected;
  _RightMode _mode = _RightMode.create;
  String _search = '';
  bool _gridView = false;

  List<RoomModel> get _filtered {
    if (_search.trim().isEmpty) return _rooms;
    final q = _search.toLowerCase();
    return _rooms
        .where((r) =>
    r.roomNumber.toLowerCase().contains(q) ||
        r.college.toLowerCase().contains(q) ||
        r.type.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _roomNoCtrl.dispose();
    _floorCtrl.dispose();
    _rentCtrl.dispose();
    _capacityCtrl.dispose();
    _occupiedCtrl.dispose();
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
      _roomNoCtrl.clear();
      _floorCtrl.clear();
      _rentCtrl.clear();
      _capacityCtrl.clear();
      _occupiedCtrl.clear();
      _selectedCollege = null;
      _selectedType = 'Single';
      _isActive = true;
    });
  }

  void _startEdit(RoomModel r) {
    setState(() {
      _mode = _RightMode.edit;
      _selected = r;
      _roomNoCtrl.text = r.roomNumber;
      _floorCtrl.text = r.floor.toString();
      _rentCtrl.text = r.rent.toStringAsFixed(0);
      _capacityCtrl.text = r.capacity.toString();
      _occupiedCtrl.text = r.occupied.toString();
      _selectedCollege = r.college;
      _selectedType = r.type;
      _isActive = r.isActive;
    });
  }

  void _startView(RoomModel r) {
    setState(() {
      _mode = _RightMode.view;
      _selected = r;
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final capacity = int.parse(_capacityCtrl.text.trim());
    final occupied = int.tryParse(_occupiedCtrl.text.trim()) ?? 0;

    if (occupied > capacity) {
      Fluttertoast.showToast(
        msg: 'Occupied cannot exceed capacity.',
        backgroundColor: AppColor.red,
        textColor: AppColor.white,
      );
      return;
    }

    setState(() {
      if (_mode == _RightMode.edit && _selected != null) {
        _selected!
          ..roomNumber = _roomNoCtrl.text.trim().toUpperCase()
          ..college = _selectedCollege!
          ..floor = int.parse(_floorCtrl.text.trim())
          ..type = _selectedType
          ..rent = double.parse(_rentCtrl.text.trim())
          ..capacity = capacity
          ..occupied = occupied
          ..isActive = _isActive;
      } else {
        _rooms.insert(
          0,
          RoomModel(
            id: _nextId++,
            roomNumber: _roomNoCtrl.text.trim().toUpperCase(),
            college: _selectedCollege!,
            floor: int.parse(_floorCtrl.text.trim()),
            type: _selectedType,
            rent: double.parse(_rentCtrl.text.trim()),
            capacity: capacity,
            occupied: occupied,
            isActive: _isActive,
          ),
        );
      }
    });

    Fluttertoast.showToast(
      msg: _mode == _RightMode.edit ? 'Room updated.' : 'Room added.',
      backgroundColor: AppColor.primary,
      textColor: AppColor.white,
    );

    _startCreate();
  }

  void _delete(RoomModel r) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Room',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColor.black)),
        content: Text('Delete room "${r.roomNumber}"?',
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
                _rooms.removeWhere((x) => x.id == r.id);
                if (_selected?.id == r.id) _startCreate();
              });
              Navigator.pop(ctx);
              Fluttertoast.showToast(
                msg: 'Room deleted.',
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
    final total = _rooms.length;
    final available = _rooms.where((r) => !r.isFull).length;
    final full = _rooms.where((r) => r.isFull).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Room Management',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.black),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _startCreate,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Room'),
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
            _statPill('Available: $available', const Color(0xFF059669)),
            _statPill('Full: $full', const Color(0xFFDC2626)),
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
                      hintText: 'Search rooms...',
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
        final r = _filtered[i];
        final isSelected = _selected?.id == r.id;
        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _startView(r),
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
                  child: Icon(Icons.meeting_room_rounded,
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
                            child: Text('Room ${r.roomNumber}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.black)),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColor.primary.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(r.type,
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    color: AppColor.primary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('${r.college} • ₹${r.rent.toStringAsFixed(0)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                _occupancyBadge(r),
                IconButton(
                  onPressed: () => _startEdit(r),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  color: AppColor.primary,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () => _delete(r),
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
            childAspectRatio: 1.4,
          ),
          itemCount: _filtered.length,
          itemBuilder: (context, i) {
            final r = _filtered[i];
            final isSelected = _selected?.id == r.id;
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _startView(r),
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
                          child: Icon(Icons.meeting_room_rounded,
                              size: 18, color: AppColor.primary),
                        ),
                        const Spacer(),
                        _occupancyBadge(r),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('Room ${r.roomNumber}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColor.black)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColor.primary.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(r.type,
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: AppColor.primary)),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(r.college,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600)),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('₹${r.rent.toStringAsFixed(0)}/mo',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColor.primary,
                                fontWeight: FontWeight.w700)),
                        Row(
                          children: [
                            InkWell(
                              onTap: () => _startEdit(r),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.edit_outlined,
                                    size: 16, color: AppColor.primary),
                              ),
                            ),
                            InkWell(
                              onTap: () => _delete(r),
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

  Widget _occupancyBadge(RoomModel r) {
    final color = r.isFull
        ? const Color(0xFFDC2626)
        : (r.occupied == 0
        ? const Color(0xFF059669)
        : const Color(0xFFD97706));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${r.occupied}/${r.capacity}',
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.meeting_room_outlined,
              size: 48, color: AppColor.primary.withOpacity(0.3)),
          const SizedBox(height: 10),
          const Text('No rooms found',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.black)),
          const SizedBox(height: 4),
          Text(
            _search.isEmpty
                ? 'Click "Add Room" to create one'
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
    final r = _selected!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Room Details',
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
              child: Icon(Icons.meeting_room_rounded,
                  color: AppColor.primary, size: 36),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text('Room ${r.roomNumber}',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.black)),
          ),
          const SizedBox(height: 6),
          Center(
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(r.type,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppColor.primary)),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: r.isActive
                    ? const Color(0xFF059669).withOpacity(0.12)
                    : const Color(0xFFDC2626).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                r.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: r.isActive
                      ? const Color(0xFF059669)
                      : const Color(0xFFDC2626),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _viewRow(Icons.school_outlined, 'College', r.college),
          _viewRow(Icons.stairs_outlined, 'Floor', 'Floor ${r.floor}'),
          _viewRow(Icons.currency_rupee_outlined, 'Monthly Rent',
              '₹${r.rent.toStringAsFixed(0)}'),
          _viewRow(Icons.people_outline, 'Occupancy',
              '${r.occupied} of ${r.capacity}'),
          const SizedBox(height: 4),
          // Occupancy bar
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: r.capacity == 0 ? 0 : r.occupied / r.capacity,
              minHeight: 8,
              backgroundColor: AppColor.bg,
              valueColor: AlwaysStoppedAnimation<Color>(
                r.isFull
                    ? const Color(0xFFDC2626)
                    : (r.occupied == 0
                    ? const Color(0xFF059669)
                    : const Color(0xFFD97706)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _startEdit(r),
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
                  onPressed: () => _delete(r),
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
                    isEdit ? 'Edit Room' : 'Create Room',
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

            // Room number + Floor
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label('Room Number'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _roomNoCtrl,
                        textCapitalization:
                        TextCapitalization.characters,
                        decoration: _inputDecoration('e.g. A-101'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
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
                      _label('Floor'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _floorCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('e.g. 1'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Required';
                          }
                          final n = int.tryParse(v.trim());
                          if (n == null || n < 0) return 'Invalid';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
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

            // Type dropdown
            _label('Room Type'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: _inputDecoration('Select type'),
              items: _types
                  .map((t) => DropdownMenuItem(
                value: t,
                child: Text(t,
                    style: const TextStyle(fontSize: 13)),
              ))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _selectedType = v ?? 'Single'),
            ),
            const SizedBox(height: 14),

            // Rent
            _label('Monthly Rent (₹)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _rentCtrl,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('e.g. 8000'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                final r = double.tryParse(v.trim());
                if (r == null || r <= 0) return 'Enter valid amount';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Capacity + Occupied
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label('Capacity'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _capacityCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('e.g. 2'),
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
                      _label('Occupied'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _occupiedCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('e.g. 1'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Required';
                          }
                          final n = int.tryParse(v.trim());
                          if (n == null || n < 0) return 'Invalid';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
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
                      isEdit ? 'Update Room' : 'Create Room',
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