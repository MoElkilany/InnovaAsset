// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AssetModelAdapter extends TypeAdapter<AssetModel> {
  @override
  final int typeId = 0;

  @override
  AssetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AssetModel(
      id: fields[0] as String,
      descriptionId: fields[1] as String,
      code: fields[2] as String,
      categoryId: fields[3] as String,
      locationId: fields[4] as String,
      status: fields[5] as String,
      details: fields[6] as String,
      imagePath: fields[7] as String,
      createdAt: fields[8] as DateTime,
      isSynced: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AssetModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.descriptionId)
      ..writeByte(2)
      ..write(obj.code)
      ..writeByte(3)
      ..write(obj.categoryId)
      ..writeByte(4)
      ..write(obj.locationId)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.details)
      ..writeByte(7)
      ..write(obj.imagePath)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
