class User {
  final String id;
  final String email;
  final String password;
  final String name;
  final String phone;

  const User({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        email: json['email'] as String,
        password: json['password'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
      );
}
