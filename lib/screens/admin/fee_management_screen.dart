import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/mongo_service.dart';
import '../../models/fee_payment_model.dart';
import '../../models/student_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class FeeManagementScreen extends StatefulWidget {
  const FeeManagementScreen({super.key});

  @override
  State<FeeManagementScreen> createState() => _FeeManagementScreenState();
}

class _FeeManagementScreenState extends State<FeeManagementScreen> with SingleTickerProviderStateMixin {
  final _mongo = MongoService();
  final _currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showRecordPaymentModal([StudentModel? preselectedStudent]) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final remarksController = TextEditingController();
    String? selectedStudentId = preselectedStudent?.id;
    String selectedMethod = AppConstants.paymentMethods.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final students = _mongo.getStudents();
            final currentStudent = selectedStudentId != null ? _mongo.getStudentById(selectedStudentId!) : null;
            final currentDue = selectedStudentId != null ? _mongo.getDueAmountForStudent(selectedStudentId!) : 0.0;

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
                        const Text(
                          'Record Fee Payment',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryNavy),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Student Selector
                    DropdownButtonFormField<String>(
                      value: selectedStudentId,
                      decoration: const InputDecoration(labelText: 'Select Student'),
                      items: students.map((s) {
                        final due = _mongo.getDueAmountForStudent(s.id);
                        return DropdownMenuItem(
                          value: s.id,
                          child: Text('${s.name} (${s.id}) - Due: ${_currency.format(due)}'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setModalState(() => selectedStudentId = val);
                      },
                      validator: (v) => v == null ? 'Please select a student' : null,
                    ),

                    if (currentStudent != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Outstanding Due: ${_currency.format(currentDue)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                            Text('Total Fee: ${_currency.format(currentStudent.feeAmount)}', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: amountController,
                      label: 'Payment Amount (₹)',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.currency_rupee_rounded,
                      validator: (v) => Validators.validateNumber(v, 'Amount'),
                    ),

                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedMethod,
                      decoration: const InputDecoration(labelText: 'Payment Method'),
                      items: AppConstants.paymentMethods
                          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedMethod = val);
                      },
                    ),

                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: remarksController,
                      label: 'Remarks / Transaction Ref',
                      hint: 'e.g. Bank ref #8291, Cash slip #12',
                    ),

                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Submit Payment & Issue Receipt',
                      icon: Icons.receipt_long_rounded,
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                        final receiptNo = 'REC-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';

                        final payment = FeePaymentModel(
                          id: 'PAY_${DateTime.now().millisecondsSinceEpoch}',
                          studentId: selectedStudentId!,
                          studentName: currentStudent?.name ?? 'Student',
                          amount: amount,
                          paymentDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                          paymentMethod: selectedMethod,
                          receiptNo: receiptNo,
                          remarks: remarksController.text.trim().isNotEmpty ? remarksController.text.trim() : 'Fee payment recorded',
                        );

                        await _mongo.addFeePayment(payment);
                        if (mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Payment of ${_currency.format(amount)} recorded! Receipt: $receiptNo'),
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

  void _showStudentHistory(StudentModel student) {
    final payments = _mongo.getPaymentsForStudent(student.id);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Fee Receipts History (${student.id})', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              if (payments.isEmpty)
                const Expanded(child: Center(child: Text('No fee payments recorded yet.')))
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: payments.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final p = payments[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade50,
                          child: const Icon(Icons.receipt_rounded, color: AppTheme.statusSuccess, size: 20),
                        ),
                        title: Text(_currency.format(p.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${p.paymentDate} • ${p.paymentMethod} • ${p.receiptNo}'),
                        trailing: const Icon(Icons.check_circle_rounded, color: AppTheme.statusSuccess, size: 18),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final students = _mongo.getStudents();
    final payments = _mongo.getFeePayments();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hostel Fee Management'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppTheme.accentTeal,
          tabs: const [
            Tab(text: 'Student Dues', icon: Icon(Icons.people_outline_rounded, size: 20)),
            Tab(text: 'Payment History', icon: Icon(Icons.history_rounded, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Student Fee Overview & Dues
          Column(
            children: [
              // Totals Banner
              Container(
                color: Colors.blueGrey.shade50,
                padding: const EdgeInsets.all(14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _summaryBlock('Expected Fees', _currency.format(_mongo.totalExpectedFees), Colors.grey.shade800),
                    _summaryBlock('Collected', _currency.format(_mongo.totalCollectedFees), AppTheme.statusSuccess),
                    _summaryBlock('Total Due', _currency.format(_mongo.totalPendingFees), AppTheme.statusDanger),
                  ],
                ),
              ),

              // Student Dues List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final s = students[index];
                    final paid = _mongo.getTotalPaidForStudent(s.id);
                    final due = _mongo.getDueAmountForStudent(s.id);
                    final status = _mongo.getPaymentStatusForStudent(s.id);

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    Text('ID: ${s.id} • Room: ${s.roomNumber ?? "None"}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
                                  ],
                                ),
                                StatusBadge(status: status),
                              ],
                            ),
                            const Divider(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total: ${_currency.format(s.feeAmount)}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                                    Text('Paid: ${_currency.format(paid)}', style: const TextStyle(fontSize: 12, color: AppTheme.statusSuccess, fontWeight: FontWeight.w600)),
                                    Text('Due: ${_currency.format(due)}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: due > 0 ? AppTheme.statusDanger : Colors.grey.shade700)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      ),
                                      onPressed: () => _showStudentHistory(s),
                                      child: const Text('History', style: TextStyle(fontSize: 12)),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryBlue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      ),
                                      onPressed: () => _showRecordPaymentModal(s),
                                      child: const Text('Pay', style: TextStyle(fontSize: 12)),
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
              ),
            ],
          ),

          // Tab 2: All Payment History Records
          ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final p = payments[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade50,
                    child: const Icon(Icons.receipt_rounded, color: AppTheme.statusSuccess),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(p.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                      Text(_currency.format(p.amount), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.statusSuccess, fontSize: 15)),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text('Receipt: ${p.receiptNo} • ${p.paymentMethod}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                      Text('${p.paymentDate} • ${p.remarks ?? ""}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.payment_rounded),
        label: const Text('Record Payment'),
        onPressed: () => _showRecordPaymentModal(),
      ),
    );
  }

  Widget _summaryBlock(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700)),
      ],
    );
  }
}
