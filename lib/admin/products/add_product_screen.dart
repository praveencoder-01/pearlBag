import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // ✅ KEEP: same form + controllers + logic
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final categoryController = TextEditingController();
  final imageUrlController = TextEditingController();
  final _descCtrl = TextEditingController();
  final _shipCtrl = TextEditingController();
  final _returnCtrl = TextEditingController();
  final _materialCtrl = TextEditingController();
  final _closureCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _idealForCtrl = TextEditingController();

  bool isAvailable = true;
  bool isLoading = false;

  List<XFile?> pickedImages = [null, null, null, null];
  List<String?> uploadedImageUrls = [null, null, null, null];

  bool isUploadingImage = false;

  // ✅ UI-only state (does NOT change backend behavior)
  int? _uploadingIndex;

  // ===== DESIGN TOKENS =====
  static const _bg = Color(0xFFF6F7FB);
  static const _card = Colors.white;
  static const _border = Color(0xFFE8ECF4);
  static const _primary = Color(0xFF6C63FF);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);

  Future<void> addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    // 🔴 IMPORTANT CHECK (KEEP)
    if (uploadedImageUrls.where((e) => e != null).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least one image')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('products').add({
        'name': nameController.text.trim(),
        'price': double.parse(priceController.text.trim()),
        'category': categoryController.text.trim(),
        'imageUrls': uploadedImageUrls.where((e) => e != null).toList(),
        'isAvailable': isAvailable,
        'description': _descCtrl.text.trim(),
        'shippingPolicy': _shipCtrl.text.trim(),
        'returnPolicy': _returnCtrl.text.trim(),
        // ✅ KEEP EXACT SAME KEYS + controller mapping (even if swapped)
        'closure': _materialCtrl.text.trim(),
        'material': _closureCtrl.text.trim(),
        'weight': _weightCtrl.text.trim(),
        'idealFor': _idealForCtrl.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => isLoading = false);
  }

 Future<void> pickImage(int index) async {
  final user = FirebaseAuth.instance.currentUser;
debugPrint("STORAGE UPLOAD USER: ${user?.uid}  email: ${user?.email}");
  final picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  if (image == null) return;

  setState(() {
    pickedImages[index] = image;
    isUploadingImage = true;
    _uploadingIndex = index;
  });

  try {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = FirebaseStorage.instance.ref().child(
      'product_images/$fileName.png',
    );

    final bytes = await image.readAsBytes();
    await ref.putData(bytes, SettableMetadata(contentType: 'image/png'));

    final url = await ref.getDownloadURL();

    if (!mounted) return;
    setState(() {
      uploadedImageUrls[index] = url;
    });
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image upload failed: $e")),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        isUploadingImage = false;
        _uploadingIndex = null;
      });
    }
  }
}

  // Example categories (UI only). You can replace with your real categories list.
  final List<String> _categories = const [
    'Handbags',
    'Sling Bags',
    'Tote Bags',
    'Backpacks',
    'Wallets',
    'Accessories',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final maxW = c.maxWidth;
            final contentMaxWidth = maxW >= 1000 ? 900.0 : 900.0;

            return CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyHeaderDelegate(
                    extent: 64,
                    child: SizedBox(
                      height: 64,
                      child: _StickyHeader(
                        title: 'Add New Product',
                        onBack: () => Navigator.pop(context),
                        onSave: isLoading ? null : addProduct,
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentMaxWidth),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // 2) Product Images (first + most important)
                              ImageUploaderCard(
                                title: 'Product Images',
                                subtitle:
                                    'Add a featured image and up to 3 additional photos. Clear photos improve sales.',
                                uploadingIndex: isUploadingImage
                                    ? _uploadingIndex
                                    : null,
                                primaryBadgeText: 'Primary Image',
                                onPick: pickImage,
                                imageProviderBuilder: (i) {
                                  if (uploadedImageUrls[i] != null) {
                                    return NetworkImage(uploadedImageUrls[i]!);
                                  }
                                  if (!kIsWeb && pickedImages[i] != null) {
                                    return FileImage(
                                      File(pickedImages[i]!.path),
                                    );
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // 3) Basic Information
                              SectionCard(
                                title: 'Basic Information',
                                subtitle:
                                    'Start with the essentials: name, category, price and stock.',
                                child: Column(
                                  children: [
                                    ModernInputField(
                                      controller: nameController,
                                      label: 'Product Name',
                                      hint: 'e.g., Pearl Embellished Handbag',
                                      prefixIcon: Icons.shopping_bag_outlined,
                                    ),
                                    const SizedBox(height: 12),

                                    // Category dropdown style (still writes to your controller)
                                    ModernDropdownField(
                                      label: 'Category',
                                      hint: 'Select a category',
                                      value:
                                          _categories.contains(
                                            categoryController.text.trim(),
                                          )
                                          ? categoryController.text.trim()
                                          : null,
                                      items: _categories,
                                      prefixIcon: Icons.category_outlined,
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                          ? 'Required'
                                          : null,
                                      onChanged: (v) {
                                        categoryController.text = v ?? '';
                                        setState(() {});
                                      },
                                    ),

                                    const SizedBox(height: 12),

                                    // Price + Stock status in same row
                                    _ResponsiveRow(
                                      gap: 12,
                                      children: [
                                        ModernInputField(
                                          controller: priceController,
                                          label: 'Price',
                                          hint: 'e.g., 999',
                                          prefixIcon: Icons.currency_rupee,
                                          keyboardType: TextInputType.number,
                                        ),
                                        StockTogglePill(
                                          value: isAvailable,
                                          onChanged: (v) =>
                                              setState(() => isAvailable = v),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // 4) Description
                              SectionCard(
                                title: 'Description',
                                subtitle: 'Describe material, size, and usage.',
                                child: ModernMultilineField(
                                  controller: _descCtrl,
                                  label: 'Description',
                                  hint:
                                      'Example: Premium pearl finish, spacious compartments, perfect for parties & daily use.',
                                  minLines: 6,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // 5) Product Details (new grouping)
                              SectionCard(
                                title: 'Product Details',
                                subtitle:
                                    'Add quick specs customers care about.',
                                child: LayoutBuilder(
                                  builder: (context, box) {
                                    final isTwoCol = box.maxWidth >= 640;
                                    return Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: [
                                        SizedBox(
                                          width: isTwoCol
                                              ? (box.maxWidth - 12) / 2
                                              : box.maxWidth,
                                          child: ModernInputField(
                                            controller: _materialCtrl,
                                            label: 'Material',
                                            hint: 'e.g., PU Leather / Fabric',
                                            prefixIcon: Icons.texture_outlined,
                                          ),
                                        ),
                                        SizedBox(
                                          width: isTwoCol
                                              ? (box.maxWidth - 12) / 2
                                              : box.maxWidth,
                                          child: ModernInputField(
                                            controller: _closureCtrl,
                                            label: 'Closure',
                                            hint: 'e.g., Zip / Magnetic',
                                            prefixIcon: Icons.lock_outline,
                                          ),
                                        ),
                                        SizedBox(
                                          width: isTwoCol
                                              ? (box.maxWidth - 12) / 2
                                              : box.maxWidth,
                                          child: ModernInputField(
                                            controller: _weightCtrl,
                                            label: 'Weight',
                                            hint: 'e.g., 450g',
                                            prefixIcon:
                                                Icons.monitor_weight_outlined,
                                          ),
                                        ),
                                        SizedBox(
                                          width: isTwoCol
                                              ? (box.maxWidth - 12) / 2
                                              : box.maxWidth,
                                          child: ModernInputField(
                                            controller: _idealForCtrl,
                                            label: 'Ideal For',
                                            hint: 'e.g., Women / Unisex',
                                            prefixIcon: Icons.person_outline,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 16),

                              // 6) Policies
                              SectionCard(
                                title: 'Shipping & Returns',
                                subtitle:
                                    'Set clear expectations to reduce cancellations.',
                                child: Column(
                                  children: [
                                    ModernMultilineField(
                                      controller: _shipCtrl,
                                      label: 'Shipping Policy',
                                      hint:
                                          'Example: Ships within 24–48 hours. Delivery in 3–7 business days.',
                                      minLines: 5,
                                    ),
                                    const SizedBox(height: 12),
                                    ModernMultilineField(
                                      controller: _returnCtrl,
                                      label: 'Return Policy',
                                      hint:
                                          'Example: 7-day return. Item must be unused with tags and original packaging.',
                                      minLines: 5,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // 7) Submit Area
                              PrimaryButton(
                                label: 'Add Product',
                                icon: Icons.add,
                                isLoading: isLoading,
                                onPressed: isLoading ? null : addProduct,
                              ),

                              const SizedBox(height: 10),
                              Text(
                                'Tip: Add at least 3 photos for best conversions.',
                                style: const TextStyle(
                                  color: _textSecondary,
                                  fontSize: 12.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// =======================
// Sticky Header (Professional)
// =======================

class _StickyHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback? onSave;

  const _StickyHeader({
    required this.title,
    required this.onBack,
    required this.onSave,
  });

  static const _primary = Color(0xFF6C63FF);
  static const _border = Color(0xFFE8ECF4);
  static const _textPrimary = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        decoration: const BoxDecoration(
          // subtle gradient + bottom border (no heavy purple appbar)
          gradient: LinearGradient(
            colors: [Color(0xFFF9FAFF), Color(0xFFF3F4FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border(bottom: BorderSide(color: _border)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              tooltip: 'Back',
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton.icon(
              onPressed: onSave,
              icon: const Icon(
                Icons.check_circle_outline,
                size: 18,
                color: _primary,
              ),
              label: const Text(
                'Save',
                style: TextStyle(color: _primary, fontWeight: FontWeight.w700),
              ),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0x0F6C63FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double extent;
  final Widget child;

  _StickyHeaderDelegate({required this.extent, required this.child});

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child; // child already has fixed height
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return extent != oldDelegate.extent || child != oldDelegate.child;
  }
}

// =======================
// Helper Widgets
// =======================

class SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const SectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  static const _card = Colors.white;
  static const _border = Color(0xFFE8ECF4);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: const TextStyle(
                color: _textSecondary,
                fontSize: 12.5,
                height: 1.3,
              ),
            ),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isLoading;
  final VoidCallback? onPressed;

  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    required this.isLoading,
    required this.onPressed,
  });

  static const _primary = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          disabledBackgroundColor: _primary.withOpacity(0.55),
          elevation: 0, // ✅ no heavy shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  key: const ValueKey('label'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: Colors.white),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class ModernInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const ModernInputField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  static const _border = Color(0xFFE8ECF4);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator:
            validator ??
            (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        style: const TextStyle(
          color: _textPrimary,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(color: _textSecondary),
          prefixIcon: prefixIcon == null
              ? null
              : Icon(prefixIcon, size: 20, color: _textSecondary),
          filled: true,
          fillColor: const Color(0xFFF9FAFC), // ✅ filled style
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}

class ModernMultilineField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int minLines;

  const ModernMultilineField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.minLines = 5,
  });

  static const _border = Color(0xFFE8ECF4);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: minLines + 2,
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      style: const TextStyle(
        color: _textPrimary,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: _textSecondary),
        filled: true,
        fillColor: const Color(0xFFF9FAFC),
        alignLabelWithHint: true,
        contentPadding: const EdgeInsets.all(14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.2),
        ),
      ),
    );
  }
}

class ModernDropdownField extends StatelessWidget {
  final String label;
  final String? hint;
  final List<String> items;
  final String? value;
  final IconData? prefixIcon;
  final void Function(String?) onChanged;
  final String? Function(String?)? validator;

  const ModernDropdownField({
    super.key,
    required this.label,
    this.hint,
    required this.items,
    required this.value,
    this.prefixIcon,
    required this.onChanged,
    this.validator,
  });

  static const _border = Color(0xFFE8ECF4);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final safeValue = (value != null && items.contains(value)) ? value : null;
    return SizedBox(
      height: 50,
      child: DropdownButtonFormField<String>(
        initialValue: safeValue,
        validator: validator,
        onChanged: onChanged,
        items: items
            .map(
              (e) => DropdownMenuItem<String>(
                value: e,
                child: Text(
                  e,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
            .toList(),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(color: _textSecondary),
          prefixIcon: prefixIcon == null
              ? null
              : Icon(prefixIcon, size: 20, color: _textSecondary),
          filled: true,
          fillColor: const Color(0xFFF9FAFC),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.2),
          ),
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: _textSecondary,
        ),
      ),
    );
  }
}

// =======================
// Product Images Section
// =======================

typedef ImageProviderBuilder = ImageProvider<Object>? Function(int index);

class ImageUploaderCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String primaryBadgeText;
  final void Function(int index) onPick;
  final ImageProviderBuilder imageProviderBuilder;
  final int? uploadingIndex;

  const ImageUploaderCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.primaryBadgeText,
    required this.onPick,
    required this.imageProviderBuilder,
    required this.uploadingIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: title,
      subtitle: subtitle,
      child: LayoutBuilder(
        builder: (context, box) {
          final isWide = box.maxWidth >= 640;
          if (isWide) {
            // Desktop/tablet: big primary on left, 3 thumbs on right
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: _ImageSlot(
                    index: 0,
                    height: 260,
                    isPrimary: true,
                    badge: primaryBadgeText,
                    onTap: () => onPick(0),
                    image: imageProviderBuilder(0),
                    isUploading: uploadingIndex == 0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      _ImageSlot(
                        index: 1,
                        height: 80,
                        onTap: () => onPick(1),
                        image: imageProviderBuilder(1),
                        isUploading: uploadingIndex == 1,
                      ),
                      const SizedBox(height: 10),
                      _ImageSlot(
                        index: 2,
                        height: 80,
                        onTap: () => onPick(2),
                        image: imageProviderBuilder(2),
                        isUploading: uploadingIndex == 2,
                      ),
                      const SizedBox(height: 10),
                      _ImageSlot(
                        index: 3,
                        height: 80,
                        onTap: () => onPick(3),
                        image: imageProviderBuilder(3),
                        isUploading: uploadingIndex == 3,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          // Mobile: primary on top, 3 thumbs in row
          return Column(
            children: [
              _ImageSlot(
                index: 0,
                height: 210,
                isPrimary: true,
                badge: primaryBadgeText,
                onTap: () => onPick(0),
                image: imageProviderBuilder(0),
                isUploading: uploadingIndex == 0,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ImageSlot(
                      index: 1,
                      height: 86,
                      onTap: () => onPick(1),
                      image: imageProviderBuilder(1),
                      isUploading: uploadingIndex == 1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ImageSlot(
                      index: 2,
                      height: 86,
                      onTap: () => onPick(2),
                      image: imageProviderBuilder(2),
                      isUploading: uploadingIndex == 2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ImageSlot(
                      index: 3,
                      height: 86,
                      onTap: () => onPick(3),
                      image: imageProviderBuilder(3),
                      isUploading: uploadingIndex == 3,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ImageSlot extends StatelessWidget {
  final int index;
  final double height;
  final VoidCallback onTap;
  final ImageProvider<Object>? image;
  final bool isPrimary;
  final String? badge;
  final bool isUploading;

  const _ImageSlot({
    required this.index,
    required this.height,
    required this.onTap,
    required this.image,
    required this.isUploading,
    this.isPrimary = false,
    this.badge,
  });

  static const _border = Color(0xFFE8ECF4);
  static const _textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final hasImage = image != null;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
              image: hasImage
                  ? DecorationImage(image: image!, fit: BoxFit.cover)
                  : null,
            ),
            child: !hasImage
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          color: _textSecondary,
                          size: 28,
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Upload',
                          style: TextStyle(
                            color: _textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),

          if (isPrimary)
            Positioned(
              left: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge ?? 'Primary',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

          if (isUploading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: SizedBox(
                    height: 26,
                    width: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =======================
// Stock Toggle Pill
// =======================

class StockTogglePill extends StatelessWidget {
  final bool value; // true = in stock
  final ValueChanged<bool> onChanged;

  const StockTogglePill({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const _border = Color(0xFFE8ECF4);

  @override
  Widget build(BuildContext context) {
    final inStock = value;

    return Container(
      height: 50,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PillChoice(
              label: 'In Stock',
              selected: inStock,
              selectedBg: Colors.green.withOpacity(0.12),
              selectedFg: Colors.green.shade700,
              onTap: () => onChanged(true),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _PillChoice(
              label: 'Out of Stock',
              selected: !inStock,
              selectedBg: Colors.red.withOpacity(0.10),
              selectedFg: Colors.red.shade700,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillChoice extends StatelessWidget {
  final String label;
  final bool selected;
  final Color selectedBg;
  final Color selectedFg;
  final VoidCallback onTap;

  const _PillChoice({
    required this.label,
    required this.selected,
    required this.selectedBg,
    required this.selectedFg,
    required this.onTap,
  });

  static const _textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? selectedBg : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? selectedFg : _textSecondary,
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }
}

// =======================
// Simple responsive row helper
// =======================

class _ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final double gap;

  const _ResponsiveRow({required this.children, this.gap = 12});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final isStack = box.maxWidth < 520;

        if (isStack) {
          // ✅ In a scroll view, never use Expanded inside Column
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: double.infinity, child: children[0]),
              SizedBox(height: gap),
              SizedBox(width: double.infinity, child: children[1]),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: children[0]),
            SizedBox(width: gap),
            Expanded(child: children[1]),
          ],
        );
      },
    );
  }
}
