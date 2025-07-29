// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firm_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FirmAdapter extends TypeAdapter<Firm> {
  @override
  final int typeId = 3;

  @override
  Firm read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Firm(
      id: fields[0] as String,
      name: fields[1] as String,
      createdAt: fields[2] as DateTime,
      description: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Firm obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FirmAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
