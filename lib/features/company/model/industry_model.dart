import 'package:flutter/foundation.dart';

@immutable
class IndustryModel {
  final String id;
  final String name;

  const IndustryModel({
    required this.id,
    required this.name,
  });

  IndustryModel copyWith({
    String? id,
    String? name,
  }) =>
      IndustryModel(
        id: id ?? this.id,
        name: name ?? this.name,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'name': name,
      };

  factory IndustryModel.fromMap(Map<String, dynamic> map) {
    // Handle different ID field formats
    String id = '';
    if (map.containsKey('\$id') && map['\$id'] != null) {
      id = map['\$id'].toString();
    } else if (map.containsKey('id') && map['id'] != null) {
      id = map['id'].toString();
    } else if (map.containsKey('_id') && map['_id'] != null) {
      id = map['_id'].toString();
    }
    
    // Handle different name field formats
    String name = '';
    if (map.containsKey('name') && map['name'] != null) {
      name = map['name'].toString();
    } else if (map.containsKey('title') && map['title'] != null) {
      name = map['title'].toString();
    } else if (map.containsKey('industry_name') && map['industry_name'] != null) {
      name = map['industry_name'].toString();
    }
    
    return IndustryModel(
      id: id,
      name: name,
    );
  }

  @override
  String toString() => 'IndustryModel(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is IndustryModel &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
