import 'package:hive/hive.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: 4)
class Reminder extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String description;
  @HiveField(2)
  DateTime? reminderDate;
  @HiveField(3)
  DateTime createdAt;
  @HiveField(4)
  bool isCompleted;

  Reminder({
    required this.id,
    required this.description,
    this.reminderDate,
    required this.createdAt,
    this.isCompleted = false,
  });
}