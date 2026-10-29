import 'package:flutter/material.dart';
import '../../services/mongo_service.dart';
import '../../models/complaint_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/custom_button.dart';

class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  final _mongo = MongoService();
  String _selectedStatus = 'All';
  String _selectedCategory = 'All';

  List<ComplaintModel> _getFilteredComplaints() {
    var list = _mongo.getComplaints();
    if (_selectedStatus != 'All') {
      list = list.where((c) => c.status == _selectedStatus).toList();
    }
    if (_selectedCategory != 'All') {
      list = list.where((c) => c.category == _selectedCategory).toList();
    }
    return list;
  }

  void _showComplaintResolutionDialog(ComplaintModel complaint) {
    String currentStatus = complaint.status;
    final notesController = TextEditingController(text: complaint.resolutionNotes ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Text(
                complaint.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StatusBadge(status: complaint.priority),
                        const SizedBox(width: 8),
                        StatusBadge(status: complaint.category),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Filed by: ${complaint.studentName} (${complaint.studentId})',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Text(
                      'Room: ${complaint.roomNumber} • Date: ${complaint.submissionDate}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        complaint.description,
                        style: const TextStyle(fontSize: 13, height: 1.3),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Update Status:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: currentStatus,
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                      items: [
                        AppConstants.complaintPending,
                        AppConstants.complaintInProgress,
                        AppConstants.complaintResolved,
                      ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => currentStatus = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Resolution Note / Action Taken',
                        hintText: 'e.g. Electrician scheduled / Washer replaced',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await _mongo.updateComplaintStatus(
                      complaint.id,
                      currentStatus,
                      notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
                    );
                    if (mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Complaint status updated to $currentStatus'), backgroundColor: AppTheme.statusSuccess),
                      );
                      setState(() {});
                    }
                  },
                  child: const Text('Save Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final complaints = _getFilteredComplaints();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints & Maintenance'),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('All (${_mongo.getComplaints().length})', 'All'),
                  const SizedBox(width: 8),
                  _filterChip('Pending (${_mongo.getComplaints().where((c) => c.status == "Pending").length})', 'Pending'),
                  const SizedBox(width: 8),
                  _filterChip('In Progress (${_mongo.getComplaints().where((c) => c.status == "In Progress").length})', 'In Progress'),
                  const SizedBox(width: 8),
                  _filterChip('Resolved (${_mongo.getComplaints().where((c) => c.status == "Resolved").length})', 'Resolved'),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: complaints.isEmpty
                ? EmptyStateView(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'No Complaints Found',
                    message: 'No grievances match the selected status filter.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: complaints.length,
                    itemBuilder: (context, index) {
                      final c = complaints[index];
                      return Card(
                        child: InkWell(
                          onTap: () => _showComplaintResolutionDialog(c),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        c.title,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    StatusBadge(status: c.status),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  c.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${c.studentName} (${c.roomNumber}) • ${c.category}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                    Row(
                                      children: [
                                        StatusBadge(status: c.priority, fontSize: 10.5),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.edit_note_rounded, size: 18, color: AppTheme.primaryBlue),
                                      ],
                                    ),
                                  ],
                                ),
                                if (c.resolutionNotes != null && c.resolutionNotes!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Action: ${c.resolutionNotes}',
                                      style: TextStyle(fontSize: 11.5, color: Colors.green.shade900, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isSelected = _selectedStatus == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedStatus = value),
      selectedColor: AppTheme.primaryNavy,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }
}
