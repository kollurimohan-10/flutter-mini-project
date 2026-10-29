import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';

class HostelInfoScreen extends StatefulWidget {
  const HostelInfoScreen({super.key});

  @override
  State<HostelInfoScreen> createState() => _HostelInfoScreenState();
}

class _HostelInfoScreenState extends State<HostelInfoScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hostel Rules & Contacts'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppTheme.accentTeal,
          tabs: const [
            Tab(text: 'Rules', icon: Icon(Icons.rule_folder_rounded, size: 20)),
            Tab(text: 'Mess Timings', icon: Icon(Icons.restaurant_rounded, size: 20)),
            Tab(text: 'Emergency', icon: Icon(Icons.emergency_rounded, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Rules & Policies
          ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: AppConstants.hostelRules.length,
            itemBuilder: (context, index) {
              final r = AppConstants.hostelRules[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavy.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '0${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r['title']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryNavy),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              r['desc']!,
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.35),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Tab 2: Mess Timings & Menu
          ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: AppConstants.messTimings.length,
            itemBuilder: (context, index) {
              final m = AppConstants.messTimings[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.flatware_rounded, color: AppTheme.primaryBlue, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                m['meal']!,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              m['time']!,
                              style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Text(
                        'Sample Menu:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        m['menu']!,
                        style: TextStyle(fontSize: 13.5, color: Colors.grey.shade800),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Tab 3: Emergency Contacts Directory
          ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: AppConstants.emergencyContacts.length,
            itemBuilder: (context, index) {
              final c = AppConstants.emergencyContacts[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.shade50,
                    child: const Icon(Icons.phone_in_talk_rounded, color: AppTheme.statusDanger),
                  ),
                  title: Text(c['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                  subtitle: Text(c['role']!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      c['phone']!,
                      style: const TextStyle(color: AppTheme.statusSuccess, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
