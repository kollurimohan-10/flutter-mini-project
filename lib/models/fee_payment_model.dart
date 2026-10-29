class FeePaymentModel {
  final String id;
  final String studentId;
  final String studentName;
  final double amount;
  final String paymentDate;
  final String paymentMethod;
  final String receiptNo;
  final String? remarks;

  FeePaymentModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    required this.receiptNo,
    this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'payment_id': id,
      'student_id': studentId,
      'student_name': studentName,
      'amount': amount,
      'payment_date': paymentDate,
      'payment_method': paymentMethod,
      'receipt_no': receiptNo,
      'remarks': remarks,
    };
  }

  factory FeePaymentModel.fromMap(Map<String, dynamic> map) {
    return FeePaymentModel(
      id: map['payment_id']?.toString() ?? map['_id']?.toString() ?? map['id']?.toString() ?? '',
      studentId: map['student_id'] ?? map['studentId'] ?? '',
      studentName: map['student_name'] ?? map['studentName'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: map['payment_date'] ?? map['paymentDate'] ?? '',
      paymentMethod: map['payment_method'] ?? map['paymentMethod'] ?? 'UPI',
      receiptNo: map['receipt_no'] ?? map['receiptNo'] ?? '',
      remarks: map['remarks'],
    );
  }
}
