// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SelectedProductAdapter extends TypeAdapter<SelectedProduct> {
  @override
  final int typeId = 1;

  @override
  SelectedProduct read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SelectedProduct(
      product: fields[0] as Product,
      unitPrice: fields[1] as double,
      quantity: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SelectedProduct obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.product)
      ..writeByte(1)
      ..write(obj.unitPrice)
      ..writeByte(2)
      ..write(obj.quantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectedProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
