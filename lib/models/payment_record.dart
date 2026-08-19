class PaymentRecord {
  final String id;
  final String subscriptionId;
  final String subscriptionName; // stored redundantly so history survives even if the subscription is later deleted
  final double amount;
  final DateTime paidOn;

  PaymentRecord({
    required this.id,
    required this.subscriptionId,
    required this.subscriptionName,
    required this.amount,
    required this.paidOn,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subscriptionId': subscriptionId,
      'subscriptionName': subscriptionName,
      'amount': amount,
      'paidOn': paidOn.toIso8601String(),
    };
  }

  factory PaymentRecord.fromMap(Map<String, dynamic> map) {
    return PaymentRecord(
      id: map['id'] as String,
      subscriptionId: map['subscriptionId'] as String,
      subscriptionName: map['subscriptionName'] as String,
      amount: (map['amount'] as num).toDouble(),
      paidOn: DateTime.parse(map['paidOn'] as String),
    );
  }
}