// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_description_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AssetDescriptionModelAdapter extends TypeAdapter<AssetDescriptionModel> {
  @override
  final int typeId = 3;

  @override
  AssetDescriptionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AssetDescriptionModel(
      id: fields[0] as String,
      label: fields[1] as String,
      isLocal: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AssetDescriptionModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.isLocal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetDescriptionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
