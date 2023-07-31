class Medicine {
  String name;
  String shortDescription;
  String longDescription;
  String location;
  String expirationTime;
  String dosagePerDay;
  String type;

  Medicine({
    required this.name,
    required this.shortDescription,
    required this.longDescription,
    required this.location,
    required this.expirationTime,
    required this.dosagePerDay,
    required this.type,
  });

  // Create a Medicine object from a JSON map
  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json['name'] as String,
      shortDescription: json['short_description'] as String,
      longDescription: json['long_description'] as String,
      location: json['location'] as String,
      expirationTime: json['expiration_time'] as String,
      dosagePerDay: json['dosage_per_day'] as String,
      type: json['type'] as String,
    );
  }

  // Convert the Medicine object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'short_description': shortDescription,
      'long_description': longDescription,
      'location': location,
      'expiration_time': expirationTime,
      'dosage_per_day': dosagePerDay,
      'type': type,
    };
  }
}
