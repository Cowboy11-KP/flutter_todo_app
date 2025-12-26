import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/viewmodels/auth_cubit.dart';
import 'package:frontend/viewmodels/task_cubit.dart';
import 'package:frontend/viewmodels/task_state.dart';
import 'package:frontend/viewmodels/user_cubit.dart';
import 'package:frontend/viewmodels/user_state.dart';
import 'package:frontend/views/components/Custom_textField.dart';
import 'package:frontend/views/components/custom_confirm_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
        ),
      ),
      // Dùng BlocBuilder để lắng nghe dữ liệu từ UserCubit
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, userState) {
          final user = userState.user;
          final String userName = user?.displayName ?? 'User Name';
          final String? photoUrl = user?.photoUrl;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // 1. AVATAR & NAME (Cập nhật từ UserState)
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                            ? NetworkImage(photoUrl)
                            : null,
                        child: (photoUrl == null || photoUrl.isEmpty)
                            ? const Icon(Icons.person, size: 45, color: Colors.white)
                            : null,
                      ),
                      // Nút đổi ảnh nhanh
                      GestureDetector(
                        onTap: () => _showUpdateImageDialog(context, user?.uid),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 25),

                  // 2. TASK STATISTICS (Lắng nghe TaskCubit)
                  _buildTaskStatsSection(),

                  const SizedBox(height: 30),

                  // 3. SETTINGS SECTION
                  _buildSectionLabel('Settings'),
                  _buildMenuItem(context, 'App Settings', Icons.settings_outlined, onTap: () {}),

                  const SizedBox(height: 20),

                  // 4. ACCOUNT SECTION
                  _buildSectionLabel('Account'),
                  _buildMenuItem(
                    context,
                    'Change account name',
                    Icons.person_outline,
                    onTap: () => _showUpdateNameDialog(context, userName, user?.uid),
                  ),
                  if (user?.authMethod != 'google.com')
                    _buildMenuItem(
                      context,
                      'Change account password',
                      Icons.vpn_key_outlined,
                      onTap: () => _showUpdatePasswordDialog(context),
                    ),
                  _buildMenuItem(
                    context,
                    'Change account Image',
                    Icons.camera_alt_outlined,
                    onTap: () => _showUpdateImageDialog(context, user?.uid),
                  ),

                  const SizedBox(height: 20),

                  // 5. UPTODO SECTION
                  _buildSectionLabel('Uptodo'),
                  _buildMenuItem(context, 'About US', Icons.info_outline, onTap: () {}),
                  _buildMenuItem(context, 'FAQ', Icons.help_outline, onTap: () {}),
                  _buildMenuItem(context, 'Help & Feedback', Icons.flash_on_outlined, onTap: () {}),
                  _buildMenuItem(context, 'Support US', Icons.thumb_up_alt_outlined, onTap: () {}),
                  _buildMenuItem(
                    context,
                    'Log out',
                    Icons.logout,
                    color: Colors.redAccent,
                    onTap: () => _showLogoutConfirmDialog(context),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          label,
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildTaskStatsSection() {
    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        int leftTasks = 0;
        int doneTasks = 0;
        if (state is TaskLoaded) {
          leftTasks = state.tasks.where((t) => !t.isDone).length;
          doneTasks = state.tasks.where((t) => t.isDone).length;
        }
        return Row(
          children: [
            Expanded(child: _buildStatCard('$leftTasks Task left')),
            const SizedBox(width: 20),
            Expanded(child: _buildStatCard('$doneTasks Task done')),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF363636),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon,
      {required VoidCallback onTap, Color? color}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Icon(icon, color: color ?? Colors.white, size: 24),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
    );
  }

  // --- DIALOGS ---

  void _showUpdateNameDialog(BuildContext context, String currentName, String? uid) {
    if (uid == null) return;
    _nameController.text = currentName;
    showDialog(
      context: context,
      builder: (ctx) => CustomConfirmDialog(
        title: 'Change account name',
        actionText: 'Update',
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: CustomTextField(
            controller: _nameController,
            hint: 'Enter new name',
          ),
        ),
        onActionPressed: () async {
          final newName = _nameController.text.trim();
          if (newName.isNotEmpty) {
            await context.read<UserCubit>().updateName(uid, newName);
            if (context.mounted) Navigator.pop(ctx);
          }
        },
      ),
    );
  }

  void _showUpdateImageDialog(BuildContext context, String? uid) {
    if (uid == null) return;
    _nameController.clear();
    showDialog(
      context: context,
      builder: (ctx) => CustomConfirmDialog(
        title: 'Change Image URL',
        actionText: 'Update',
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: CustomTextField(
            controller: _nameController,
            hint: 'Paste image URL here',
          ),
        ),
        onActionPressed: () async {
          final url = _nameController.text.trim();
          if (url.isNotEmpty) {
            // await context.read<UserCubit>().updatePhotoUrl(uid, url);
            if (context.mounted) Navigator.pop(ctx);
          }
        },
      ),
    );
  }

  void _showUpdatePasswordDialog(BuildContext context) {
    _nameController.clear();
    showDialog(
      context: context,
      builder: (ctx) => CustomConfirmDialog(
        title: 'Change Password',
        actionText: 'Change',
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: CustomTextField(
            controller: _nameController,
            hint: 'Enter new password',
            // obscureText: true, // Nếu CustomTextField có hỗ trợ ẩn mật khẩu
          ),
        ),
        onActionPressed: () async {
          final pass = _nameController.text.trim();
          if (pass.length >= 6) {
            await context.read<UserCubit>().changePassword(pass);
            if (context.mounted) Navigator.pop(ctx);
          }
        },
      ),
    );
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => CustomConfirmDialog(
        title: 'Log out',
        actionText: 'Log out',
        actionColor: Colors.redAccent,
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: const Text(
            'Are you sure you want to log out?',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
        onActionPressed: () async {
          await context.read<AuthCubit>().logOut();
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/start', (route) => false);
          }
        },
      ),
    );
  }
}