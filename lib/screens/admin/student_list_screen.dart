import 'package:flutter/material.dart';
import '../../services/mongo_service.dart';
import '../../models/student_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/confirm_dialog.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final _mongo = MongoService();
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StudentModel> _getFilteredStudents() {
    final query = _searchController.text.trim().toLowerCase();
    var list = _mongo.getStudents();

    if (_selectedFilter == 'Allocated') {
      list = list.where((s) => s.isAllocated).toList();
    } else if (_selectedFilter == 'Unallocated') {
      list = list.where((s) => !s.isAllocated).toList();
    }

    if (query.isNotEmpty) {
      list = list.where((s) {
        return s.name.toLowerCase().contains(query) ||
               s.id.toLowerCase().contains(query) ||
               s.rollNo.toLowerCase().contains(query) ||
               s.course.toLowerCase().contains(query) ||
               (s.roomNumber?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    return list;
  }

  void _confirmDelete(StudentModel student) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Student Record',
      message: 'Are you sure you want to delete ${student.name} (${student.id})? This will also release any allocated room bed.',
      confirmText: 'Delete Record',
      icon: Icons.delete_forever_rounded,
    );

    if (confirmed) {
      await _mongo.deleteStudent(student.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${student.name} deleted successfully'),
            backgroundColor: AppTheme.statusDanger,
          ),
        );
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final students = _getFilteredStudents();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add New Student',
            onPressed: () => Navigator.pushNamed(context, '/student_form').then((_) => setState(() {})),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search by name, ID, roll no, or room...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 22),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip('All (${_mongo.getStudents().length})', 'All'),
                      const SizedBox(width: 8),
                      _filterChip('Allocated (${_mongo.getStudents().where((s) => s.isAllocated).length})', 'Allocated'),
                      const SizedBox(width: 8),
                      _filterChip('Unallocated (${_mongo.getStudents().where((s) => !s.isAllocated).length})', 'Unallocated'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Student List
          Expanded(
            child: students.isEmpty
                ? EmptyStateView(
                    icon: Icons.person_off_rounded,
                    title: 'No Students Found',
                    message: _searchController.text.isNotEmpty
                        ? 'No students match your search "${_searchController.text}".'
                        : 'No student records in this category.',
                    actionText: 'Register New Student',
                    onAction: () => Navigator.pushNamed(context, '/student_form').then((_) => setState(() {})),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final s = students[index];
                      return Card(
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/student_details',
                              arguments: s.id,
                            ).then((_) => setState(() {}));
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: s.gender == 'Female' ? Colors.pink.shade50 : Colors.blue.shade50,
                                  child: Text(
                                    s.initials,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: s.gender == 'Female' ? Colors.pink.shade700 : AppTheme.primaryBlue,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              s.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: s.isAllocated ? Colors.green.shade50 : Colors.amber.shade50,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: s.isAllocated ? Colors.green.shade200 : Colors.amber.shade200,
                                              ),
                                            ),
                                            child: Text(
                                              s.isAllocated ? 'Room ${s.roomNumber}' : 'No Room',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: s.isAllocated ? Colors.green.shade800 : Colors.amber.shade900,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'ID: ${s.id} • Roll: ${s.rollNo}',
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${s.course} (${s.year})',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
                                  onSelected: (val) {
                                    if (val == 'view') {
                                      Navigator.pushNamed(context, '/student_details', arguments: s.id).then((_) => setState(() {}));
                                    } else if (val == 'edit') {
                                      Navigator.pushNamed(context, '/student_form', arguments: s).then((_) => setState(() {}));
                                    } else if (val == 'delete') {
                                      _confirmDelete(s);
                                    }
                                  },
                                  itemBuilder: (ctx) => [
                                    const PopupMenuItem(value: 'view', child: Text('View Details')),
                                    const PopupMenuItem(value: 'edit', child: Text('Edit Info')),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete Student', style: TextStyle(color: AppTheme.statusDanger)),
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Student'),
        onPressed: () => Navigator.pushNamed(context, '/student_form').then((_) => setState(() {})),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = value),
      selectedColor: AppTheme.primaryNavy,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }
}
