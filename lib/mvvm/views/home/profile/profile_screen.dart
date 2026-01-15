import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mvvm/viewmodels/auth/auth_cubit.dart';
import 'package:frontend/mvvm/viewmodels/task/task_cubit.dart';
import 'package:frontend/mvvm/viewmodels/task/task_state.dart';
import 'package:frontend/mvvm/viewmodels/user_cubit.dart';
import 'package:frontend/mvvm/viewmodels/user_state.dart';
import 'package:frontend/mvvm/views/components/Custom_textField.dart';
import 'package:frontend/mvvm/views/components/custom_confirm_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
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
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, userState) {
          final user = userState.user;
          // KIỂM TRA GUEST: Nếu user null hoặc không có UID (chỉ dùng local hive)
          final bool isGuest = user == null || user.uid.isEmpty;
          
          final String userName = isGuest ? 'Guest User' : (user.displayName ?? 'User Name');
          final String? photoUrl = user?.photoUrl;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // 1. AVATAR & NAME
                  _buildAvatar(photoUrl, isGuest, user?.uid),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 25),

                  // 2. TASK STATISTICS (Vẫn cho khách xem stats từ Hive local)
                  _buildTaskStatsSection(),

                  const SizedBox(height: 30),

                  // 3. SETTINGS & ACCOUNT (PHẦN NÀY SẼ BỊ KHÓA NẾU LÀ GUEST)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Toàn bộ nội dung Menu
                      Opacity(
                        opacity: isGuest ? 0.2 : 1.0, // Làm mờ 80% nếu là khách
                        child: IgnorePointer(
                          ignoring: isGuest, // Khóa tương tác nếu là khách
                          child: Column(
                            children: [
                              _buildSectionLabel('Settings'),
                              _buildMenuItem(context, 'App Settings', Icons.settings_outlined, onTap: () {}),

                              const SizedBox(height: 20),

                              _buildSectionLabel('Account'),
                              _buildMenuItem(
                                context,
                                'Change account name',
                                Icons.person_outline,
                                onTap: () => _showUpdateNameDialog(context, userName, user?.uid),
                              ),
                              
                              // Ẩn Password nếu là Google, Hiện nếu là Email
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
                            ],
                          ),
                        ),
                      ),

                      // Overlay hiển thị khi là Guest
                      if (isGuest)
                        _buildGuestOverlay(context),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 4. UPTODO SECTION (Luôn mở cho tất cả)
                  _buildSectionLabel('Uptodo'),
                  _buildMenuItem(context, 'About US', Icons.info_outline, onTap: () {}),
                  _buildMenuItem(context, 'FAQ', Icons.help_outline, onTap: () {}),
                  
                  // Nút Logout / Login
                  _buildMenuItem(
                    context,
                    isGuest ? 'Back to Login' : 'Log out',
                    isGuest ? Icons.login : Icons.logout,
                    color: isGuest ? Colors.blue : Colors.redAccent,
                    onTap: () => isGuest 
                        ? Navigator.pushReplacementNamed(context, '/start')
                        : _showLogoutConfirmDialog(context),
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

  // --- WIDGET HELPERS ---

  Widget _buildAvatar(String? photoUrl, bool isGuest, String? uid) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 45,
          backgroundColor: Colors.grey[800],
          backgroundImage: (photoUrl != null && !isGuest) ? NetworkImage(photoUrl) : null,
          child: (photoUrl == null || isGuest)
              ? const Icon(Icons.person, size: 45, color: Colors.white)
              : null,
        ),
        if (!isGuest)
          GestureDetector(
            onTap: () => _showUpdateImageDialog(context, uid),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
            ),
          )
      ],
    );
  }

  Widget _buildGuestOverlay(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.lock_outline, color: Color(0xFF8687E7), size: 40),
        const SizedBox(height: 8),
        const Text(
          "Login to sync your data",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8687E7),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          onPressed: () => Navigator.pushNamed(context, '/login'),
          child: const Text("Login Now", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildTaskStatsSection() {
    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        int leftTasks = 0, doneTasks = 0;
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

  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon,
      {required VoidCallback onTap, Color? color}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Icon(icon, color: color ?? Colors.white, size: 24),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
    );
  }

  // --- DIALOGS ---

  void _showUpdateNameDialog(BuildContext context, String currentName, String? uid) {
    if (uid == null) return;
    _inputController.text = currentName;
    showDialog(
      context: context,
      builder: (ctx) => CustomConfirmDialog(
        title: 'Change account name',
        actionText: 'Update',
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: CustomTextField(controller: _inputController, hint: 'New name'),
        ),
        onActionPressed: () async {
          final newName = _inputController.text.trim();
          if (newName.isNotEmpty) {
            await context.read<UserCubit>().updateName(uid, newName);
            if (context.mounted) Navigator.pop(ctx);
          }
        },
      ),
    );
  }

  void _showUpdatePasswordDialog(BuildContext context) {
    _inputController.clear();
    showDialog(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: CustomConfirmDialog(
          title: 'Change Password',
          actionText: 'Change',
          content: CustomTextField(controller: _inputController, hint: 'New password', isPassword: true),
          onActionPressed: () async {
            final pass = _inputController.text.trim();
            if (pass.length >= 6) {
              await context.read<UserCubit>().changePassword(pass);
              if (context.mounted) Navigator.pop(ctx);
            }
          },
        ),
      ),
    );
  }

  void _showUpdateImageDialog(BuildContext context, String? uid) {
    if (uid == null) return;
    _inputController.clear();
    showDialog(
      context: context,
      builder: (ctx) => CustomConfirmDialog(
        title: 'Change Image URL',
        actionText: 'Update',
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: CustomTextField(controller: _inputController, hint: 'Paste image URL'),
        ),
        onActionPressed: () async {
          final url = _inputController.text.trim();
          if (url.isNotEmpty) {
            // await context.read<UserCubit>().updatePhotoUrl(uid, url);
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
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: const Text(
            'Are you sure you want to log out?',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
        onActionPressed: () async {
          await context.read<AuthCubit>().logOut();
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/start');
          }
        },
      ),
    );
  }
}