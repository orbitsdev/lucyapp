class Location {
  final int? id;
  final String? name;
  final String? address;
  
  Location({
    this.id,
    this.name,
    this.address,
  });
  
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      address: json['address'],
    );
  }
  
  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'],
      name: map['name'],
      address: map['address'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
    };
  }
  
  Location copyWith({
    int? id,
    String? name,
    String? address,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
    );
  }
  
  @override
  String toString() {
    return 'Location(id: $id, name: $name, address: $address)';
  }
}
