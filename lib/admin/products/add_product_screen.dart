import 'dart:io'; // Add at the top

import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    // 🔴 IMPORTANT CHECK
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
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      pickedImages[index] = image;
      isUploadingImage = true;
    });

    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = FirebaseStorage.instance.ref().child(
      'product_images/$fileName.png',
    );

    final bytes = await image.readAsBytes();
    await ref.putData(bytes, SettableMetadata(contentType: 'image/png'));

    final url = await ref.getDownloadURL();

    setState(() {
      uploadedImageUrls[index] = url;
      isUploadingImage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Add New Product",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF3F3D56)],
            ),
          ),
        ),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// IMAGE PREVIEW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(4, (i) {
                        return GestureDetector(
                          onTap: () => pickImage(i),
                          child: Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.shade200,
                              image: uploadedImageUrls[i] != null
                                  ? DecorationImage(
                                      image: kIsWeb
                                          ? NetworkImage(uploadedImageUrls[i]!)
                                                as ImageProvider
                                          : (pickedImages[i] != null
                                                    ? FileImage(
                                                        File(
                                                          pickedImages[i]!.path,
                                                        ),
                                                      )
                                                    : const AssetImage(
                                                        'assets/placeholder.png',
                                                      ))
                                                as ImageProvider,
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: uploadedImageUrls[i] == null
                                ? const Icon(
                                    Icons.add_a_photo,
                                    size: 30,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                        );
                      }),
                    ),

                    _inputField(
                      controller: nameController,
                      label: "Product Name",
                      icon: Icons.shopping_bag,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _inputField(
                            controller: priceController,
                            label: "Price",
                            keyboardType: TextInputType.number,
                            icon: Icons.currency_rupee,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _inputField(
                            controller: categoryController,
                            label: "Category",
                            icon: Icons.category,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// AVAILABILITY
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? Colors.green.withOpacity(0.12)
                            : Colors.red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: SwitchListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        value: isAvailable,
                        onChanged: (val) => setState(() => isAvailable = val),
                        title: Text(
                          isAvailable ? "In Stock" : "Out of Stock",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isAvailable ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    const SizedBox(height: 18),

                    /// DESCRIPTION
                    TextFormField(
  controller: _descCtrl,
  maxLines: 5,
  validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
  decoration: const InputDecoration(
    labelText: "Description",
    border: OutlineInputBorder(),
    alignLabelWithHint: true,
  ),
),


                    const SizedBox(height: 14),

                    /// SHIPPING POLICY
                   TextFormField(
  controller: _shipCtrl,
  maxLines: 4,
  validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
  decoration: const InputDecoration(
    labelText: "Shipping Policy",
    border: OutlineInputBorder(),
    alignLabelWithHint: true,
  ),
),


                    const SizedBox(height: 14),

                    /// RETURN POLICY
                    TextFormField(
  controller: _returnCtrl,
  maxLines: 4,
  validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
  decoration: const InputDecoration(
    labelText: "Return Policy",
    border: OutlineInputBorder(),
    alignLabelWithHint: true,
  ),
),




                    /// BUTTON
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text(
                                "Add Product",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C63FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: addProduct,
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
