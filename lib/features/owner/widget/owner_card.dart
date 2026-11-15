import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/utils/app_color.dart';

// ═══════════════════════════════════════════════
//  MODEL
// ═══════════════════════════════════════════════
class OwnerModel {
  int id;
  String name;
  String email;
  String phone;
  String college;
  String address;
  int roomsOwned;
  bool isActive;

  OwnerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.college,
    required this.address,
    required this.roomsOwned,
    this.isActive = true,
  });
}

enum _RightMode { create, edit, view }

// ═══════════════════════════════════════════════
//  OWNER CARD
// ═══════════════════════════════════════════════
class OwnerCard extends StatefulWidget {
  const OwnerCard({super.key});

  @override
  State<OwnerCard> createState() => _OwnerCardState();
}

class _OwnerCardState extends State<OwnerCard> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _roomsCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  String? _selectedCollege;
  bool _isActive = true;

  // ── Constants ──
  final List<String> _colleges = [
    'IIT Delhi',
    'AIIMS Delhi',
    "St. Xavier's College",
    'Delhi University',
  ];

  int _nextId = 4;
  final List<OwnerModel> _owners = [
    OwnerModel(
      id: 1,
      name: 'Ramesh Kumar',
      email: 'ramesh@gmail.com',
      phone: '+91 98765 43210',
      college: 'IIT Delhi',
      address: 'H-12, Hauz Khas, New Delhi',
      roomsOwned: 6,
    ),
    OwnerModel(
      id: 2,
      name: 'Suresh Sharma',
      email: 'suresh@gmail.com',
      phone: '+91 98765 43211',
      college: 'AIIMS Delhi',
      address: 'B-45, Ansari Nagar, New Delhi',
      roomsOwned: 4,
    ),
    OwnerModel(
      id: 3,
      name: 'Priya Verma',
      email: 'priya@gmail.com',
      phone: '+91 98765 43212',
      college: "St. Xavier's College",
      address: 'C-8, Fort Area, Mumbai',
      roomsOwned: 3,
      isActive: false,
    ),
  ];

  OwnerModel? _selected;
  _RightMode _mode = _RightMode.create;
  String _search = '';
  bool _gridView = false;

  List<OwnerModel> get _filtered {
    if (_search.trim().isEmpty) return _owners;
    final q = _search.toLowerCase();
    return _owners
        .where((o) =>
    o.name.toLowerCase().contains(q) ||
        o.email.toLowerCase().contains(q) ||
        o.phone.toLowerCase().contains(q) ||
        o.college.toLowerCase().contains(q))
        .toList();
  }

  int get _totalRooms =>
      _owners.fold(0, (sum, o) => sum + o.roomsOwned);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _roomsCtrl.dispose();
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
      _emailCtrl.clear();
      _phoneCtrl.clear();
      _addressCtrl.clear();
      _roomsCtrl.clear();
      _selectedCollege = null;
      _isActive = true;
    });
  }

  void _startEdit(OwnerModel o) {
    setState(() {
      _mode = _RightMode.edit;
      _selected = o;
      _nameCtrl.text = o.name;
      _emailCtrl.text = o.email;
      _phoneCtrl.text = o.phone;
      _addressCtrl.text = o.address;
      _roomsCtrl.text = o.roomsOwned.toString();
      _selectedCollege = o.college;
      _isActive = o.isActive;
    });
  }

  void _startView(OwnerModel o) {
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
          ..name = _nameCtrl.text.trim()
          ..email = _emailCtrl.text.trim()
          ..phone = _phoneCtrl.text.trim()
          ..college = _selectedCollege!
          ..address = _addressCtrl.text.trim()
          ..roomsOwned = int.parse(_roomsCtrl.text.trim())
          ..isActive = _isActive;
      } else {
        _owners.insert(
          0,
          OwnerModel(
            id: _nextId++,
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            college: _selectedCollege!,
            address: _addressCtrl.text.trim(),
            roomsOwned: int.parse(_roomsCtrl.text.trim()),
            isActive: _isActive,
          ),
        );
      }
    });

    Fluttertoast.showToast(
      msg: _mode == _RightMode.edit ? 'Owner updated.' : 'Owner added.',
      backgroundColor: AppColor.primary,
      textColor: AppColor.white,
    );

    _startCreate();
  }

  void _delete(OwnerModel o) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Owner',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColor.black)),
        content: Text('Delete "${o.name}"?',
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
                _owners.removeWhere((x) => x.id == o.id);
                if (_selected?.id == o.id) _startCreate();
              });
              Navigator.pop(ctx);
              Fluttertoast.showToast(
                msg: 'Owner deleted.',
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
    final total = _owners.length;
    final active = _owners.where((o) => o.isActive).length;
    final inactive = total - active;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Owner Management',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.black),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _startCreate,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Owner'),
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
            _statPill('Active: $active', const Color(0xFF059669)),
            _statPill('Inactive: $inactive', const Color(0xFFDC2626)),
            _statPill('Rooms: $_totalRooms', const Color(0xFF2563EB)),
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
                      hintText: 'Search owners...',
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

  Widget _avatar(String name, {double size = 40}) {
    final initial =
    name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      alignment: Alignment.center,
      child: Text(initial,
          style: TextStyle(
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
              color: AppColor.primary)),
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
                _avatar(o.name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(o.name,
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
                              color: const Color(0xFF2563EB)
                                  .withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('${o.roomsOwned} rooms',
                                style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2563EB))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('${o.college} • ${o.phone}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                _statusDot(o.isActive),
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
            childAspectRatio: 1.35,
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
                        _avatar(o.name, size: 36),
                        const Spacer(),
                        _statusDot(o.isActive),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(o.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColor.black)),
                    const SizedBox(height: 2),
                    Text(o.college,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600)),
                    const SizedBox(height: 2),
                    Text(o.phone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600)),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB)
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('${o.roomsOwned} rooms',
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2563EB))),
                        ),
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

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_outline,
              size: 48, color: AppColor.primary.withOpacity(0.3)),
          const SizedBox(height: 10),
          const Text('No owners found',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.black)),
          const SizedBox(height: 4),
          Text(
            _search.isEmpty
                ? 'Click "Add Owner" to create one'
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
                child: Text('Owner Details',
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
          Center(child: _avatar(o.name, size: 72)),
          const SizedBox(height: 16),
          Center(
            child: Text(o.name,
                textAlign: TextAlign.center,
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
                color: const Color(0xFF2563EB).withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('${o.roomsOwned} rooms owned',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: Color(0xFF2563EB))),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: o.isActive
                    ? const Color(0xFF059669).withOpacity(0.12)
                    : const Color(0xFFDC2626).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                o.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: o.isActive
                      ? const Color(0xFF059669)
                      : const Color(0xFFDC2626),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _viewRow(Icons.email_outlined, 'Email', o.email),
          _viewRow(Icons.phone_outlined, 'Phone', o.phone),
          _viewRow(Icons.school_outlined, 'College', o.college),
          const SizedBox(height: 4),
          const Text('Address',
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
            child: Text(o.address,
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
                    isEdit ? 'Edit Owner' : 'Create Owner',
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

            _label('Full Name'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameCtrl,
              decoration: _inputDecoration('e.g. Ramesh Kumar'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (v.trim().length < 2) return 'Minimum 2 characters';
                return null;
              },
            ),
            const SizedBox(height: 14),

            _label('Email'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration('owner@email.com'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email required';
                final ok = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$')
                    .hasMatch(v.trim());
                if (!ok) return 'Enter valid email';
                return null;
              },
            ),
            const SizedBox(height: 14),

            _label('Phone'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('+91 98765 43210'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Phone required';
                }
                if (v.trim().length < 10) return 'Min 10 digits';
                return null;
              },
            ),
            const SizedBox(height: 14),

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

            _label('Rooms Owned'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _roomsCtrl,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('e.g. 6'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                final n = int.tryParse(v.trim());
                if (n == null || n < 0) return 'Invalid';
                return null;
              },
            ),
            const SizedBox(height: 14),

            _label('Address'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _addressCtrl,
              maxLines: 3,
              decoration: _inputDecoration('Full address'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Address is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

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
                      isEdit ? 'Update Owner' : 'Create Owner',
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