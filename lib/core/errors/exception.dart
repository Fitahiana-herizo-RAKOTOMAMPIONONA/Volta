class ServerException implements Exception {}
class CacheException implements Exception {}
class PlatformException implements Exception {
  final String message;
  PlatformException(this.message);
}