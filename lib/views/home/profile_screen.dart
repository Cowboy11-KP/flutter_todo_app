import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/viewmodels/auth_cubit.dart';
import 'package:frontend/viewmodels/task_cubit.dart';
import 'package:frontend/viewmodels/task_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // Lấy thông tin user hiện tại từ Firebase (hoặc bạn có thể lấy từ AuthCubit state)
    final user = FirebaseAuth.instance.currentUser;
    final String userName = user?.displayName ?? 'User Name';
    final String? photoUrl = user?.photoURL;

    return Scaffold(
      backgroundColor: Colors.black, // Màu nền đen theo design
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea( 
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // 1. AVATAR & NAME
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[800],
                backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                child: photoUrl == null
                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 10),
              Text(
                userName, // Tên user
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                ),
              ),
              
              const SizedBox(height: 20),
        
              // 2. TASK STATISTICS (Đếm số lượng task từ Cubit)
              BlocBuilder<TaskCubit, TaskState>(
                builder: (context, state) {
                  int leftTasks = 0;
                  int doneTasks = 0;
        
                  if (state is TaskLoaded) {
                    leftTasks = state.tasks.where((t) => !t.isDone).length;
                    doneTasks = state.tasks.where((t) => t.isDone).length;
                  } else if (state is TaskActionSuccess) {
                     leftTasks = state.tasks.where((t) => !t.isDone).length;
                     doneTasks = state.tasks.where((t) => t.isDone).length;
                  }
        
                  return Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Task left', leftTasks),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildStatCard('Task done', doneTasks),
                      ),
                    ],
                  );
                },
              ),
        
              const SizedBox(height: 30),
        
              // 3. SETTINGS SECTION
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Settings', style: TextStyle(color: Colors.grey[500])),
              ),
              const SizedBox(height: 10),
              _buildMenuItem(context, 'App Settings', Icons.settings_outlined, onTap: () {}),
        
              const SizedBox(height: 20),
        
              // 4. ACCOUNT SECTION
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Account', style: TextStyle(color: Colors.grey[500])),
              ),
              const SizedBox(height: 10),
              _buildMenuItem(context, 'Change account name', Icons.person_outline, onTap: () {}),
              _buildMenuItem(context, 'Change account password', Icons.vpn_key_outlined, onTap: () {}),
              _buildMenuItem(context, 'Change account Image', Icons.camera_alt_outlined, onTap: () {}),
        
              const SizedBox(height: 20),
        
              // 5. UPTODO SECTION
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Uptodo', style: TextStyle(color: Colors.grey[500])),
              ),
              const SizedBox(height: 10),
              _buildMenuItem(context, 'About US', Icons.info_outline, onTap: () {}),
              _buildMenuItem(context, 'FAQ', Icons.help_outline, onTap: () {}),
              _buildMenuItem(context, 'Help & Feedback', Icons.flash_on_outlined, onTap: () {}),
              _buildMenuItem(context, 'Support US', Icons.thumb_up_alt_outlined, onTap: () {}),
              _buildMenuItem(
                context, 
                'Log out', 
                Icons.logout, 
                color: Colors.redAccent,
                onTap: () {
                   _showLogoutConfirmDialog(context);
                }
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF363636), // Màu xám đậm nền button
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            '$count $label', // Ví dụ: 10 Task left
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Widget con: Các dòng Menu
  Widget _buildMenuItem(
    BuildContext context, 
    String title, 
    IconData icon, 
    {required VoidCallback onTap, Color? color}
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Icon(icon, color: color ?? Colors.white, size: 24),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 24, color: Colors.grey),
    );
  }

  // Hàm hiển thị dialog xác nhận đăng xuất
  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF363636),
        title: const Text('Log out', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to log out?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx);
              // Gọi Cubit để đăng xuất
              context.read<AuthCubit>().logOut();
            },
            child: const Text('Log out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}