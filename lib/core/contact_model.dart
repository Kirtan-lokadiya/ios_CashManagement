import 'package:hive/hive.dart';

part 'contact_model.g.dart';

@HiveType(typeId: 1)
class Contact extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  String phone;
  @HiveField(2)
  String? avatar;

  Contact({
    required this.name,
    required this.phone,
    this.avatar,
  });
} 