import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/mongo_service.dart';
import '../../models/announcement_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/confirm_dialog.dart';

class AdminAnnouncementsScreen extends StatefulWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  State<AdminAnnouncementsScreen> createState() => _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState extends State<AdminAnnouncementsScreen> {
  final _mongo = MongoService();

  void _showAnnouncementModal([AnnouncementModel? existing]) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: existing?.title ?? '');
    final messageController = TextEditingController(text: existing?.message ?? '');
    final authorController = TextEditingController(text: existing?.author ?? 'Chief Warden Office');
    String priority = existing?.priority ?? 'Normal';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          existing != null ? 'Edit Announcement' : 'New Hostel Notice',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryNavy),
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: titleController,
                      label: 'Notice Title',
                      validator: (v) => Validators.requiredField(v, 'Title'),
                    ),
                    CustomTextField(
                      controller: messageController,
                      label: 'Notice Message / Details',
                      maxLines: 4,
                      validator: (v) => Validators.requiredField(v, 'Message'),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: priority,
                            decoration: const InputDecoration(labelText: 'Priority Level'),
                            items: ['Normal', 'Urgent'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                            onChanged: (val) {
                              if (val != null) setModalState(() => priority = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: authorController,
                            label: 'Author / Office',
                            validator: (v) => Validators.requiredField(v, 'Author'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: existing != null ? 'Update Notice' : 'Publish Broadcast',
                      icon: Icons.campaign_rounded,
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        final announcement = AnnouncementModel(
                          id: existing?.id ?? 'ANN_${DateTime.now().millisecondsSinceEpoch}',
                          title: titleController.text.trim(),
                          message: messageController.text.trim(),
                          date: existing?.date ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
                          priority: priority,
                          author: authorController.text.trim(),
                        );

                        if (existing != null) {
                          await _mongo.updateAnnouncement(announcement);
                        } else {
                          await _mongo.addAnnouncement(announcement);
                        }

                        if (mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(existing != null ? 'Notice updated' : 'Notice published to all residents!'),
                              backgroundColor: AppTheme.statusSuccess,
                            ),
                          );
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteAnnouncement(AnnouncementModel a) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Notice',
      message: 'Delete announcement "${a.title}"?',
      confirmText: 'Delete',
    );

    if (confirmed) {
      await _mongo.deleteAnnouncement(a.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notice deleted'), backgroundColor: AppTheme.statusDanger),
        );
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final announcements = _mongo.getAnnouncements();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hostel Announcements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alert_rounded),
            tooltip: 'New Notice',
            onPressed: () => _showAnnouncementModal(),
          ),
        ],
      ),
      body: announcements.isEmpty
          ? EmptyStateView(
              icon: Icons.campaign_outlined,
              title: 'No Announcements',
              message: 'No circulars or notices published yet.',
              actionText: 'Post Notice',
              onAction: () => _showAnnouncementModal(),
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
                        const SizedBox(height: 6),
                        Text(
                          a.message,
                          style: TextStyle(fontSize: 13.5, color: Colors.grey.shade800, height: 1.4),
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'By: ${a.author}',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.primaryBlue),
                                  onPressed: () => _showAnnouncementModal(a),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppTheme.statusDanger),
                                  onPressed: () => _deleteAnnouncement(a),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Post Notice'),
        onPressed: () => _showAnnouncementModal(),
      ),
    );
  }
}
