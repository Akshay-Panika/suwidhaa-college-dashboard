import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/utils/app_color.dart';

// ═══════════════════════════════════════════════
//  MODEL
// ═══════════════════════════════════════════════
class CollegeModel {
  int id;
  String name;
  String code;
  String email;
  String phone;
  String city;
  int establishedYear;
  bool isActive;

  CollegeModel({
    required this.id,
    required this.name,
    required this.code,
    required this.email,
    required this.phone,
    required this.city,
    required this.establishedYear,
    this.isActive = true,
  });
}

enum _RightMode { create, edit, view }

// ═══════════════════════════════════════════════
//  COLLEGE CARD
// ═══════════════════════════════════════════════
class CollegeCard extends StatefulWidget {
  const CollegeCard({super.key});

  @override
  State<CollegeCard> createState() => _CollegeCardState();
}

class _CollegeCardState extends State<CollegeCard> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  bool _isActive = true;

  int _nextId = 4;
  final List<CollegeModel> _colleges = [
    CollegeModel(
      id: 1,
      name: 'IIT Delhi',
      code: 'IITD',
      email: 'admin@iitd.ac.in',
      phone: '+91 98765 43210',
      city: 'New Delhi',
      establishedYear: 1961,
    ),
    CollegeModel(
      id: 2,
      name: 'AIIMS Delhi',
      code: 'AIIMS',
      email: 'info@aiims.edu',
      phone: '+91 98765 43211',
      city: 'New Delhi',
      establishedYear: 1956,
    ),
    CollegeModel(
      id: 3,
      name: 'St. Xavier\'s College',
      code: 'SXC',
      email: 'principal@sxc.edu.in',
      phone: '+91 98765 43212',
      city: 'Mumbai',
      establishedYear: 1869,
      isActive: false,
    ),
  ];

  CollegeModel? _selected;
  _RightMode _mode = _RightMode.create;
  String _search = '';
  bool _gridView = false;

  List<CollegeModel> get _filtered {
    if (_search.trim().isEmpty) return _colleges;
    final q = _search.toLowerCase();
    return _colleges
        .where((c) =>
    c.name.toLowerCase().contains(q) ||
        c.code.toLowerCase().contains(q) ||
        c.city.toLowerCase().contains(q) ||
        c.email.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _yearCtrl.dispose();
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
      _codeCtrl.clear();
      _emailCtrl.clear();
      _phoneCtrl.clear();
      _cityCtrl.clear();
      _yearCtrl.clear();
      _isActive = true;
    });
  }

  void _startEdit(CollegeModel c) {
    setState(() {
      _mode = _RightMode.edit;
      _selected = c;
      _nameCtrl.text = c.name;
      _codeCtrl.text = c.code;
      _emailCtrl.text = c.email;
      _phoneCtrl.text = c.phone;
      _cityCtrl.text = c.city;
      _yearCtrl.text = c.establishedYear.toString();
      _isActive = c.isActive;
    });
  }

  void _startView(CollegeModel c) {
    setState(() {
      _mode = _RightMode.view;
      _selected = c;
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      if (_mode == _RightMode.edit && _selected != null) {
        _selected!
          ..name = _nameCtrl.text.trim()
          ..code = _codeCtrl.text.trim().toUpperCase()
          ..email = _emailCtrl.text.trim()
          ..phone = _phoneCtrl.text.trim()
          ..city = _cityCtrl.text.trim()
          ..establishedYear = int.parse(_yearCtrl.text.trim())
          ..isActive = _isActive;
      } else {
        _colleges.insert(
          0,
          CollegeModel(
            id: _nextId++,
            name: _nameCtrl.text.trim(),
            code: _codeCtrl.text.trim().toUpperCase(),
            email: _emailCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            city: _cityCtrl.text.trim(),
            establishedYear: int.parse(_yearCtrl.text.trim()),
            isActive: _isActive,
          ),
        );
      }
    });

    Fluttertoast.showToast(
      msg: _mode == _RightMode.edit
          ? 'College updated.'
          : 'College added.',
      backgroundColor: AppColor.primary,
      textColor: AppColor.white,
    );

    _startCreate();
  }

  void _delete(CollegeModel c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete College',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColor.black)),
        content: Text('Delete "${c.name}"?',
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
                _colleges.removeWhere((x) => x.id == c.id);
                if (_selected?.id == c.id) _startCreate();
              });
              Navigator.pop(ctx);
              Fluttertoast.showToast(
                msg: 'College deleted.',
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
    final total = _colleges.length;
    final active = _colleges.where((c) => c.isActive).length;
    final inactive = total - active;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'College Management',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.black),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _startCreate,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add College'),
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
                      hintText: 'Search colleges...',
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
        final c = _filtered[i];
        final isSelected = _selected?.id == c.id;
        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _startView(c),
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
                  child: Icon(Icons.school_rounded,
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
                            child: Text(c.name,
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
                            child: Text(c.code,
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    color: AppColor.primary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('${c.city} • Est. ${c.establishedYear}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                _statusDot(c.isActive),
                IconButton(
                  onPressed: () => _startEdit(c),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  color: AppColor.primary,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () => _delete(c),
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
            final c = _filtered[i];
            final isSelected = _selected?.id == c.id;
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _startView(c),
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
                          child: Icon(Icons.school_rounded,
                              size: 18, color: AppColor.primary),
                        ),
                        const Spacer(),
                        _statusDot(c.isActive),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(c.name,
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
                          child: Text(c.code,
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: AppColor.primary)),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(c.city,
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
                        Text('Est. ${c.establishedYear}',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500)),
                        Row(
                          children: [
                            InkWell(
                              onTap: () => _startEdit(c),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.edit_outlined,
                                    size: 16, color: AppColor.primary),
                              ),
                            ),
                            InkWell(
                              onTap: () => _delete(c),
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
          Icon(Icons.school_outlined,
              size: 48, color: AppColor.primary.withOpacity(0.3)),
          const SizedBox(height: 10),
          const Text('No colleges found',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.black)),
          const SizedBox(height: 4),
          Text(
            _search.isEmpty
                ? 'Click "Add College" to create one'
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
    final c = _selected!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('College Details',
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
              child: Icon(Icons.school_rounded,
                  color: AppColor.primary, size: 36),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(c.name,
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
                color: AppColor.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('Code: ${c.code}',
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
                color: c.isActive
                    ? const Color(0xFF059669).withOpacity(0.12)
                    : const Color(0xFFDC2626).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                c.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: c.isActive
                      ? const Color(0xFF059669)
                      : const Color(0xFFDC2626),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _viewRow(Icons.email_outlined, 'Email', c.email),
          _viewRow(Icons.phone_outlined, 'Phone', c.phone),
          _viewRow(Icons.location_city_outlined, 'City', c.city),
          _viewRow(Icons.calendar_today_outlined, 'Established',
              '${c.establishedYear}'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _startEdit(c),
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
                  onPressed: () => _delete(c),
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
                    isEdit ? 'Edit College' : 'Create College',
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

            // Name + Code (row)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label('College Name'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: _inputDecoration('e.g. IIT Delhi'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Name is required';
                          }
                          if (v.trim().length < 2) {
                            return 'Minimum 2 characters';
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
                      _label('Code'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _codeCtrl,
                        textCapitalization: TextCapitalization.characters,
                        decoration: _inputDecoration('e.g. IITD'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Required';
                          }
                          if (v.trim().length < 2) return 'Min 2';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Email
            _label('Email'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration('admin@college.edu'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email required';
                final ok = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$')
                    .hasMatch(v.trim());
                if (!ok) return 'Enter valid email';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Phone
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

            // City + Year (row)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label('City'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _cityCtrl,
                        decoration: _inputDecoration('e.g. Delhi'),
                        validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Required'
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label('Established Year'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _yearCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        decoration: _inputDecoration('e.g. 1961')
                            .copyWith(counterText: ''),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Required';
                          }
                          final y = int.tryParse(v.trim());
                          if (y == null) return 'Invalid';
                          final currentYear =
                              DateTime.now().year;
                          if (y < 1800 || y > currentYear) {
                            return '1800–$currentYear';
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
                      isEdit ? 'Update College' : 'Create College',
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