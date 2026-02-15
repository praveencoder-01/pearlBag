import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    // ✅ Pre-fill from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final u = context.read<UserProvider>();
      _nameCtrl.text = u.name;
      _phoneCtrl.text = u.phone;
      _streetCtrl.text = u.address['street'] ?? '';
      _cityCtrl.text = u.address['city'] ?? '';
      _stateCtrl.text = u.address['state'] ?? '';
      _pincodeCtrl.text = u.address['pincode'] ?? '';
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  Widget _input(String label, TextEditingController c,
      {TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await context.read<UserProvider>().saveAddress(
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            street: _streetCtrl.text.trim(),
            city: _cityCtrl.text.trim(),
            state: _stateCtrl.text.trim(),
            pincode: _pincodeCtrl.text.trim(),
            country: "India",
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Address saved ✅")),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Address")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                _input("Full Name", _nameCtrl),
                const SizedBox(height: 12),
                _input("Phone", _phoneCtrl, type: TextInputType.phone),
                const SizedBox(height: 12),
                _input("Street / Address", _streetCtrl),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _input("City", _cityCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _input("State", _stateCtrl)),
                  ],
                ),
                const SizedBox(height: 12),
                _input("Pincode", _pincodeCtrl, type: TextInputType.number),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "SAVE ADDRESS",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
