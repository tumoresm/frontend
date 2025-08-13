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
    return IndustryModel(
      id: map['\$id'] as String? ?? '',
      name: map['name'] as String? ?? '',
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
