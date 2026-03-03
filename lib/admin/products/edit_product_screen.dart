import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  EditProductScreen({
    super.key,
    required this.productId,
    required this.productData,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  // ✅ KEEP: same data/logic
  List<String> uploadedImageUrls = [];

  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController categoryController;
  late TextEditingController imageUrlController;

  bool availability = true;
  bool isLoading = false;

  // ✅ UI-only flags (logic unchanged)
  bool _isUploadingImage = false;

  // ===== DESIGN TOKENS =====
  static const _bg = Color(0xFFF6F7FB);
  static const _card = Colors.white;
  static const _border = Color(0xFFE8ECF4);
  static const _primary = Color(0xFF6C63FF);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.productData['name']);
    priceController =
        TextEditingController(text: widget.productData['price'].toString());
    categoryController =
        TextEditingController(text: widget.productData['category']);
    imageUrlController =
        TextEditingController(text: widget.productData['imageUrl'] ?? "");

    availability = widget.productData['availability'] ?? true;

    uploadedImageUrls = List<String>.from(widget.productData['imageUrls'] ?? []);
  }

  Future<String?> pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return null;

    final fileName = DateTime.now().millisecondsSinceEpoch.toString();

    final ref = FirebaseStorage.instance.ref().child(
      'product_images/$fileName.png',
    );

    final bytes = await image.readAsBytes();
    await ref.putData(bytes, SettableMetadata(contentType: 'image/png'));

    final downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> updateProduct() async {
    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update({
        'name': nameController.text.trim(),
        'price': int.parse(priceController.text.trim()),
        'category': categoryController.text.trim(),
        'availability': availability,
        'imageUrl': uploadedImageUrls.isNotEmpty ? uploadedImageUrls[0] : '',
        'imageUrls': uploadedImageUrls,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product updated successfully")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final canTap = !isLoading && !_isUploadingImage;

    return Scaffold(
      backgroundColor: _bg,

      // 7) Sticky bottom save area (premium)
      bottomNavigationBar: _BottomSaveBar(
        isLoading: isLoading,
        onSave: isLoading ? null : updateProduct,
      ),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: _textPrimary,
        ),
        title: const Text(
          "Edit Product",
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: isLoading ? null : updateProduct,
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text("Save"),
              style: TextButton.styleFrom(
                foregroundColor: _primary,
                backgroundColor: const Color(0x0F6C63FF),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              children: [
                // 3) Images section (primary + thumbnails + add)
                SectionCard(
                  title: "Images",
                  subtitle:
                      "First image is your primary photo. Add more to improve trust.",
                  child: ImageEditorStrip(
                    imageUrls: uploadedImageUrls,
                    isUploading: _isUploadingImage,
                    enabled: canTap,
                    onAdd: () async {
                      setState(() => _isUploadingImage = true);
                      try {
                        final url = await pickAndUploadImage();
                        if (url != null) {
                          setState(() => uploadedImageUrls.add(url));
                        }
                      } finally {
                        if (mounted) setState(() => _isUploadingImage = false);
                      }
                    },
                    onDelete: (index) {
                      setState(() => uploadedImageUrls.removeAt(index));
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // 4) Basic Info
                SectionCard(
                  title: "Basic Info",
                  subtitle: "Update details shown on your product page.",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ModernTextField(
                        controller: nameController,
                        label: "Product Name",
                        hint: "e.g., Pearl Handbag",
                        prefixIcon: Icons.shopping_bag_outlined,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "This appears on your product page",
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, box) {
                          final isStack = box.maxWidth < 520;
                          if (isStack) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ModernTextField(
                                  controller: priceController,
                                  label: "Price",
                                  hint: "e.g., 700",
                                  prefixIcon: Icons.currency_rupee,
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 12),
                                ModernTextField(
                                  controller: categoryController,
                                  label: "Category",
                                  hint: "Select category",
                                  prefixIcon: Icons.category_outlined,
                                  // dropdown feel
                                  suffixIcon: Icons.keyboard_arrow_down_rounded,
                                  readOnlyLook: true,
                                ),
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(
                                child: ModernTextField(
                                  controller: priceController,
                                  label: "Price",
                                  hint: "e.g., 700",
                                  prefixIcon: Icons.currency_rupee,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ModernTextField(
                                  controller: categoryController,
                                  label: "Category",
                                  hint: "Select category",
                                  prefixIcon: Icons.category_outlined,
                                  suffixIcon:
                                      Icons.keyboard_arrow_down_rounded,
                                  readOnlyLook: true,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 5) Availability
                SectionCard(
                  title: "Availability",
                  subtitle: "Control whether this product can be ordered.",
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _border),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Availability",
                            style: TextStyle(
                              color: _textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                        StatusBadge(
                          text: availability ? "In Stock" : "Out of Stock",
                          kind: availability
                              ? StatusBadgeKind.success
                              : StatusBadgeKind.danger,
                        ),
                        const SizedBox(width: 10),
                        Switch(
                          value: availability,
                          onChanged: isLoading
                              ? null
                              : (val) => setState(() => availability = val),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 6) Advanced (collapsible)
                SectionCard(
                  title: "Advanced",
                  subtitle: "Optional settings for power users.",
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsets.only(top: 12),
                      title: const Text(
                        "Advanced settings",
                        style: TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: const Text(
                        "Image URL is optional",
                        style: TextStyle(color: _textSecondary, fontSize: 12.5),
                      ),
                      children: [
                        ModernTextField(
                          controller: imageUrlController,
                          label: "Image URL",
                          hint: "Optional",
                          prefixIcon: Icons.link,
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
        boxShadow: const [
          // ✅ very soft, optional
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 15.5,
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

class ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final TextInputType keyboardType;
  final bool readOnlyLook;
  final Function(String)? onChanged;

  const ModernTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.readOnlyLook = false,
    this.onChanged,
  });

  static const _border = Color(0xFFE8ECF4);
  static const _primary = Color(0xFF6C63FF);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        readOnly: false, // ✅ keep editable (only "looks" like dropdown)
        style: const TextStyle(
          color: _textPrimary,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(color: _textSecondary),
          prefixIcon: prefixIcon == null
              ? null
              : Icon(prefixIcon, size: 20, color: _textSecondary),
          suffixIcon: suffixIcon == null
              ? null
              : Icon(suffixIcon, color: _textSecondary),
          filled: true,
          fillColor: const Color(0xFFF9FAFC),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _primary, width: 1.2),
          ),
        ),
      ),
    );
  }
}

enum StatusBadgeKind { success, danger, neutral }

class StatusBadge extends StatelessWidget {
  final String text;
  final StatusBadgeKind kind;

  const StatusBadge({
    super.key,
    required this.text,
    required this.kind,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (kind) {
      case StatusBadgeKind.success:
        bg = Colors.green.withOpacity(0.12);
        fg = Colors.green.shade700;
        break;
      case StatusBadgeKind.danger:
        bg = Colors.red.withOpacity(0.10);
        fg = Colors.red.shade700;
        break;
      case StatusBadgeKind.neutral:
      default:
        bg = const Color(0xFFE8ECF4);
        fg = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class ImageEditorStrip extends StatelessWidget {
  final List<String> imageUrls;
  final bool isUploading;
  final bool enabled;
  final VoidCallback onAdd;
  final void Function(int index) onDelete;

  const ImageEditorStrip({
    super.key,
    required this.imageUrls,
    required this.isUploading,
    required this.enabled,
    required this.onAdd,
    required this.onDelete,
  });

  static const _border = Color(0xFFE8ECF4);
  static const _textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    // Primary is index 0 (if exists)
    final primaryUrl = imageUrls.isNotEmpty ? imageUrls[0] : null;
    final thumbs = imageUrls.length > 1 ? imageUrls.sublist(1) : <String>[];

    return Column(
      children: [
        // Primary big tile
        Stack(
          children: [
            _ImageTile(
              size: 220,
              imageUrl: primaryUrl,
              isPrimary: true,
              badgeText: "Primary",
              enabled: enabled && !isUploading,
              onTap: primaryUrl == null ? onAdd : null, // tap to add if empty
              onDelete: primaryUrl == null ? null : () => onDelete(0),
            ),
            if (isUploading)
              Positioned.fill(
                child: _UploadOverlay(),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // Thumbnails row + Add tile
        SizedBox(
          height: 86,
          child: AbsorbPointer(
            absorbing: !enabled || isUploading,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (int i = 0; i < thumbs.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _ImageTile(
                      size: 86,
                      imageUrl: thumbs[i],
                      enabled: enabled,
                      onDelete: () => onDelete(i + 1),
                    ),
                  ),
                _AddTile(
                  size: 86,
                  enabled: enabled && !isUploading,
                  onTap: onAdd,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageTile extends StatelessWidget {
  final double size;
  final String? imageUrl;
  final bool enabled;
  final bool isPrimary;
  final String? badgeText;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const _ImageTile({
    required this.size,
    required this.imageUrl,
    required this.enabled,
    this.isPrimary = false,
    this.badgeText,
    this.onTap,
    this.onDelete,
  });

  static const _border = Color(0xFFE8ECF4);
  static const _textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Stack(
        children: [
          Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
              image: hasImage
                  ? DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: !hasImage
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add_photo_alternate_outlined,
                            color: _textSecondary),
                        SizedBox(height: 6),
                        Text(
                          "Add",
                          style: TextStyle(
                            color: _textSecondary,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),

          if (isPrimary && hasImage)
            Positioned(
              left: 10,
              top: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badgeText ?? "Primary",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),

          if (hasImage && onDelete != null)
            Positioned(
              right: 8,
              top: 8,
              child: GestureDetector(
                onTap: enabled ? onDelete : null,
                child: const CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  final double size;
  final bool enabled;
  final VoidCallback onTap;

  const _AddTile({
    required this.size,
    required this.enabled,
    required this.onTap,
  });

  static const _border = Color(0xFFE8ECF4);
  static const _textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: const Center(
          child: Icon(Icons.add, color: _textSecondary, size: 28),
        ),
      ),
    );
  }
}

class _UploadOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.30),
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
    );
  }
}

// Sticky bottom bar with loading state inside button
class _BottomSaveBar extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onSave;

  const _BottomSaveBar({
    required this.isLoading,
    required this.onSave,
  });

  static const _border = Color(0xFFE8ECF4);
  static const _primary = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            disabledBackgroundColor: _primary.withOpacity(0.55),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isLoading
                ? Row(
                    key: const ValueKey("saving"),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Saving…",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    "Save Changes",
                    key: ValueKey("save"),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}