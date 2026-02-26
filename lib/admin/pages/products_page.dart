import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_website/admin/admin_shell.dart';
import 'package:food_website/admin/pages/dashboard_page.dart';
import 'package:food_website/admin/theme/_theme.dart';
import 'package:food_website/admin/widgets/buttons.dart';
import 'package:food_website/admin/widgets/common.dart';
import 'package:food_website/admin/widgets/empty_state.dart';
import 'package:food_website/admin/widgets/header.dart';
import 'package:food_website/admin/widgets/skeletons.dart';

class PearlProductsPage extends StatefulWidget {
  const PearlProductsPage({super.key});

  @override
  State<PearlProductsPage> createState() => _PearlProductsPageState();
}

class _PearlProductsPageState extends State<PearlProductsPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _category = "All";
  int _stockFilter = 0; // 0=All, 1=In stock, 2=Out of stock

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snap) {
        final isLoading = snap.connectionState == ConnectionState.waiting;
        final docs = snap.data?.docs ?? const [];

        final categories = <String>{"All"};
        for (final d in docs) {
          final data = d.data() as Map<String, dynamic>;
          final c = (data['category'] ?? '').toString().trim();
          if (c.isNotEmpty) categories.add(c);
        }
        final categoryList = categories.toList()
          ..sort((a, b) => a == "All" ? -1 : a.compareTo(b));

        final query = _searchCtrl.text.trim().toLowerCase();
        final filtered = docs.where((d) {
          final data = d.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toString().toLowerCase();
          final cat = (data['category'] ?? '').toString();
          final inStock = (data['inStock'] ?? true) == true;

          final matchesSearch = query.isEmpty || name.contains(query);
          final matchesCategory = _category == "All" || cat == _category;
          final matchesStock =
              _stockFilter == 0 || (_stockFilter == 1 ? inStock : !inStock);

          return matchesSearch && matchesCategory && matchesStock;
        }).toList();

        return LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final isMobile = Breakpoints.isMobile(w);
            final isTablet = Breakpoints.isTablet(w);
            final isDesktop = Breakpoints.isDesktop(w);

            return CustomScrollView(
              slivers: [
                // Page header / controls
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: "Product management",
                    subtitle: "Search, filter and manage your catalog.",
                    right: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.end,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isMobile
                                ? double.infinity
                                : (isTablet ? 260 : 360),
                            minWidth: isMobile ? 200 : 240,
                          ),
                          child: SearchField(
                            controller: _searchCtrl,
                            hint: "Search products…",
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        PrimaryButton(
                          label: isMobile ? "Add" : "Add product",
                          icon: Icons.add_rounded,
                          onTap: () {
                            // TODO: open add product dialog/page
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 10)),

                // Filters row (chips)
                SliverToBoxAdapter(
                  child: Panel(
                    title: "Filters",
                    subtitle: "Refine results quickly",
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilterChipGroup(
                          label: "Category",
                          value: _category,
                          items: categoryList,
                          onChanged: (v) => setState(() => _category = v),
                        ),
                        ChoicePills(
                          label: "Stock",
                          valueIndex: _stockFilter,
                          items: const ["All", "In stock", "Out of stock"],
                          onChanged: (i) => setState(() => _stockFilter = i),
                        ),
                        if (!isMobile)
                          SoftInfo(
                            text: "${filtered.length} products",
                            icon: Icons.inventory_2_outlined,
                          ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // Content
                if (isLoading)
                  SliverToBoxAdapter(
                    child: Panel(
                      title: "Products",
                      subtitle: "Loading…",
                      child: const SkeletonList(count: 8, height: 62),
                    ),
                  )
                else if (filtered.isEmpty)
                  const SliverToBoxAdapter(
                    child: Panel(
                      title: "Products",
                      subtitle: "No matches",
                      child: EmptyState(
                        icon: Icons.search_off_rounded,
                        title: "No products found",
                        subtitle:
                            "Try changing filters or searching with a different keyword.",
                      ),
                    ),
                  )
                else if (isDesktop)
                  // Desktop: sticky header + rows
                  SliverToBoxAdapter(
                    child: Panel(
                      title: "Products",
                      subtitle: "Manage your inventory",
                      child: ProductsDesktopTable(
                        docs: filtered,
                        onEdit: (id) {},
                        onDelete: (id) {
                          FirebaseFirestore.instance
                              .collection('products')
                              .doc(id)
                              .delete();
                        },
                        onToggleStock: (id, v) {
                          FirebaseFirestore.instance
                              .collection('products')
                              .doc(id)
                              .update({'inStock': v});
                        },
                      ),
                    ),
                  )
                else
                  // Mobile/Tablet: cards
                  SliverToBoxAdapter(
                    child: Panel(
                      title: "Products",
                      subtitle: "Manage your inventory",
                      child: ProductsList(
                        docs: filtered,
                        onEdit: (id) {},
                        onDelete: (id) {
                          FirebaseFirestore.instance
                              .collection('products')
                              .doc(id)
                              .delete();
                        },
                        onToggleStock: (id, v) {
                          FirebaseFirestore.instance
                              .collection('products')
                              .doc(id)
                              .update({'inStock': v});
                        },
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            );
          },
        );
      },
    );
  }
}

/// =======================================================
/// Products UI
/// =======================================================
class ProductsDesktopTable extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;
  final ValueChanged<String> onEdit;
  final ValueChanged<String> onDelete;
  final void Function(String id, bool value) onToggleStock;

  const ProductsDesktopTable({
    super.key,
    required this.docs,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStock,
  });

  @override
  Widget build(BuildContext context) {
    final items = docs;

    const minWidth = 980.0;

    return LayoutBuilder(
      builder: (context, c) {
        final needsScroll = c.maxWidth < minWidth;

        final content = Column(
          children: [
            TableHeaderRow(
              columns: const [
                "Product",
                "Category",
                "Price",
                "Stock",
                "Availability",
                "",
              ],
              flex: const [34, 16, 12, 10, 16, 12],
            ),
            const SizedBox(height: 8),
            ...items.take(12).map((d) {
              final data = d.data() as Map<String, dynamic>;
              final id = d.id;
              final name = (data['name'] ?? 'Pearl Bag').toString();
              final price = (data['price'] is num)
                  ? (data['price'] as num).toStringAsFixed(0)
                  : '0';
              final stock = (data['stock'] ?? 0).toString();
              final category = (data['category'] ?? 'Bags').toString();
              final inStock = (data['inStock'] ?? true) == true;
              final imageUrl = (data['imageUrl'] ?? '').toString();

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Hoverable(
                  borderRadius: 14,
                  builder: (hovered) => AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: hovered ? const Color(0xFFF7F9FF) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AdminTheme.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 34,
                          child: Row(
                            children: [
                              _ImgThumb(url: imageUrl, size: 44),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: AdminTheme.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 16,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _SoftTag(text: category),
                          ),
                        ),
                        Expanded(
                          flex: 12,
                          child: CellText(
                            "₹$price",
                            flex: 12,
                            alignEnd: false,
                            strong: true,
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: CellText(stock, flex: 10, alignEnd: false),
                        ),
                        Expanded(
                          flex: 16,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _AvailabilitySwitch(
                              value: inStock,
                              onChanged: (v) => onToggleStock(id, v),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 12,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: PopupMenuButton<String>(
                              tooltip: "Actions",
                              onSelected: (v) {
                                if (v == "edit") onEdit(id);
                                if (v == "delete") onDelete(id);
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: "edit",
                                  child: Text("Edit"),
                                ),
                                PopupMenuItem(
                                  value: "delete",
                                  child: Text("Delete"),
                                ),
                              ],
                              child: Hoverable(
                                borderRadius: 12,
                                builder: (h) => Container(
                                  height: 38,
                                  width: 38,
                                  decoration: BoxDecoration(
                                    color: h
                                        ? const Color(0xFFF1F5FF)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AdminTheme.border,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.more_horiz_rounded,
                                    color: AdminTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );

        if (!needsScroll) return content;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: minWidth),
            child: content,
          ),
        );
      },
    );
  }
}

class ProductsList extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;
  final ValueChanged<String> onEdit;
  final ValueChanged<String> onDelete;
  final void Function(String id, bool value) onToggleStock;

  const ProductsList({
    super.key,
    required this.docs,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStock,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: docs.take(10).map((d) {
        final data = d.data() as Map<String, dynamic>;
        final id = d.id;
        final name = (data['name'] ?? 'Pearl Bag').toString();
        final price = (data['price'] is num)
            ? (data['price'] as num).toStringAsFixed(0)
            : '0';
        final category = (data['category'] ?? 'Bags').toString();
        final inStock = (data['inStock'] ?? true) == true;
        final imageUrl = (data['imageUrl'] ?? '').toString();
        final stock = (data['stock'] ?? 0).toString();

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Hoverable(
            borderRadius: 16,
            builder: (hovered) => AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hovered ? const Color(0xFFF7F9FF) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AdminTheme.border),
              ),
              child: Row(
                children: [
                  _ImgThumb(url: imageUrl, size: 54),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              "₹$price",
                              style: TextStyle(
                                color: AdminTheme.textSecondary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            _SoftTag(text: category),
                            SoftInfo(
                              text: "Stock $stock",
                              icon: Icons.inventory_2_outlined,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _AvailabilitySwitch(
                              value: inStock,
                              onChanged: (v) => onToggleStock(id, v),
                            ),
                            const Spacer(),
                            IconButton(
                              tooltip: "Edit",
                              onPressed: () => onEdit(id),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              tooltip: "Delete",
                              onPressed: () => onDelete(id),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ImgThumb extends StatelessWidget {
  final String url;
  final double size;

  const _ImgThumb({required this.url, this.size = 46});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF1F5FF),
        border: Border.all(color: AdminTheme.border),
        image: url.isEmpty
            ? null
            : DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
      child: url.isEmpty
          ? Icon(
              Icons.image_outlined,
              color: AdminTheme.textSecondary.withOpacity(0.65),
            )
          : null,
    );
  }
}

class _AvailabilitySwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AvailabilitySwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AdminTheme.success,
          activeTrackColor: AdminTheme.success.withOpacity(0.25),
          inactiveThumbColor: AdminTheme.textSecondary.withOpacity(0.60),
          inactiveTrackColor: AdminTheme.textSecondary.withOpacity(0.18),
        ),
        Text(
          value ? "In stock" : "Out",
          style: TextStyle(
            color: value ? AdminTheme.success : AdminTheme.textSecondary,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// ----------------------
/// Tags / chips
/// ----------------------
class _SoftTag extends StatelessWidget {
  final String text;
  const _SoftTag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: AdminTheme.textPrimary,
        ),
      ),
    );
  }
}

class SoftInfo extends StatelessWidget {
  final String text;
  final IconData icon;
  const SoftInfo({super.key, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AdminTheme.textSecondary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AdminTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class FilterChipGroup extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const FilterChipGroup({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(label, style: AdminTheme.meta),
        ...items.take(8).map((it) {
          final active = it == value;
          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => onChanged(it),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: active
                    ? AdminTheme.primary.withOpacity(0.10)
                    : const Color(0xFFF7F9FF),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: active
                      ? AdminTheme.primary.withOpacity(0.20)
                      : AdminTheme.border,
                ),
              ),
              child: Text(
                it,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: active ? AdminTheme.primary : AdminTheme.textSecondary,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class ChoicePills extends StatelessWidget {
  final String label;
  final int valueIndex;
  final List<String> items;
  final ValueChanged<int> onChanged;

  const ChoicePills({
    super.key,
    required this.label,
    required this.valueIndex,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(label, style: AdminTheme.meta),
        ...List.generate(items.length, (i) {
          final active = i == valueIndex;
          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: active
                    ? AdminTheme.success.withOpacity(0.10)
                    : const Color(0xFFF7F9FF),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: active
                      ? AdminTheme.success.withOpacity(0.20)
                      : AdminTheme.border,
                ),
              ),
              child: Text(
                items[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: active ? AdminTheme.success : AdminTheme.textSecondary,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
