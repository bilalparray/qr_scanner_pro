// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'code_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CodeEntryAdapter extends TypeAdapter<CodeEntry> {
  @override
  final int typeId = 0;

  @override
  CodeEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CodeEntry(
      content: fields[0] as String,
      type: fields[1] as String,
      timestamp: fields[2] as DateTime,
      format: fields[3] as String?,
      isFavorite: fields[4] as bool,
      title: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CodeEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.content)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.format)
      ..writeByte(4)
      ..write(obj.isFavorite)
      ..writeByte(5)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
