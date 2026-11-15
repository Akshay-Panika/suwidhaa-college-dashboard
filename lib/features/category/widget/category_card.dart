import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/utils/app_color.dart';

// ═══════════════════════════════════════════════
//  MODEL
// ═══════════════════════════════════════════════
class CategoryModel {
  int id;
  String name;
  String description;
  bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    this.isActive = true,
  });
}

enum _RightMode { create, edit, view }

// ═══════════════════════════════════════════════
//  CATEGORY CARD
// ═══════════════════════════════════════════════
class CategoryCard extends StatefulWidget {
  const CategoryCard({super.key});

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  bool _isActive = true;

  int _nextId = 4;
  final List<CategoryModel> _categories = [
    CategoryModel(
        id: 1,
        name: 'Engineering',
        description:
        'B.Tech, M.Tech, and diploma programs in engineering disciplines.'),
    CategoryModel(
        id: 2,
        name: 'Medical',
        description: 'MBBS, BDS, nursing and paramedical courses.'),
    CategoryModel(
        id: 3,
        name: 'Commerce',
        description: 'B.Com, M.Com and accounting-related programs.',
        isActive: false),
  ];

  CategoryModel? _selected;
  _RightMode _mode = _RightMode.create;
  String _search = '';
  bool _gridView = false;

  List<CategoryModel> get _filtered {
    if (_search.trim().isEmpty) return _categories;
    final q = _search.toLowerCase();
    return _categories
        .where((c) =>
    c.name.toLowerCase().contains(q) ||
        c.description.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
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
      _descCtrl.clear();
      _isActive = true;
    });
  }

  void _startEdit(CategoryModel c) {
    setState(() {
      _mode = _RightMode.edit;
      _selected = c;
      _nameCtrl.text = c.name;
      _descCtrl.text = c.description;
      _isActive = c.isActive;
    });
  }

  void _startView(CategoryModel c) {
    setState(() {
      _mode = _RightMode.view;
      _selected = c;
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      if (_mode == _RightMode.edit && _selected != null) {
        _selected!.name = _nameCtrl.text.trim();
        _selected!.description = _descCtrl.text.trim();
        _selected!.isActive = _isActive;
      } else {
        _categories.insert(
          0,
          CategoryModel(
            id: _nextId++,
            name: _nameCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            isActive: _isActive,
          ),
        );
      }
    });

    Fluttertoast.showToast(
      msg: _mode == _RightMode.edit
          ? 'Category updated.'
          : 'Category added.',
      backgroundColor: AppColor.primary,
      textColor: AppColor.white,
    );

    _startCreate();
  }

  void _delete(CategoryModel c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Category',
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
                _categories.removeWhere((x) => x.id == c.id);
                if (_selected?.id == c.id) _startCreate();
              });
              Navigator.pop(ctx);
              Fluttertoast.showToast(
                msg: 'Category deleted.',
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
    final total = _categories.length;
    final active = _categories.where((c) => c.isActive).length;
    final inactive = total - active;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Category Management',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.black),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _startCreate,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Category'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: AppColor.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
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
      padding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                      hintText: 'Search categories...',
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
                      _viewToggleBtn(Icons.view_list_rounded,
                          !_gridView, () => setState(() => _gridView = false)),
                      _viewToggleBtn(Icons.grid_view_rounded,
                          _gridView, () => setState(() => _gridView = true)),
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
        padding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                  child: Text(
                    c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColor.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColor.black)),
                      const SizedBox(height: 2),
                      Text(c.description,
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
            childAspectRatio: 1.6,
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
                    color:
                    isSelected ? AppColor.primary : AppColor.border,
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
                          child: Text(
                            c.name.isNotEmpty
                                ? c.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColor.primary),
                          ),
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
                    Expanded(
                      child: Text(c.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
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
          Icon(Icons.category_outlined,
              size: 48, color: AppColor.primary.withOpacity(0.3)),
          const SizedBox(height: 10),
          const Text('No categories found',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.black)),
          const SizedBox(height: 4),
          Text(
            _search.isEmpty
                ? 'Click "Add Category" to create one'
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
      child: _mode == _RightMode.view
          ? _buildViewCard()
          : _buildFormCard(),
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
                child: Text('Category Details',
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
              child: Text(
                c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(c.name,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.black)),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 5),
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
            child: Text(c.description,
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
                    isEdit ? 'Edit Category' : 'Create Category',
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
            const Text('Category Name',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameCtrl,
              decoration: _inputDecoration('e.g. Engineering'),
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'Name is required';
                if (v.trim().length < 2) return 'Minimum 2 characters';
                return null;
              },
            ),
            const SizedBox(height: 14),
            const Text('Description',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: _inputDecoration('Short description...'),
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'Description is required';
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
                      isEdit ? 'Update Category' : 'Create Category',
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