import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/mongo_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state_view.dart';

class StudentFeesScreen extends StatelessWidget {
  const StudentFeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final student = AuthService().currentStudent;
    final mongo = MongoService();
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final studentId = student?.id ?? 'STU1001';

    final totalFee = student?.feeAmount ?? 35000.0;
    final totalPaid = mongo.getTotalPaidForStudent(studentId);
    final due = mongo.getDueAmountForStudent(studentId);
    final status = mongo.getPaymentStatusForStudent(studentId);
    final payments = mongo.getPaymentsForStudent(studentId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Hostel Fees'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dues Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Fee Status Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        StatusBadge(status: status),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _feeColumn('Total Fee', currency.format(totalFee), Colors.grey.shade800),
                        _feeColumn('Paid', currency.format(totalPaid), AppTheme.statusSuccess),
                        _feeColumn('Remaining Due', currency.format(due), due > 0 ? AppTheme.statusDanger : Colors.grey.shade700),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: totalFee > 0 ? (totalPaid / totalFee).clamp(0.0, 1.0) : 0,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.statusSuccess),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Payment Receipts History
            const Text(
              'Payment History & Receipts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
            ),
            const SizedBox(height: 8),

            if (payments.isEmpty)
              const EmptyStateView(
                icon: Icons.receipt_long_outlined,
                title: 'No Payments Recorded',
                message: 'No fee receipts have been issued to your account yet.',
              )
            else
              ...payments.map((p) => Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade50,
                    child: const Icon(Icons.receipt_rounded, color: AppTheme.statusSuccess),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(currency.format(p.amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(p.paymentDate, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Receipt No: ${p.receiptNo}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                      Text('Method: ${p.paymentMethod} • ${p.remarks ?? ""}', style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5)),
                    ],
                  ),
                  trailing: const Icon(Icons.check_circle_rounded, color: AppTheme.statusSuccess, size: 20),
                ),
              )),

            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: AppTheme.primaryBlue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'For fee payment verification or receipts, please visit the hostel accounts counter.',
                      style: TextStyle(fontSize: 11.5, color: AppTheme.primaryBlue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feeColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
      ],
    );
  }
}
