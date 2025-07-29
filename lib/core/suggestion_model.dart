import 'package:hive/hive.dart';

part 'suggestion_model.g.dart';

@HiveType(typeId: 2)
class Suggestion extends HiveObject {
  @HiveField(0)
  String value;
  @HiveField(1)
  String type; // e.g., 'category', 'source', 'purpose'

  Suggestion({
    required this.value,
    required this.type,
  });
} 