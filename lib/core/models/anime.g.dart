// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anime.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnimeAdapter extends TypeAdapter<Anime> {
  @override
  final int typeId = 0;

  @override
  Anime read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Anime(
      malId: fields[0] as int,
      title: fields[1] as String,
      titleEnglish: fields[2] as String?,
      titleJapanese: fields[3] as String?,
      synopsis: fields[4] as String?,
      images: fields[5] as AnimeImages,
      episodes: fields[6] as int?,
      duration: fields[7] as String?,
      rating: fields[8] as String?,
      score: fields[9] as double?,
      scoredBy: fields[10] as int?,
      rank: fields[11] as int?,
      popularity: fields[12] as int?,
      genres: (fields[13] as List).cast<Genre>(),
      studios: (fields[14] as List).cast<Studio>(),
      source: fields[15] as String?,
      status: fields[16] as String?,
      aired: fields[17] as String?,
      season: fields[18] as String?,
      year: fields[19] as int?,
      type: fields[20] as String?,
      lastUpdated: fields[21] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Anime obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.malId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.titleEnglish)
      ..writeByte(3)
      ..write(obj.titleJapanese)
      ..writeByte(4)
      ..write(obj.synopsis)
      ..writeByte(5)
      ..write(obj.images)
      ..writeByte(6)
      ..write(obj.episodes)
      ..writeByte(7)
      ..write(obj.duration)
      ..writeByte(8)
      ..write(obj.rating)
      ..writeByte(9)
      ..write(obj.score)
      ..writeByte(10)
      ..write(obj.scoredBy)
      ..writeByte(11)
      ..write(obj.rank)
      ..writeByte(12)
      ..write(obj.popularity)
      ..writeByte(13)
      ..write(obj.genres)
      ..writeByte(14)
      ..write(obj.studios)
      ..writeByte(15)
      ..write(obj.source)
      ..writeByte(16)
      ..write(obj.status)
      ..writeByte(17)
      ..write(obj.aired)
      ..writeByte(18)
      ..write(obj.season)
      ..writeByte(19)
      ..write(obj.year)
      ..writeByte(20)
      ..write(obj.type)
      ..writeByte(21)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AnimeImagesAdapter extends TypeAdapter<AnimeImages> {
  @override
  final int typeId = 1;

  @override
  AnimeImages read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnimeImages(
      jpg: fields[0] as ImageSet,
      webp: fields[1] as ImageSet,
    );
  }

  @override
  void write(BinaryWriter writer, AnimeImages obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.jpg)
      ..writeByte(1)
      ..write(obj.webp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimeImagesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ImageSetAdapter extends TypeAdapter<ImageSet> {
  @override
  final int typeId = 2;

  @override
  ImageSet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ImageSet(
      imageUrl: fields[0] as String?,
      smallImageUrl: fields[1] as String?,
      largeImageUrl: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ImageSet obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.imageUrl)
      ..writeByte(1)
      ..write(obj.smallImageUrl)
      ..writeByte(2)
      ..write(obj.largeImageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageSetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GenreAdapter extends TypeAdapter<Genre> {
  @override
  final int typeId = 3;

  @override
  Genre read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Genre(
      malId: fields[0] as int,
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Genre obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.malId)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StudioAdapter extends TypeAdapter<Studio> {
  @override
  final int typeId = 4;

  @override
  Studio read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Studio(
      malId: fields[0] as int,
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Studio obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.malId)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
