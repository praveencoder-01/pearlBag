import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:food_website/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String _gender = "male"; // male | female
  bool _loading = true;
  bool _saving = false;

  String? _photoUrl; // from firestore/storage

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      FirebaseFirestore.instance.collection("users").doc(_uid);

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;

    // fallback values (auth)
    _emailCtrl.text = user?.email ?? "";
    _nameCtrl.text = user?.displayName ?? "";

    try {
      final snap = await _userDoc.get();
      final data = snap.data();

      if (data != null) {
        _nameCtrl.text = (data["name"] ?? _nameCtrl.text).toString();
        _ageCtrl.text = (data["age"] ?? "").toString();
        _phoneCtrl.text = (data["phone"] ?? "").toString();
        _gender = (data["gender"] ?? "male").toString();
        _photoUrl = data["photoUrl"]?.toString();
        _emailCtrl.text = (data["email"] ?? _emailCtrl.text).toString();
      }
    } catch (_) {
      // ignore, keep fallback values
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();

    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked == null) return;

    setState(() => _saving = true);

    try {
      final file = File(picked.path);

      final ref = FirebaseStorage.instance.ref("users/$_uid/profile.jpg");

      // upload
      await ref.putFile(file);

      // get url
      final url = await ref.getDownloadURL();

      // save url in firestore
      await _userDoc.set(
        {
          "photoUrl": url,
          "updatedAt": FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;
      setState(() => _photoUrl = url);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image upload failed: $e")),
      );
    } finally {
      if (!mounted) return;
      setState(() => _saving = false);
    }
  }

  Future<void> _saveDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final name = _nameCtrl.text.trim();
    final age = _ageCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = user.email ?? _emailCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name is required")),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await _userDoc.set(
        {
          "name": name,
          "age": age,
          "phone": phone,
          "gender": _gender,
          "email": email,
          "photoUrl": _photoUrl,
          "updatedAt": FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved ✅")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Save failed: $e")),
      );
    } finally {
      if (!mounted) return;
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal Details"),
        centerTitle: true,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          children: [
            const SizedBox(height: 10),

            // AVATAR + UPLOAD
            Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 82,
                      width: 82,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEFEF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: (_photoUrl != null && _photoUrl!.isNotEmpty)
                            ? Image.network(
                                _photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person,
                                  size: 46,
                                  color: Colors.black45,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 46,
                                color: Colors.black45,
                              ),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: InkWell(
                        onTap: _saving ? null : _pickAndUploadImage,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 26,
                          width: 26,
                          decoration: BoxDecoration(
 color: AppColors.card,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              )
                            ],
                          ),
                          child: _saving
                              ? const Padding(
                                  padding: EdgeInsets.all(6),
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.edit, size: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Upload image",
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _LabeledField(
              label: "Name",
              child: _UnderlineTextField(
                controller: _nameCtrl,
                hint: "Enter name",
              ),
            ),

            const SizedBox(height: 18),

            _LabeledField(
              label: "Gender",
              child: Row(
                children: [
                  _GenderChip(
                    text: "Male",
                    selected: _gender == "male",
                    onTap: () => setState(() => _gender = "male"),
                  ),
                  const SizedBox(width: 12),
                  _GenderChip(
                    text: "Female",
                    selected: _gender == "female",
                    onTap: () => setState(() => _gender = "female"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            _LabeledField(
              label: "Age",
              child: _UnderlineTextField(
                controller: _ageCtrl,
                hint: "e.g. 22 Year",
                keyboardType: TextInputType.text,
              ),
            ),

            const SizedBox(height: 18),

            _LabeledField(
              label: "Phone",
              child: _UnderlineTextField(
                controller: _phoneCtrl,
                hint: "Enter phone number",
                keyboardType: TextInputType.phone,
              ),
            ),

            const SizedBox(height: 18),

            _LabeledField(
              label: "Email",
              child: _UnderlineTextField(
                controller: _emailCtrl,
                hint: "Enter email",
                keyboardType: TextInputType.emailAddress,
                enabled: false,
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _saving ? "Saving..." : "Save",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- UI pieces ----------
class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 84,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black38,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _UnderlineTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool enabled;

  const _UnderlineTextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      style: const TextStyle(fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26),
        border: const UnderlineInputBorder(),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE2E2E2)),
        ),
        disabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE2E2E2)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E2E2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? Colors.white : Colors.black26,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        height: 6,
                        width: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black54,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
