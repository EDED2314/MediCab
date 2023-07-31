class User {
  String name;
  String age;
  String gender;
  String pfp;

  User({
    required this.name,
    required this.age,
    required this.gender,
    required this.pfp,
  });

  // Create a User object from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      age: json['age'] as String,
      gender: json['gender'] as String,
      pfp: json['pfp'] as String,
    );
  }

  // Convert the User object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'pfp': pfp,
    };
  }
}
