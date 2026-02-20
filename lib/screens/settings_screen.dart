import 'package:flutter/material.dart';
import 'package:food_website/screens/change_password_screen.dart';
import 'package:food_website/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsOn = true;
  bool _darkModeOn = false;

  String _language = "English";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
 color: AppColors.card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: [
                  SettingsRowArrow(
                    icon: Icons.language_rounded,
                    title: "Language",
                    trailingText: _language,
                    onTap: () async {
                      // simple demo (you can replace with bottom sheet)
                      final selected = await showModalBottomSheet<String>(
                        context: context,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(22),
                          ),
                        ),
                        builder: (_) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 10),
                              const Text(
                                "Select Language",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ListTile(
                                title: const Text("English"),
                                onTap: () => Navigator.pop(context, "English"),
                              ),
                              ListTile(
                                title: const Text("Hindi"),
                                onTap: () => Navigator.pop(context, "Hindi"),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      );

                      if (selected != null) {
                        setState(() => _language = selected);
                      }
                    },
                  ),

                  const _RowDivider(),

                  SettingsRowSwitch(
                    icon: Icons.notifications_rounded,
                    title: "Notification",
                    value: _notificationsOn,
                    onChanged: (v) => setState(() => _notificationsOn = v),
                  ),

                  const _RowDivider(),

                  SettingsRowSwitch(
                    icon: Icons.dark_mode_rounded,
                    title: "Dark Mood",
                    value: _darkModeOn,
                    onChanged: (v) => setState(() => _darkModeOn = v),
                    trailingText: _darkModeOn ? "on" : "off",
                  ),

                  const _RowDivider(),

                  SettingsRowArrow(
                    icon: Icons.help_outline_rounded,
                    title: "Help Center",
                    onTap: () {
                      // TODO: open help center page
                    },
                  ),

                  const _RowDivider(),

                  // ✅ Keep your Change Password here
                  SettingsRowArrow(
                    icon: Icons.lock_rounded,
                    title: "Change Password",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                    showDivider: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------- ROW WIDGETS (same style as screenshot) ----------

class SettingsRowArrow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final VoidCallback onTap;
  final bool showDivider;

  const SettingsRowArrow({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingText,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                _IconBox(icon: icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (trailingText != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      trailingText!,
                      style: const TextStyle(
                        color: Colors.black45,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              ],
            ),
          ),
        ),
        if (showDivider) const _RowDivider(),
      ],
    );
  }
}

class SettingsRowSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? trailingText;

  const SettingsRowSwitch({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _IconBox(icon: icon),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (trailingText != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                trailingText!,
                style: const TextStyle(
                  color: Colors.black45,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  const _IconBox({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      width: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(padding: EdgeInsets.only(left: 64, right: 14),);
  }
}
