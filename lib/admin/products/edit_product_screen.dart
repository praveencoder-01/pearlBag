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
  List<String> uploadedImageUrls = [];

  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController categoryController;
  late TextEditingController imageUrlController;

  bool availability = true;
  bool isLoading = false;

@override
void initState() {
  super.initState();

  nameController =
      TextEditingController(text: widget.productData['name']);
  priceController =
      TextEditingController(text: widget.productData['price'].toString());
  categoryController =
      TextEditingController(text: widget.productData['category']);
  imageUrlController =
      TextEditingController(text: widget.productData['imageUrl'] ?? "");

  availability = widget.productData['availability'] ?? true;

  // 🔥 Ye line add karo
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
  'imageUrls': uploadedImageUrls, // 🔥 Save all remaining images
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
  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF3F3D56)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    Row(
                      children: const [
                        Icon(Icons.edit, color: Color(0xFF6C63FF)),
                        SizedBox(width: 8),
                        Text(
                          "Edit Product",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// IMAGE PREVIEW (STYLISH)
                   
SizedBox(
  height: 100,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: uploadedImageUrls.length < 4
        ? uploadedImageUrls.length + 1 // 🔹 ek extra slot for adding
        : uploadedImageUrls.length,
    itemBuilder: (context, index) {
      if (index < uploadedImageUrls.length) {
        // 🔹 Existing image
        return Stack(
          children: [
            Container(
              margin: const EdgeInsets.all(8),
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                image: DecorationImage(
                  image: NetworkImage(uploadedImageUrls[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    uploadedImageUrls.removeAt(index); // remove
                  });
                },
                child: const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      } else {
        // 🔹 Add Image slot
        return GestureDetector(
          onTap: () async {
            String? newImageUrl = await pickAndUploadImage();
            if (newImageUrl != null) {
              setState(() {
                uploadedImageUrls.add(newImageUrl);
              });
            }
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.grey.shade200,
            ),
            child: const Icon(Icons.add, size: 40, color: Colors.grey),
          ),
        );
      }
    },
  ),
),

                    const SizedBox(height: 24),

                    /// PRODUCT NAME
                    _styledField(
                      controller: nameController,
                      label: "Product Name",
                      icon: Icons.shopping_bag,
                    ),

                    const SizedBox(height: 14),

                    /// PRICE & CATEGORY
                    Row(
                      children: [
                        Expanded(
                          child: _styledField(
                            controller: priceController,
                            label: "Price",
                            icon: Icons.currency_rupee,
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _styledField(
                            controller: categoryController,
                            label: "Category",
                            icon: Icons.category,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    /// IMAGE URL
                    _styledField(
                      controller: imageUrlController,
                      label: "Image URL",
                      icon: Icons.link,
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 20),

                    /// AVAILABILITY
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: availability
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            availability ? "In Stock" : "Out of Stock",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: availability
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          Switch(
                            value: availability,
                            onChanged: (val) =>
                                setState(() => availability = val),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    /// UPDATE BUTTON
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: updateProduct,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF6C63FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 6,
                              ),
                              child: const Text(
                                "Save Changes",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}

Widget _styledField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  bool isNumber = false,
  Function(String)? onChanged,
}) {
  return TextField(
    controller: controller,
    keyboardType:
        isNumber ? TextInputType.number : TextInputType.text,
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
