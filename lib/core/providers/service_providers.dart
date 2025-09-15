import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/services.dart';

// API Service Provider
final jikanApiServiceProvider = Provider<JikanApiService>((ref) {
  return JikanApiService();
});

// Hive Service Provider (for convenience, though it's static)
final hiveServiceProvider = Provider<HiveService>((ref) {
  throw UnimplementedError(
      'HiveService is static, use HiveService methods directly');
});

// Keep the API service alive for the entire app lifecycle
final apiServiceKeepaliveProvider = Provider<JikanApiService>((ref) {
  final service = JikanApiService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});
