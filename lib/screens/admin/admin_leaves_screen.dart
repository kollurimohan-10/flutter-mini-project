import 'package:flutter/material.dart';
import '../../services/mongo_service.dart';
import '../../models/leave_request_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state_view.dart';

class AdminLeavesScreen extends StatefulWidget {
  const AdminLeavesScreen({super.key});

  @override
  State<AdminLeavesScreen> createState() => _AdminLeavesScreenState();
}

class _AdminLeavesScreenState extends State<AdminLeavesScreen> {
  final _mongo = MongoService();
  String _selectedStatus = 'All';

  List<LeaveRequestModel> _getFilteredLeaves() {
    var list = _mongo.getLeaveRequests();
    if (_selectedStatus != 'All') {
      list = list.where((l) => l.status == _selectedStatus).toList();
    }
    return list;
  }

  void _showReviewDialog(LeaveRequestModel leave) {
    final notesController = TextEditingController(text: leave.decisionNotes ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            'Review Leave Request',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(leave.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    StatusBadge(status: leave.status),
                  ],
                ),
                Text('Student ID: ${leave.studentId} • Applied: ${leave.appliedDate}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const Divider(height: 18),
                _infoRow(Icons.date_range_rounded, 'Duration', '${leave.startDate} to ${leave.returnDate}'),
                _infoRow(Icons.phone_rounded, 'Parent Contact', leave.parentContact),
                const SizedBox(height: 8),
                const Text('Reason for Leave:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                  child: Text(leave.reason, style: const TextStyle(fontSize: 13, height: 1.3)),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Warden Decision Note',
                    hintText: 'e.g. Parent confirmed via phone',
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.statusDanger,
                side: const BorderSide(color: AppTheme.statusDanger),
              ),
              onPressed: () async {
                await _mongo.updateLeaveStatus(
                  leave.id,
                  AppConstants.leaveRejected,
                  notesController.text.trim().isNotEmpty ? notesController.text.trim() : 'Rejected by warden',
                );
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Leave request rejected'), backgroundColor: AppTheme.statusDanger),
                  );
                  setState(() {});
                }
              },
              child: const Text('Reject'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.statusSuccess,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await _mongo.updateLeaveStatus(
                  leave.id,
                  AppConstants.leaveApproved,
                  notesController.text.trim().isNotEmpty ? notesController.text.trim() : 'Approved by warden',
                );
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Leave request approved!'), backgroundColor: AppTheme.statusSuccess),
                  );
                  setState(() {});
                }
              },
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryBlue),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final leaves = _getFilteredLeaves();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Applications'),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('All (${_mongo.getLeaveRequests().length})', 'All'),
                  const SizedBox(width: 8),
                  _filterChip('Pending (${_mongo.getLeaveRequests().where((l) => l.status == "Pending").length})', 'Pending'),
                  const SizedBox(width: 8),
                  _filterChip('Approved (${_mongo.getLeaveRequests().where((l) => l.status == "Approved").length})', 'Approved'),
                  const SizedBox(width: 8),
                  _filterChip('Rejected (${_mongo.getLeaveRequests().where((l) => l.status == "Rejected").length})', 'Rejected'),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: leaves.isEmpty
                ? EmptyStateView(
                    icon: Icons.flight_takeoff_outlined,
                    title: 'No Leave Requests',
                    message: 'No leave applications in this category.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: leaves.length,
                    itemBuilder: (context, index) {
                      final l = leaves[index];
                      return Card(
                        child: InkWell(
                          onTap: () => _showReviewDialog(l),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l.studentName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    StatusBadge(status: l.status),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Duration: ${l.startDate} to ${l.returnDate}',
                                  style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryNavy, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l.reason,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Parent: ${l.parentContact}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                    if (l.isPending)
                                      const Row(
                                        children: [
                                          Text('Tap to review', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                                          Icon(Icons.chevron_right, size: 16, color: AppTheme.primaryBlue),
                                        ],
                                      ),
                                  ],
                                ),
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
