import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../../../theme_provider.dart';
import 'UserInfo_Page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _goToUserInfo(context),
            child: const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/pr.jpg'),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _goToUserInfo(context),
            child: const Column(
              children: [
                Text(
                  'Ahmed Mostafa',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  'ahmed20@gmail.com',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 5),
                Text(
                  '+20 100 123 4567',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_6, color: Colors.blue),
                  title: Text(
                    isDarkMode ? "Switch to Light Mode" : "Switch to Dark Mode",
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    themeProvider.toggleTheme();
                  },
                ),
                const Divider(),

                _buildOption(
                  icon: Icons.person,
                  title: 'Show Profile',
                  onTap: () => _goToUserInfo(context),
                ),
                const Divider(),

                _buildOption(
                  icon: Icons.notifications,
                  title: 'Notification Settings',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("You have a new message request."),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const Divider(),

                _buildOption(
                  icon: Icons.logout,
                  title: 'Log Out',
                  color: Colors.red,
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    Color color = Colors.blue,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: color,
          fontWeight: color == Colors.red ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _goToUserInfo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserInfoPage()),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
