class Wallet {
  final String id;
  final String name;
  final int colorValue;

  Wallet({
    required this.id,
    required this.name,
    this.colorValue = 0xFF3D5AFE,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
    };
  }

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      id: map['id'] as String,
      name: map['name'] as String,
      colorValue: map['colorValue'] as int? ?? 0xFF3D5AFE,
    );
  }
}