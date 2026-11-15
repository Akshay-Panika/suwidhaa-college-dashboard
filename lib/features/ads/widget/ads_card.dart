import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/utils/app_color.dart';

// ═══════════════════════════════════════════════
//  MODEL
// ═══════════════════════════════════════════════
class AdsModel {
  int id;
  String title;
  String advertiser;
  String imageUrl;
  String targetUrl;
  String placement;
  bool isActive;

  AdsModel({
    required this.id,
    required this.title,
    required this.advertiser,
    required this.imageUrl,
    this.targetUrl = '',
    this.placement = 'Home Top',
    this.isActive = true,
  });
}

enum _RightMode { create, edit, view }

// ═══════════════════════════════════════════════
//  PLACEMENT OPTIONS
// ═══════════════════════════════════════════════
const List<String> _kPlacements = [
  'Home Top',
  'Home Bottom',
  'Category Page',
  'Sidebar',
  'Checkout',
];

const Map<String, Color> _kPlacementColors = {
  'Home Top': Color(0xFF6D28D9),
  'Home Bottom': Color(0xFF2563EB),
  'Category Page': Color(0xFF059669),
  'Sidebar': Color(0xFFD97706),
  'Checkout': Color(0xFFDC2626),
};

// ═══════════════════════════════════════════════
//  ADS CARD
// ═══════════════════════════════════════════════
class AdsCard extends StatefulWidget {
  const AdsCard({super.key});

  @override
  State<AdsCard> createState() => _AdsCardState();
}

class _AdsCardState extends State<AdsCard> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _advertiserCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  bool _isActive = true;
  String _placement = _kPlacements.first;

  int _nextId = 4;
  final List<AdsModel> _ads = [
    AdsModel(
      id: 1,
      title: 'Summer Tiffin Sale — Flat 15% Off',
      advertiser: 'Tasty Tiffins Co.',
      imageUrl: 'https://picsum.photos/seed/ad1/800/400',
      targetUrl: '/offers/summer',
      placement: 'Home Top',
    ),
    AdsModel(
      id: 2,
      title: 'Hostel Room Booking is Live',
      advertiser: 'StayEasy Rentals',
      imageUrl: 'https://picsum.photos/seed/ad2/800/400',
      targetUrl: '/rooms',
      placement: 'Sidebar',
    ),
    AdsModel(
      id: 3,
      title: 'Refer & Earn ₹200 Credit',
      advertiser: 'College Admin',
      imageUrl: 'https://picsum.photos/seed/ad3/800/400',
      targetUrl: '/referral',
      placement: 'Home Bottom',
      isActive: false,
    ),
  ];

  AdsModel? _selected;
  _RightMode _mode = _RightMode.create;
  String _search = '';
  bool _gridView = true;

  List<AdsModel> get _filtered {
    if (_search.trim().isEmpty) return _ads;
    final q = _search.toLowerCase();
    return _ads
        .where((a) =>
    a.title.toLowerCase().contains(q) ||
        a.advertiser.toLowerCase().contains(q) ||
        a.placement.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _advertiserCtrl.dispose();
    _imageCtrl.dispose();
    _targetCtrl.dispose();
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
      _titleCtrl.clear();
      _advertiserCtrl.clear();
      _imageCtrl.clear();
      _targetCtrl.clear();
      _placement = _kPlacements.first;
      _isActive = true;
    });
  }

  void _startEdit(AdsModel a) {
    setState(() {
      _mode = _RightMode.edit;
      _selected = a;
      _titleCtrl.text = a.title;
      _advertiserCtrl.text = a.advertiser;
      _imageCtrl.text = a.imageUrl;
      _targetCtrl.text = a.targetUrl;
      _placement = a.placement;
      _isActive = a.isActive;
    });
  }

  void _startView(AdsModel a) {
    setState(() {
      _mode = _RightMode.view;
      _selected = a;
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      if (_mode == _RightMode.edit && _selected != null) {
        _selected!.title = _titleCtrl.text.trim();
        _selected!.advertiser = _advertiserCtrl.text.trim();
        _selected!.imageUrl = _imageCtrl.text.trim();
        _selected!.targetUrl = _targetCtrl.text.trim();
        _selected!.placement = _placement;
        _selected!.isActive = _isActive;
      } else {
        _ads.insert(
          0,
          AdsModel(
            id: _nextId++,
            title: _titleCtrl.text.trim(),
            advertiser: _advertiserCtrl.text.trim(),
            imageUrl: _imageCtrl.text.trim(),
            targetUrl: _targetCtrl.text.trim(),
            placement: _placement,
            isActive: _isActive,
          ),
        );
      }
    });

    Fluttertoast.showToast(
      msg: _mode == _RightMode.edit ? 'Ad updated.' : 'Ad created.',
      backgroundColor: AppColor.primary,
      textColor: AppColor.white,
    );

    _startCreate();
  }

  void _delete(AdsModel a) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Ad',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColor.black)),
        content: Text('Delete "${a.title}"?',
            style: const TextStyle(fontSize: 14, color: Colors.grey)),
        actionsPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
            const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _ads.removeWhere((x) => x.id == a.id);
                if (_selected?.id == a.id) _startCreate();
              });
              Navigator.pop(ctx);
              Fluttertoast.showToast(
                msg: 'Ad deleted.',
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
    final total = _ads.length;
    final active = _ads.where((a) => a.isActive).length;
    final inactive = total - active;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Ads Management',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.black),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _startCreate,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Ad'),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _placementChip(String placement) {
    final color = _kPlacementColors[placement] ?? AppColor.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(placement,
          style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
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
                      hintText: 'Search ads...',
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
                      _viewToggleBtn(
                          Icons.view_list_rounded,
                          !_gridView,
                              () => setState(() => _gridView = false)),
                      _viewToggleBtn(
                          Icons.grid_view_rounded,
                          _gridView,
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
        final a = _filtered[i];
        final isSelected = _selected?.id == a.id;
        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _startView(a),
          child: Container(
            padding: const EdgeInsets.all(10),
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 64,
                    height: 44,
                    child: _adImage(a.imageUrl, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColor.black)),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          _placementChip(a.placement),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(a.advertiser,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _statusDot(a.isActive),
                IconButton(
                  onPressed: () => _startEdit(a),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  color: AppColor.primary,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () => _delete(a),
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
            childAspectRatio: 1.25,
          ),
          itemCount: _filtered.length,
          itemBuilder: (context, i) {
            final a = _filtered[i];
            final isSelected = _selected?.id == a.id;
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _startView(a),
              child: Container(
                padding: const EdgeInsets.all(10),
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
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: double.infinity,
                          child: _adImage(a.imageUrl,
                              fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(a.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.black)),
                        ),
                        _statusDot(a.isActive),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(a.advertiser,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade600)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _placementChip(a.placement),
                        const Spacer(),
                        InkWell(
                          onTap: () => _startEdit(a),
                          child: const Padding(
                            padding: EdgeInsets.all(2),
                            child: Icon(Icons.edit_outlined,
                                size: 14, color: AppColor.primary),
                          ),
                        ),
                        InkWell(
                          onTap: () => _delete(a),
                          child: const Padding(
                            padding: EdgeInsets.all(2),
                            child: Icon(Icons.delete_outline,
                                size: 14, color: AppColor.red),
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
        color: active ? const Color(0xFF059669) : const Color(0xFFDC2626),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.campaign_outlined,
              size: 48, color: AppColor.primary.withOpacity(0.3)),
          const SizedBox(height: 10),
          const Text('No ads found',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.black)),
          const SizedBox(height: 4),
          Text(
            _search.isEmpty
                ? 'Click "Add Ad" to create one'
                : 'Try a different search term',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  IMAGE HELPER
  // ═══════════════════════════════════════════════
  Widget _adImage(String url, {BoxFit fit = BoxFit.cover}) {
    if (url.isEmpty) {
      return Container(
        color: AppColor.bg,
        alignment: Alignment.center,
        child: Icon(Icons.campaign_outlined,
            size: 22, color: AppColor.primary.withOpacity(0.4)),
      );
    }
    return Image.network(
      url,
      fit: fit,
      errorBuilder: (_, __, ___) => Container(
        color: AppColor.bg,
        alignment: Alignment.center,
        child: Icon(Icons.broken_image_outlined,
            size: 22, color: Colors.grey.shade400),
      ),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppColor.bg,
          alignment: Alignment.center,
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColor.primary,
            ),
          ),
        );
      },
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
    final a = _selected!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Ad Details',
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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: _adImage(a.imageUrl),
            ),
          ),
          const SizedBox(height: 16),
          Text(a.title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.black)),
          const SizedBox(height: 6),
          Text(a.advertiser,
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _placementChip(a.placement),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: a.isActive
                      ? const Color(0xFF059669).withOpacity(0.12)
                      : const Color(0xFFDC2626).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  a.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: a.isActive
                        ? const Color(0xFF059669)
                        : const Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Target URL',
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
            child: Text(
              a.targetUrl.isEmpty ? '— No target set —' : a.targetUrl,
              style: TextStyle(
                  fontSize: 12,
                  color: a.targetUrl.isEmpty
                      ? Colors.grey.shade500
                      : Colors.grey.shade800,
                  height: 1.5),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Image URL',
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
            child: Text(a.imageUrl,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade800,
                    height: 1.5)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _startEdit(a),
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
                  onPressed: () => _delete(a),
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
                    isEdit ? 'Edit Ad' : 'Create Ad',
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
            const Text('Ad Title',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleCtrl,
              decoration: _inputDecoration('e.g. Summer Tiffin Sale'),
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'Title is required';
                if (v.trim().length < 3) return 'Minimum 3 characters';
                return null;
              },
            ),
            const SizedBox(height: 14),
            const Text('Advertiser',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _advertiserCtrl,
              decoration: _inputDecoration('e.g. Tasty Tiffins Co.'),
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'Advertiser is required';
                return null;
              },
            ),
            const SizedBox(height: 14),
            const Text('Image URL',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _imageCtrl,
              decoration: _inputDecoration('https://example.com/ad.jpg'),
              onChanged: (_) => setState(() {}),
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'Image URL is required';
                if (!v.trim().startsWith('http'))
                  return 'Must start with http(s)';
                return null;
              },
            ),
            if (_imageCtrl.text.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: _adImage(_imageCtrl.text.trim()),
                ),
              ),
            ],
            const SizedBox(height: 14),
            const Text('Target URL (optional)',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _targetCtrl,
              decoration: _inputDecoration('/offers  or  https://...'),
            ),
            const SizedBox(height: 14),
            const Text('Placement',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColor.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColor.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _placement,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey.shade600),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColor.black),
                  items: _kPlacements
                      .map((p) => DropdownMenuItem(
                    value: p,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _kPlacementColors[p] ??
                                AppColor.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(p),
                      ],
                    ),
                  ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _placement = v);
                  },
                ),
              ),
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
                      isEdit ? 'Update Ad' : 'Create Ad',
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
    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
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