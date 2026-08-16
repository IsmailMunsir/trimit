class User {
  final String id;
  final String name;
  final String email;
  final String passwordHash; // never store the real password, only its hash
  final bool emailVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    this.emailVerified = false,
  });

  User copyWith({
    String? name,
    String? email,
    String? passwordHash,
    bool? emailVerified,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'passwordHash': passwordHash,
      'emailVerified': emailVerified ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      passwordHash: map['passwordHash'] as String,
      emailVerified: (map['emailVerified'] as int) == 1,
    );
  }
}