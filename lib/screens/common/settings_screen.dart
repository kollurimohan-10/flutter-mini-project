import 'package:flutter/material.dart';
import '../../services/mongo_service.dart';
import '../../services/mongo_config.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/confirm_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _mongo = MongoService();
  late TextEditingController _uriController;
  bool _isConnecting = false;
  bool _isSeeding = false;

  @override
  void initState() {
    super.initState();
    _uriController = TextEditingController(text: MongoConfig.activeUri);
  }

  @override
  void dispose() {
    _uriController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() => _isConnecting = true);
    final uri = _uriController.text.trim();
    final success = await _mongo.connect(uri);
    setState(() => _isConnecting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Connected successfully to MongoDB!' : 'Could not connect to MongoDB. Using resilient local cache.'),
          backgroundColor: success ? AppTheme.statusSuccess : Colors.orange,
        ),
      );
    }
  }

  Future<void> _seedDatabase() async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Reset & Seed Database',
      message: 'This will reset all MongoDB collections and populate them with standard fictional test records (10 students, 5+ rooms, attendance, fees, complaints, and leaves). Proceed?',
      confirmText: 'Seed Database',
      icon: Icons.cloud_upload_rounded,
      confirmColor: AppTheme.primaryBlue,
    );

    if (confirmed) {
      setState(() => _isSeeding = true);
      await _mongo.seedDatabase();
      setState(() => _isSeeding = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sample data seeded successfully into MongoDB!'),
            backgroundColor: AppTheme.statusSuccess,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _mongo.isConnected;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Database'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MongoDB Connection Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.storage_rounded, color: isConnected ? AppTheme.statusSuccess : Colors.orange),
                            const SizedBox(width: 8),
                            const Text(
                              'MongoDB Connection',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isConnected ? AppTheme.statusSuccess : Colors.orange).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isConnected ? 'Online' : 'Offline Mode',
                            style: TextStyle(
                              color: isConnected ? AppTheme.statusSuccess : Colors.orange.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Connection URI string (Atlas or Localhost):',
                      style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                    ),
                    CustomTextField(
                      controller: _uriController,
                      label: 'MongoDB URI',
                      hint: 'mongodb://10.0.2.2:27017/hostel_db',
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Test / Reconnect',
                            icon: Icons.sync_rounded,
                            isLoading: _isConnecting,
                            onPressed: _testConnection,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '• Android Emulator Local: mongodb://10.0.2.2:27017/hostel_db\n'
                      '• Physical Device or Desktop: mongodb://127.0.0.1:27017/hostel_db\n'
                      '• MongoDB Atlas: mongodb+srv://<user>:<password>@cluster0.mongodb.net/hostel_db',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Demonstration / Seeding Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.dataset_rounded, color: AppTheme.primaryNavy),
                        const SizedBox(width: 8),
                        const Text(
                          'Lab Viva & Demo Controls',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Instantly reset the system with at least 10 realistic students, 5+ rooms across floors, attendance records, fee transactions with receipts, complaints, and leave applications.',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.35),
                    ),
                    const SizedBox(height: 14),
                    CustomButton(
                      text: 'Seed / Reload Sample Data',
                      icon: Icons.cloud_download_rounded,
                      color: AppTheme.accentTeal,
                      isLoading: _isSeeding,
                      onPressed: _seedDatabase,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // College Mini Project Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Project Information',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryNavy),
                    ),
                    const Divider(height: 18),
                    _infoRow('Project Name', 'Hostel Student Management System'),
                    _infoRow('Framework', 'Flutter (Dart)'),
                    _infoRow('Database', 'MongoDB (mongo_dart driver)'),
                    _infoRow('Design Standard', 'Material Design 3 (Navy & Teal)'),
                    _infoRow('Purpose', 'College Flutter Lab Mini Project'),
                    _infoRow('Version', 'v1.0.0'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Logout Button
            CustomButton(
              text: 'Sign Out of Account',
              icon: Icons.logout_rounded,
              color: AppTheme.statusDanger,
              onPressed: () async {
                final confirm = await ConfirmDialog.show(
                  context: context,
                  title: 'Sign Out',
                  message: 'Are you sure you want to log out?',
                  confirmText: 'Sign Out',
                );
                if (confirm && context.mounted) {
                  AuthService().logout();
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
