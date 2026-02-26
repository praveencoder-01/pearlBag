import 'package:flutter/material.dart';
import 'package:food_website/admin/theme/_theme.dart';
import 'package:food_website/admin/widgets/buttons.dart';
import 'package:food_website/admin/widgets/common.dart';

class SearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  const SearchField({
    super.key,
    required this.hint,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminTheme.border),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          color: AdminTheme.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AdminTheme.textSecondary.withOpacity(0.8),
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: AdminTheme.textSecondary.withOpacity(0.75),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
class _LivePill extends StatelessWidget {
  const _LivePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AdminTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AdminTheme.primary.withOpacity(0.18)),
      ),
      alignment: Alignment.center,
      child: const Text(
        "Live",
        style: TextStyle(
          color: AdminTheme.primary,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _HeaderActions extends StatelessWidget {
  final bool dense;
  final ValueChanged<String> onAction;

  const _HeaderActions({required this.dense, required this.onAction});

  @override
  Widget build(BuildContext context) {
    // ✅ Fixed spacing system
    final gap = dense ? Space.x8 : Space.x10;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PrimaryButton(
          label: dense ? "Add" : "Add product",
          icon: Icons.add_rounded,
          onTap: () => onAction("add_product"),
        ),
        SizedBox(width: gap),
        SecondaryButton(
          label: "Export",
          icon: Icons.file_download_outlined,
          onTap: () => onAction("export"),
        ),
        SizedBox(width: gap),
        TertiaryButton(
          tooltip: "Filter",
          icon: Icons.tune_rounded,
          onTap: () => onAction("filter"),
        ),
      ],
    );
  }
}

class _HeaderMoreMenu extends StatelessWidget {
  final ValueChanged<String> onQuickAction;
  const _HeaderMoreMenu({required this.onQuickAction});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: "More actions",
      onSelected: onQuickAction,
      itemBuilder: (context) => const [
        PopupMenuItem(value: "add_product", child: Text("Add product")),
        PopupMenuItem(value: "export", child: Text("Export")),
        PopupMenuItem(value: "filter", child: Text("Filter")),
      ],
      child: const IconButtonPill(
        tooltip: "More",
        icon: Icons.more_horiz_rounded,
        onTap: null,
      ),
    );
  }
}

/// ======================
/// Dashboard Page
/// ======================

/// ======================
/// Products Page (management)
/// - Search + filter chips
/// - Desktop: sticky header + table-like rows
/// - Mobile: card list
/// ======================

/// =======================================================
/// Reusable UI components
/// =======================================================

class _AvatarMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: "Account",
      onSelected: (_) {},
      itemBuilder: (context) => const [
        PopupMenuItem(value: "profile", child: Text("Profile")),
        PopupMenuItem(value: "settings", child: Text("Settings")),
      ],
      child: Hoverable(
        borderRadius: 16,
        builder: (hovered) => AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: hovered ? const Color(0xFFF1F5FF) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AdminTheme.border),
          ),
          child: Row(
            children: [
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [AdminTheme.primary, AdminTheme.primary2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Text(
                    "P",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.expand_more_rounded,
                color: AdminTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ======================
/// Title block (desktop/tablet)
/// ======================
class _HeaderTitleBlock extends StatelessWidget {
  final String title;
  final String? breadcrumb;
  final bool showLivePill;

  final bool showMenu;
  final VoidCallback? onOpenDrawer;

  const _HeaderTitleBlock({
    required this.title,
    required this.showLivePill,
    required this.showMenu,
    required this.onOpenDrawer,
    this.breadcrumb,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showMenu && onOpenDrawer != null) ...[
          IconButtonPill(
            tooltip: "Menu",
            icon: Icons.menu_rounded,
            onTap: onOpenDrawer,
          ),
          const SizedBox(width: Space.x10),
        ],
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: AdminTheme.h1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showLivePill) ...[
                    const SizedBox(width: Space.x10),
                    const _LivePill(),
                  ],
                ],
              ),
              if (breadcrumb != null && breadcrumb!.trim().isNotEmpty) ...[
                const SizedBox(height: Space.x4),
                Text(
                  breadcrumb!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AdminTheme.meta,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// ----------------------
/// Tablet (600–1024)
/// Left: Title + Live
/// Right: Search (smaller) + More + Notifications + Avatar
/// ----------------------
class _TabletHeader extends StatelessWidget {
  final String title;
  final ValueChanged<String> onQuickAction;

  const _TabletHeader({required this.title, required this.onQuickAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // LEFT
        Expanded(
          child: _HeaderTitleBlock(
            title: title,
            showLivePill: true,
            breadcrumb: null,
            showMenu: false,
            onOpenDrawer: null,
          ),
        ),

        const SizedBox(width: Space.x12),

        // RIGHT
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320, minWidth: 200),
              child: const SearchField(hint: "Search…"),
            ),
            const SizedBox(width: Space.x10),

            // ✅ Actions collapse into "More"
            _HeaderMoreMenu(onQuickAction: onQuickAction),
            const SizedBox(width: Space.x8),

            IconButtonPill(
              tooltip: "Notifications",
              icon: Icons.notifications_none_rounded,
              onTap: () {},
              badge: 2,
            ),
            const SizedBox(width: Space.x10),
            _AvatarMenu(),
          ],
        ),
      ],
    );
  }
}


class _DesktopHeader extends StatelessWidget {
  final String title;
  final ValueChanged<String> onQuickAction;

  const _DesktopHeader({required this.title, required this.onQuickAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // LEFT (never jumps; ellipsis)
        Flexible(
          flex: 3,
          child: _HeaderTitleBlock(
            title: title,
            showLivePill: true,
            // breadcrumb optional (kept off by default; hook ready)
            breadcrumb: null,
            showMenu: false,
            onOpenDrawer: null,
          ),
        ),

        const SizedBox(width: Space.x12),

        // CENTER (fluid but max width)
        Expanded(
          flex: 4,
          child: Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560, minWidth: 220),
              child: const SearchField(
                hint: "Search orders, products, customers…",
              ),
            ),
          ),
        ),

        const SizedBox(width: Space.x12),

        // RIGHT (always right aligned; fixed height 44 items)
        Flexible(
          flex: 3,
          child: Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _HeaderActions(dense: false, onAction: onQuickAction),
                const SizedBox(width: Space.x10),
                IconButtonPill(
                  tooltip: "Notifications",
                  icon: Icons.notifications_none_rounded,
                  onTap: () {},
                  badge: 2,
                ),
                const SizedBox(width: Space.x10),
                _AvatarMenu(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


class _HeaderTitleInline extends StatelessWidget {
  final String title;
  const _HeaderTitleInline({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AdminTheme.h1,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// ----------------------
/// Mobile (<600)
/// Row 1: Menu (if drawer) + Title + Notifications + Avatar
/// Row 2: Full width Search
/// ----------------------
class _MobileHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onOpenDrawer;

  const _MobileHeader({required this.title, required this.onOpenDrawer});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1
        SizedBox(
          height: 56, // keeps the top row premium and stable
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (onOpenDrawer != null) ...[
                IconButtonPill(
                  tooltip: "Menu",
                  icon: Icons.menu_rounded,
                  onTap: onOpenDrawer,
                ),
                const SizedBox(width: Space.x10),
              ],

              // Title (ellipsis, never jumps)
              Expanded(child: _HeaderTitleInline(title: title)),

              const SizedBox(width: Space.x10),
              IconButtonPill(
                tooltip: "Notifications",
                icon: Icons.notifications_none_rounded,
                onTap: () {},
                badge: 2,
              ),
              const SizedBox(width: Space.x10),
              _AvatarMenu(),
            ],
          ),
        ),

        const SizedBox(height: Space.x10),

        // Row 2 (full width search)
        const SearchField(hint: "Search orders, products, customers…"),
      ],
    );
  }
}

/// ======================
/// ✅ NEW HEADER LAYOUT (replaces Wrap-based ResponsiveHeaderRow)
/// ======================
class ResponsiveHeader extends StatelessWidget {
  final double width;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;

  final String title;
  final VoidCallback? onOpenDrawer;
  final ValueChanged<String> onQuickAction;

  const ResponsiveHeader({
    super.key,
    required this.width,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.title,
    required this.onOpenDrawer,
    required this.onQuickAction,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Required: professional header height baseline
    // Desktop/Tablet: exactly 56
    // Mobile: min 56, grows because it becomes 2 rows (as required)
    final base = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: isMobile
          ? _MobileHeader(title: title, onOpenDrawer: onOpenDrawer)
          : (isTablet
                ? _TabletHeader(title: title, onQuickAction: onQuickAction)
                : _DesktopHeader(title: title, onQuickAction: onQuickAction)),
    );

    // On desktop/tablet keep the container visually 56px tall
    if (!isMobile) {
      return SizedBox(height: 56, child: base);
    }
    return base;
  }
}