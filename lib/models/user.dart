import 'package:bettingapp/models/location.dart';

class User {
  final int? id;
  final String? name;
  final String? username;
  final String? email;
  final String? role; // "teller", "coordinator", etc.
  final String? profilePhotoUrl;
  final Location? location;
  
  User({
    this.id,
    this.name,
    this.username,
    this.email,
    this.role,
    this.profilePhotoUrl,
    this.location,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      profilePhotoUrl: json['profile_photo_url'],
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
    );
  }
  
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      username: map['username'],
      email: map['email'],
      role: map['role'],
      profilePhotoUrl: map['profile_photo_url'],
      location: map['location'] != null ? Location.fromMap(map['location']) : null,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'role': role,
      'profile_photo_url': profilePhotoUrl,
      'location': location?.toMap(),
    };
  }
  
  User copyWith({
    int? id,
    String? name,
    String? username,
    String? email,
    String? role,
    String? profilePhotoUrl,
    Location? location,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      location: location ?? this.location,
    );
  }
  
  @override
  String toString() {
    return 'User(id: $id, name: $name, username: $username, email: $email, role: $role)';
  }
}
