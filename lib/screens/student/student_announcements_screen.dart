import 'package:flutter/material.dart';
import '../../services/mongo_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state_view.dart';

class StudentAnnouncementsScreen extends StatelessWidget {
  const StudentAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final announcements = MongoService().getAnnouncements();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hostel Announcements'),
      ),
      body: announcements.isEmpty
          ? const EmptyStateView(
              icon: Icons.campaign_outlined,
              title: 'No Announcements',
              message: 'There are currently no new circulars or notices posted.',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final a = announcements[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            StatusBadge(status: a.priority),
                            Text(a.date, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          a.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          a.message,
                          style: TextStyle(fontSize: 13.5, color: Colors.grey.shade800, height: 1.4),
                        ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.verified_user_rounded, size: 16, color: AppTheme.primaryBlue),
                            const SizedBox(width: 6),
                            Text(
                              'Issued by: ${a.author}',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
