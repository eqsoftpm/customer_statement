// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerAdapter extends TypeAdapter<Customer> {
  @override
  final int typeId = 0;

  @override
  Customer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Customer(
      fields[0] as int,
      fields[1] as int,
      fields[2] as int,
      fields[3] as String?,
      fields[4] as String?,
      fields[5] as String?,
      fields[6] as String?,
      fields[7] as String?,
      fields[8] as double?,
      fields[9] as String?,
      fields[10] as String?,
      fields[11] as double?,
      fields[12] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Customer obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.companyId)
      ..writeByte(2)
      ..write(obj.refId)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.address)
      ..writeByte(5)
      ..write(obj.phoneNo)
      ..writeByte(6)
      ..write(obj.gstin)
      ..writeByte(7)
      ..write(obj.email)
      ..writeByte(8)
      ..write(obj.balance)
      ..writeByte(9)
      ..write(obj.place)
      ..writeByte(10)
      ..write(obj.pincode)
      ..writeByte(11)
      ..write(obj.latitude)
      ..writeByte(12)
      ..write(obj.longitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
