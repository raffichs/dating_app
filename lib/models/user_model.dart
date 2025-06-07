class UserModel {
  final String? id;
  final String username;
  final String email;
  final String password;
  final String gender;
  final int age;
  final String timezone;
  final String country;
  final String coverImageUrl;
  final String currency;
  final String bio;
  final List<String>? likedBy;
  final double lat;
  final double lng;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.gender,
    required this.age,
    required this.timezone,
    required this.country,
    required this.coverImageUrl,
    required this.currency,
    required this.bio,
    this.likedBy,
    required this.lat,
    required this.lng,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      password: json['password'],
      gender: json['gender'],
      age: int.parse(json['age'].toString()),
      timezone: json['timezone'],
      country: json['country'],
      coverImageUrl: json['coverImageUrl'],
      currency: json['currency'],
      bio: json['bio'],
      likedBy:
          json['likedBy'] != null ? List<String>.from(json['likedBy']) : [],
      lat: (json['lat'] != null) ? json['lat'].toDouble() : null,
      lng: (json['lng'] != null) ? json['lng'].toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "email": email,
      "password": password,
      "gender": gender,
      "age": age,
      "timezone": timezone,
      "country": country,
      "coverImageUrl": coverImageUrl,
      "currency": currency,
      "bio": bio,
      'likedBy': likedBy ?? [],
      'lat': lat,
      'lng': lng,
    };
  }

  factory UserModel.empty() {
    return UserModel(
      id: null,
      username: '',
      email: '',
      password: '',
      gender: '',
      age: 0,
      timezone: '',
      country: '',
      coverImageUrl: '',
      currency: '',
      bio: '',
      likedBy: [],
      lat: 0.0,
      lng: 0.0,
    );
  }
}
