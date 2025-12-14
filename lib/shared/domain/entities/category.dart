import 'package:equatable/equatable.dart';

/// Category entity
class Category extends Equatable {
  final String id;
  final String name;
  final String? slug;
  final String? icon;
  final bool isActive;
  final DateTime? createdAt;

  const Category({
    required this.id,
    required this.name,
    this.slug,
    this.icon,
    this.isActive = true,
    this.createdAt,
  });

  Category copyWith({
    String? id,
    String? name,
    String? slug,
    String? icon,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, slug, icon, isActive, createdAt];
}
