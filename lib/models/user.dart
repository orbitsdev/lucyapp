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
  
  factory User.fromJson(Map json) {
    // Handle case where data is nested inside 'data' field
    final userData = json.containsKey('data') ? json['data'] : json;
    
    return User(
      id: userData['id'],
      name: userData['name']?.toString(),
      username: userData['username']?.toString(),
      email: userData['email']?.toString(),
      role: userData['role']?.toString(),
      profilePhotoUrl: userData['profile_photo_url']?.toString(),
      location: userData['location'] != null ? Location.fromJson(userData['location'] as Map) : null,
    );
  }
  
  factory User.fromMap(Map map) {
    return User(
      id: map['id'],
      name: map['name']?.toString(),
      username: map['username']?.toString(),
      email: map['email']?.toString(),
      role: map['role']?.toString(),
      profilePhotoUrl: map['profile_photo_url']?.toString(),
      location: map['location'] != null ? Location.fromMap(map['location'] as Map) : null,
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
