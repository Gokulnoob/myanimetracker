// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_anime_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAnimeEntryAdapter extends TypeAdapter<UserAnimeEntry> {
  @override
  final int typeId = 6;

  @override
  UserAnimeEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserAnimeEntry(
      animeId: fields[0] as int,
      status: fields[1] as WatchStatus,
      episodesWatched: fields[2] as int,
      personalScore: fields[3] as double?,
      personalNotes: fields[4] as String?,
      dateAdded: fields[5] as DateTime,
      dateCompleted: fields[6] as DateTime?,
      dateStarted: fields[7] as DateTime?,
      lastModified: fields[8] as DateTime,
      isFavorite: fields[9] as bool,
      totalEpisodes: fields[10] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, UserAnimeEntry obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.animeId)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.episodesWatched)
      ..writeByte(3)
      ..write(obj.personalScore)
      ..writeByte(4)
      ..write(obj.personalNotes)
      ..writeByte(5)
      ..write(obj.dateAdded)
      ..writeByte(6)
      ..write(obj.dateCompleted)
      ..writeByte(7)
      ..write(obj.dateStarted)
      ..writeByte(8)
      ..write(obj.lastModified)
      ..writeByte(9)
      ..write(obj.isFavorite)
      ..writeByte(10)
      ..write(obj.totalEpisodes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAnimeEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WatchStatusAdapter extends TypeAdapter<WatchStatus> {
  @override
  final int typeId = 5;

  @override
  WatchStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WatchStatus.watching;
      case 1:
        return WatchStatus.completed;
      case 2:
        return WatchStatus.planToWatch;
      case 3:
        return WatchStatus.onHold;
      case 4:
        return WatchStatus.dropped;
      default:
        return WatchStatus.watching;
    }
  }

  @override
  void write(BinaryWriter writer, WatchStatus obj) {
    switch (obj) {
      case WatchStatus.watching:
        writer.writeByte(0);
        break;
      case WatchStatus.completed:
        writer.writeByte(1);
        break;
      case WatchStatus.planToWatch:
        writer.writeByte(2);
        break;
      case WatchStatus.onHold:
        writer.writeByte(3);
        break;
      case WatchStatus.dropped:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
