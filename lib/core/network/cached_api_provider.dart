import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/cache_manager.dart';
import 'api_service.dart';
import 'cached_api_service.dart';
import 'connectivity_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final cacheManagerProvider = Provider<CacheManager>((ref) {
  return CacheManager();
});

final cachedApiServiceProvider = Provider<CachedApiService>((ref) {
  return CachedApiService(
    apiService: ref.read(apiServiceProvider),
    cacheManager: ref.read(cacheManagerProvider),
    connectivityService: ref.read(connectivityServiceProvider),
  );
});
