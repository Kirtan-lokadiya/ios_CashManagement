import 'package:hive/hive.dart';

part 'firm_model.g.dart';

@HiveType(typeId: 3)
class Firm extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  DateTime createdAt;
  @HiveField(3)
  String? description;

  Firm({
    required this.id,
    required this.name,
    required this.createdAt,
    this.description,
  });
} 