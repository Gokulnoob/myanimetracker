import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/models.dart';

class JikanApiService {
  static const String _baseUrl = 'https://api.jikan.moe/v4';
  static const Duration _requestDelay =
      Duration(milliseconds: 1000); // Respect rate limit

  final Dio _dio;
  final Logger _logger = Logger();
  DateTime? _lastRequestTime;

  JikanApiService() : _dio = Dio() {
    _setupDio();
  }

  void _setupDio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d('API Request: ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d(
              'API Response: ${response.statusCode} ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('API Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  Future<void> _enforceRateLimit() async {
    if (_lastRequestTime != null) {
      final elapsed = DateTime.now().difference(_lastRequestTime!);
      if (elapsed < _requestDelay) {
        final waitTime = _requestDelay - elapsed;
        await Future.delayed(waitTime);
      }
    }
    _lastRequestTime = DateTime.now();
  }

  Future<ApiResponse<List<Anime>>> getTopAnime({
    int page = 1,
    int limit = 25,
    String? type,
    String? filter,
  }) async {
    try {
      await _enforceRateLimit();

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (type != null) queryParams['type'] = type;
      if (filter != null) queryParams['filter'] = filter;

      final response =
          await _dio.get('/top/anime', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final data = response.data;
        final animeList =
            (data['data'] as List).map((json) => Anime.fromJson(json)).toList();

        return ApiResponse.success(
          data: animeList,
          pagination: PaginationInfo.fromJson(data['pagination']),
        );
      } else {
        return ApiResponse.error(
            'Failed to fetch top anime: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<List<Anime>>> getSeasonalAnime({
    int? year,
    String? season,
    int page = 1,
    int limit = 25,
  }) async {
    try {
      await _enforceRateLimit();

      final currentDate = DateTime.now();
      final targetYear = year ?? currentDate.year;
      final targetSeason = season ?? _getCurrentSeason();

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      final response = await _dio.get(
        '/seasons/$targetYear/$targetSeason',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final animeList =
            (data['data'] as List).map((json) => Anime.fromJson(json)).toList();

        return ApiResponse.success(
          data: animeList,
          pagination: PaginationInfo.fromJson(data['pagination']),
        );
      } else {
        return ApiResponse.error(
            'Failed to fetch seasonal anime: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<List<Anime>>> searchAnime({
    required SearchFilters filters,
    int page = 1,
    int limit = 25,
  }) async {
    try {
      await _enforceRateLimit();

      final queryParams = filters.toQueryParameters();
      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();

      final response = await _dio.get('/anime', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final data = response.data;
        final animeList =
            (data['data'] as List).map((json) => Anime.fromJson(json)).toList();

        return ApiResponse.success(
          data: animeList,
          pagination: PaginationInfo.fromJson(data['pagination']),
        );
      } else {
        return ApiResponse.error(
            'Failed to search anime: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<Anime>> getAnimeById(int id) async {
    try {
      await _enforceRateLimit();

      final response = await _dio.get('/anime/$id');

      if (response.statusCode == 200) {
        final anime = Anime.fromJson(response.data['data']);
        return ApiResponse.success(data: anime);
      } else {
        return ApiResponse.error(
            'Failed to fetch anime details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<List<Anime>>> getAnimeRecommendations(int id) async {
    try {
      await _enforceRateLimit();

      final response = await _dio.get('/anime/$id/recommendations');

      if (response.statusCode == 200) {
        final data = response.data;
        final recommendations = (data['data'] as List)
            .map((json) => Anime.fromJson(json['entry']))
            .toList();

        return ApiResponse.success(data: recommendations);
      } else {
        return ApiResponse.error(
            'Failed to fetch recommendations: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<List<Genre>>> getGenres() async {
    try {
      await _enforceRateLimit();

      final response = await _dio.get('/genres/anime');

      if (response.statusCode == 200) {
        final genres = (response.data['data'] as List)
            .map((json) => Genre.fromJson(json))
            .toList();

        return ApiResponse.success(data: genres);
      } else {
        return ApiResponse.error(
            'Failed to fetch genres: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  String _getCurrentSeason() {
    final month = DateTime.now().month;
    if (month >= 1 && month <= 3) return 'winter';
    if (month >= 4 && month <= 6) return 'spring';
    if (month >= 7 && month <= 9) return 'summer';
    return 'fall';
  }

  ApiResponse<T> _handleDioError<T>(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiResponse.error(
            'Connection timeout. Please check your internet connection.');

      case DioExceptionType.connectionError:
        return ApiResponse.error(
            'No internet connection. Please check your network settings.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 404:
            return ApiResponse.error('The requested anime was not found.');
          case 429:
            return ApiResponse.error(
                'Too many requests. Please try again later.');
          case 500:
          case 502:
          case 503:
            return ApiResponse.error(
                'Server is temporarily unavailable. Please try again later.');
          default:
            return ApiResponse.error(
                'Server error (${statusCode ?? 'Unknown'}). Please try again.');
        }

      case DioExceptionType.cancel:
        return ApiResponse.error('Request was cancelled.');

      case DioExceptionType.unknown:
      default:
        return ApiResponse.error(
            'An unexpected error occurred. Please try again.');
    }
  }

  void dispose() {
    _dio.close();
  }
}

class ApiResponse<T> {
  final T? data;
  final String? error;
  final PaginationInfo? pagination;
  final bool isSuccess;

  ApiResponse._({
    this.data,
    this.error,
    this.pagination,
    required this.isSuccess,
  });

  factory ApiResponse.success({
    required T data,
    PaginationInfo? pagination,
  }) {
    return ApiResponse._(
      data: data,
      pagination: pagination,
      isSuccess: true,
    );
  }

  factory ApiResponse.error(String error) {
    return ApiResponse._(
      error: error,
      isSuccess: false,
    );
  }
}

class PaginationInfo {
  final int currentPage;
  final int lastVisiblePage;
  final bool hasNextPage;
  final int itemsPerPage;
  final int itemsTotal;

  PaginationInfo({
    required this.currentPage,
    required this.lastVisiblePage,
    required this.hasNextPage,
    required this.itemsPerPage,
    required this.itemsTotal,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['current_page'] ?? 1,
      lastVisiblePage: json['last_visible_page'] ?? 1,
      hasNextPage: json['has_next_page'] ?? false,
      itemsPerPage: json['items']?['per_page'] ?? 25,
      itemsTotal: json['items']?['total'] ?? 0,
    );
  }
}
