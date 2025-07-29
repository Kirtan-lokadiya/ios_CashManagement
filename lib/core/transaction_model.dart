import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String type; // income or expense
  @HiveField(2)
  double amount;
  @HiveField(3)
  String? recipient;
  @HiveField(4)
  String? source;
  @HiveField(5)
  String description;
  @HiveField(6)
  DateTime date;
  @HiveField(7)
  String category;
  @HiveField(8)
  String? phone;
  @HiveField(9)
  String firmId; // New field for firm association

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    this.recipient,
    this.source,
    required this.description,
    required this.date,
    required this.category,
    this.phone,
    required this.firmId,
  });
} 