// // GENERATED CODE - DO NOT MODIFY BY HAND

// part of 'user_model.dart';

// // **************************************************************************
// // TypeAdapterGenerator
// // **************************************************************************

// class UserModelAdapter extends TypeAdapter<UserModel> {
//   @override
//   final int typeId = 0;

//   @override
//   UserModel read(BinaryReader reader) {
//     final numOfFields = reader.readByte();
//     final fields = <int, dynamic>{
//       for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
//     };
//     return UserModel(
//       username: fields[0] as String,
//       email: fields[1] as String,
//       password: fields[2] as String,
//       gender: fields[3] as String,
//       age: fields[4] as int,
//       timezone: fields[5] as String,
//       country: fields[6] as String,
//     );
//   }

//   @override
//   void write(BinaryWriter writer, UserModel obj) {
//     writer
//       ..writeByte(7)
//       ..writeByte(0)
//       ..write(obj.username)
//       ..writeByte(1)
//       ..write(obj.email)
//       ..writeByte(2)
//       ..write(obj.password)
//       ..writeByte(3)
//       ..write(obj.gender)
//       ..writeByte(4)
//       ..write(obj.age)
//       ..writeByte(5)
//       ..write(obj.timezone)
//       ..writeByte(6)
//       ..write(obj.country);
//   }

//   @override
//   int get hashCode => typeId.hashCode;

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is UserModelAdapter &&
//           runtimeType == other.runtimeType &&
//           typeId == other.typeId;
// }
