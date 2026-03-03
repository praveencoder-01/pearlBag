import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  User? get user => FirebaseAuth.instance.currentUser;

  // ===== DESIGN TOKENS =====
  static const _bg = Color(0xFFF6F7FB);
  static const _card = Colors.white;
  static const _border = Color(0xFFE8ECF4);
  static const _primary = Color(0xFF6C63FF);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final u = user;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
        title: const Text(
          "Settings",
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: _textPrimary),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _border),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                // Header subtitle (matches your admin dashboard vibe)
                const Text(
                  "Manage your admin account",
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 13.5,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                // Profile card
                SectionCard(
                  title: "Admin Profile",
                  subtitle: "Account details used for seller access.",
                  child: Row(
                    children: [
                      _Avatar(
                        letter: (u?.displayName?.isNotEmpty ?? false)
                            ? u!.displayName![0].toUpperCase()
                            : "A",
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              u?.displayName ?? "Admin",
                              style: const TextStyle(
                                color: _textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              u?.email ?? "admin@example.com",
                              style: const TextStyle(
                                color: _textSecondary,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x0F6C63FF),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0x226C63FF)),
                        ),
                        child: const Text(
                          "Admin",
                          style: TextStyle(
                            color: _primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Actions card
                SectionCard(
                  title: "Security & Session",
                  subtitle: "Keep your account secure.",
                  child: Column(
                    children: [
                      SettingsTile(
                        icon: Icons.lock_outline,
                        iconColor: _primary,
                        title: "Change Password",
                        subtitle: "Verify current password and update",
                        onTap: () {
                          if (u == null || u.email == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("No logged-in user found"),
                              ),
                            );
                            return;
                          }
                          _showChangePasswordDialog(u);
                        },
                      ),
                      const Divider(height: 1, color: _border),
                      SettingsTile(
                        icon: Icons.logout,
                        iconColor: Colors.red,
                        title: "Logout",
                        subtitle: "Sign out from this device",
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          if (!mounted) return;
                          Navigator.of(context).popUntil((r) => r.isFirst);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),
                const Text(
                  "Tip: Use a strong password (8+ chars) and avoid reusing old passwords.",
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Change Password Dialog (same behavior, modern UI)
  void _showChangePasswordDialog(User u) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    bool isVerified = false;
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
          contentPadding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            children: const [
              _DialogIcon(),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Change Password",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: _textPrimary,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isVerified
                    ? "Set a strong new password."
                    : "Verify your current password to continue.",
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 13,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 14),

              if (!isVerified)
                _ModernDialogField(
                  controller: currentPasswordController,
                  label: "Current Password",
                  icon: Icons.lock_outline,
                  obscure: true,
                ),

              if (isVerified)
                _ModernDialogField(
                  controller: newPasswordController,
                  label: "New Password",
                  icon: Icons.lock_reset_outlined,
                  obscure: true,
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: _textSecondary, fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  disabledBackgroundColor: _primary.withOpacity(0.55),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() => isLoading = true);

                        try {
                          if (!isVerified) {
                            final currentPassword =
                                currentPasswordController.text.trim();
                            if (currentPassword.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Enter current password"),
                                ),
                              );
                              return;
                            }

                            final cred = EmailAuthProvider.credential(
                              email: u.email!,
                              password: currentPassword,
                            );

                            await u.reauthenticateWithCredential(cred);

                            setState(() => isVerified = true);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Password verified")),
                            );
                          } else {
                            final newPassword =
                                newPasswordController.text.trim();
                            if (newPassword.length < 6) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Password must be at least 6 characters",
                                  ),
                                ),
                              );
                              return;
                            }

                            await u.updatePassword(newPassword);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Password updated successfully"),
                              ),
                            );

                            if (Navigator.canPop(context)) Navigator.pop(context);
                          }
                        } on FirebaseAuthException catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.message ?? e.code)),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: $e")),
                          );
                        } finally {
                          setState(() => isLoading = false);
                        }
                      },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: isLoading
                      ? const SizedBox(
                          key: ValueKey("loading"),
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isVerified ? "Update Password" : "Verify Password",
                          key: const ValueKey("label"),
                          style: const TextStyle(
                            fontSize: 14.5,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
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

// =======================
// Helper Widgets (UI only)
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

  static const _border = Color(0xFFE8ECF4);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 18,
            offset: Offset(0, 10),
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
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: const TextStyle(
                color: _textSecondary,
                fontSize: 12.5,
                height: 1.25,
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

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: _textSecondary,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: _textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String letter;
  const _Avatar({required this.letter});

  static const _primary = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _primary.withOpacity(0.35), width: 2),
      ),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: _primary.withOpacity(0.12),
        child: Text(
          letter,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: _primary,
          ),
        ),
      ),
    );
  }
}

class _DialogIcon extends StatelessWidget {
  const _DialogIcon();

  static const _primary = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      width: 34,
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.lock_outline, color: _primary, size: 18),
    );
  }
}

class _ModernDialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;

  const _ModernDialogField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.obscure,
  });

  static const _border = Color(0xFFE8ECF4);
  static const _textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _textSecondary),
        filled: true,
        fillColor: const Color(0xFFF9FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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