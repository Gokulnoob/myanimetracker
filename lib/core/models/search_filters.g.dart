// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_filters.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SearchFiltersAdapter extends TypeAdapter<SearchFilters> {
  @override
  final int typeId = 11;

  @override
  SearchFilters read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SearchFilters(
      query: fields[0] as String?,
      type: fields[1] as AnimeType?,
      status: fields[2] as AnimeStatus?,
      minScore: fields[3] as double?,
      maxScore: fields[4] as double?,
      genreIds: (fields[5] as List).cast<int>(),
      sortBy: fields[6] as SortBy,
      sortOrder: fields[7] as SortOrder,
      startYear: fields[8] as int?,
      endYear: fields[9] as int?,
      sfw: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SearchFilters obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.query)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.minScore)
      ..writeByte(4)
      ..write(obj.maxScore)
      ..writeByte(5)
      ..write(obj.genreIds)
      ..writeByte(6)
      ..write(obj.sortBy)
      ..writeByte(7)
      ..write(obj.sortOrder)
      ..writeByte(8)
      ..write(obj.startYear)
      ..writeByte(9)
      ..write(obj.endYear)
      ..writeByte(10)
      ..write(obj.sfw);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchFiltersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AnimeTypeAdapter extends TypeAdapter<AnimeType> {
  @override
  final int typeId = 7;

  @override
  AnimeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AnimeType.tv;
      case 1:
        return AnimeType.movie;
      case 2:
        return AnimeType.ova;
      case 3:
        return AnimeType.special;
      case 4:
        return AnimeType.ona;
      case 5:
        return AnimeType.music;
      default:
        return AnimeType.tv;
    }
  }

  @override
  void write(BinaryWriter writer, AnimeType obj) {
    switch (obj) {
      case AnimeType.tv:
        writer.writeByte(0);
        break;
      case AnimeType.movie:
        writer.writeByte(1);
        break;
      case AnimeType.ova:
        writer.writeByte(2);
        break;
      case AnimeType.special:
        writer.writeByte(3);
        break;
      case AnimeType.ona:
        writer.writeByte(4);
        break;
      case AnimeType.music:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AnimeStatusAdapter extends TypeAdapter<AnimeStatus> {
  @override
  final int typeId = 8;

  @override
  AnimeStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AnimeStatus.airing;
      case 1:
        return AnimeStatus.complete;
      case 2:
        return AnimeStatus.upcoming;
      default:
        return AnimeStatus.airing;
    }
  }

  @override
  void write(BinaryWriter writer, AnimeStatus obj) {
    switch (obj) {
      case AnimeStatus.airing:
        writer.writeByte(0);
        break;
      case AnimeStatus.complete:
        writer.writeByte(1);
        break;
      case AnimeStatus.upcoming:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimeStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SortByAdapter extends TypeAdapter<SortBy> {
  @override
  final int typeId = 9;

  @override
  SortBy read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SortBy.title;
      case 1:
        return SortBy.score;
      case 2:
        return SortBy.popularity;
      case 3:
        return SortBy.members;
      case 4:
        return SortBy.episodes;
      case 5:
        return SortBy.startDate;
      case 6:
        return SortBy.endDate;
      default:
        return SortBy.title;
    }
  }

  @override
  void write(BinaryWriter writer, SortBy obj) {
    switch (obj) {
      case SortBy.title:
        writer.writeByte(0);
        break;
      case SortBy.score:
        writer.writeByte(1);
        break;
      case SortBy.popularity:
        writer.writeByte(2);
        break;
      case SortBy.members:
        writer.writeByte(3);
        break;
      case SortBy.episodes:
        writer.writeByte(4);
        break;
      case SortBy.startDate:
        writer.writeByte(5);
        break;
      case SortBy.endDate:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SortByAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SortOrderAdapter extends TypeAdapter<SortOrder> {
  @override
  final int typeId = 10;

  @override
  SortOrder read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SortOrder.asc;
      case 1:
        return SortOrder.desc;
      default:
        return SortOrder.asc;
    }
  }

  @override
  void write(BinaryWriter writer, SortOrder obj) {
    switch (obj) {
      case SortOrder.asc:
        writer.writeByte(0);
        break;
      case SortOrder.desc:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SortOrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
