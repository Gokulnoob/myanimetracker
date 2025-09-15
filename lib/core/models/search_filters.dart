import 'package:hive/hive.dart';

part 'search_filters.g.dart';

@HiveType(typeId: 7)
enum AnimeType {
  @HiveField(0)
  tv,

  @HiveField(1)
  movie,

  @HiveField(2)
  ova,

  @HiveField(3)
  special,

  @HiveField(4)
  ona,

  @HiveField(5)
  music,
}

@HiveType(typeId: 8)
enum AnimeStatus {
  @HiveField(0)
  airing,

  @HiveField(1)
  complete,

  @HiveField(2)
  upcoming,
}

@HiveType(typeId: 9)
enum SortBy {
  @HiveField(0)
  title,

  @HiveField(1)
  score,

  @HiveField(2)
  popularity,

  @HiveField(3)
  members,

  @HiveField(4)
  episodes,

  @HiveField(5)
  startDate,

  @HiveField(6)
  endDate,
}

@HiveType(typeId: 10)
enum SortOrder {
  @HiveField(0)
  asc,

  @HiveField(1)
  desc,
}

@HiveType(typeId: 11)
class SearchFilters {
  @HiveField(0)
  String? query;

  @HiveField(1)
  AnimeType? type;

  @HiveField(2)
  AnimeStatus? status;

  @HiveField(3)
  double? minScore;

  @HiveField(4)
  double? maxScore;

  @HiveField(5)
  List<int> genreIds;

  @HiveField(6)
  SortBy sortBy;

  @HiveField(7)
  SortOrder sortOrder;

  @HiveField(8)
  int? startYear;

  @HiveField(9)
  int? endYear;

  @HiveField(10)
  bool sfw;

  SearchFilters({
    this.query,
    this.type,
    this.status,
    this.minScore,
    this.maxScore,
    this.genreIds = const [],
    this.sortBy = SortBy.score,
    this.sortOrder = SortOrder.desc,
    this.startYear,
    this.endYear,
    this.sfw = true,
  });

  factory SearchFilters.empty() {
    return SearchFilters();
  }

  SearchFilters copyWith({
    String? query,
    AnimeType? type,
    AnimeStatus? status,
    double? minScore,
    double? maxScore,
    List<int>? genreIds,
    SortBy? sortBy,
    SortOrder? sortOrder,
    int? startYear,
    int? endYear,
    bool? sfw,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      type: type ?? this.type,
      status: status ?? this.status,
      minScore: minScore ?? this.minScore,
      maxScore: maxScore ?? this.maxScore,
      genreIds: genreIds ?? this.genreIds,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
      sfw: sfw ?? this.sfw,
    );
  }

  void clear() {
    query = null;
    type = null;
    status = null;
    minScore = null;
    maxScore = null;
    genreIds = [];
    sortBy = SortBy.score;
    sortOrder = SortOrder.desc;
    startYear = null;
    endYear = null;
    sfw = true;
  }

  bool get hasActiveFilters {
    return query?.isNotEmpty == true ||
        type != null ||
        status != null ||
        minScore != null ||
        maxScore != null ||
        genreIds.isNotEmpty ||
        startYear != null ||
        endYear != null;
  }

  Map<String, String> toQueryParameters() {
    final params = <String, String>{};

    if (query?.isNotEmpty == true) params['q'] = query!;
    if (type != null) params['type'] = type!.name;
    if (status != null) params['status'] = status!.name;
    if (minScore != null) params['min_score'] = minScore.toString();
    if (maxScore != null) params['max_score'] = maxScore.toString();
    if (genreIds.isNotEmpty) params['genres'] = genreIds.join(',');
    if (startYear != null) params['start_date'] = '$startYear-01-01';
    if (endYear != null) params['end_date'] = '$endYear-12-31';

    params['order_by'] = sortBy.name;
    params['sort'] = sortOrder.name;
    params['sfw'] = sfw.toString();

    return params;
  }

  @override
  String toString() {
    final filters = <String>[];

    if (query?.isNotEmpty == true) filters.add('Query: "$query"');
    if (type != null) filters.add('Type: ${type!.name}');
    if (status != null) filters.add('Status: ${status!.name}');
    if (minScore != null || maxScore != null) {
      filters.add('Score: ${minScore ?? 0} - ${maxScore ?? 10}');
    }
    if (genreIds.isNotEmpty) filters.add('Genres: ${genreIds.length} selected');
    if (startYear != null || endYear != null) {
      filters.add('Year: ${startYear ?? 'Any'} - ${endYear ?? 'Any'}');
    }

    return filters.isEmpty ? 'No filters applied' : filters.join(', ');
  }
}

extension AnimeTypeExtension on AnimeType {
  String get displayName {
    switch (this) {
      case AnimeType.tv:
        return 'TV Series';
      case AnimeType.movie:
        return 'Movie';
      case AnimeType.ova:
        return 'OVA';
      case AnimeType.special:
        return 'Special';
      case AnimeType.ona:
        return 'ONA';
      case AnimeType.music:
        return 'Music';
    }
  }
}

extension AnimeStatusExtension on AnimeStatus {
  String get displayName {
    switch (this) {
      case AnimeStatus.airing:
        return 'Currently Airing';
      case AnimeStatus.complete:
        return 'Completed';
      case AnimeStatus.upcoming:
        return 'Upcoming';
    }
  }
}

extension SortByExtension on SortBy {
  String get displayName {
    switch (this) {
      case SortBy.title:
        return 'Title';
      case SortBy.score:
        return 'Score';
      case SortBy.popularity:
        return 'Popularity';
      case SortBy.members:
        return 'Members';
      case SortBy.episodes:
        return 'Episodes';
      case SortBy.startDate:
        return 'Start Date';
      case SortBy.endDate:
        return 'End Date';
    }
  }
}
