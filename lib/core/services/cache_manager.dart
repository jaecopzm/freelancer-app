import 'dart:async';

/// Simple in-memory cache manager for offline support
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  final Map<String, CacheEntry> _cache = {};
  final Map<String, Timer> _timers = {};

  /// Cache entry with expiration
  CacheEntry<T>? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    
    // Check if expired
    if (entry.isExpired) {
      remove(key);
      return null;
    }
    
    return entry as CacheEntry<T>?;
  }

  /// Store data in cache with optional TTL
  void set<T>(
    String key, 
    T data, {
    Duration? ttl = const Duration(minutes: 5),
  }) {
    // Cancel existing timer if any
    _timers[key]?.cancel();
    
    // Store in cache
    _cache[key] = CacheEntry<T>(
      data: data,
      timestamp: DateTime.now(),
      ttl: ttl,
    );

    // Set expiration timer if TTL is provided
    if (ttl != null) {
      _timers[key] = Timer(ttl, () => remove(key));
    }
  }

  /// Remove entry from cache
  void remove(String key) {
    _cache.remove(key);
    _timers[key]?.cancel();
    _timers.remove(key);
  }

  /// Clear all cache
  void clear() {
    _cache.clear();
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }

  /// Clear cache by pattern
  void clearPattern(bool Function(String key) matcher) {
    final keysToRemove = _cache.keys.where(matcher).toList();
    for (final key in keysToRemove) {
      remove(key);
    }
  }

  /// Check if key exists and is not expired
  bool has(String key) {
    final entry = _cache[key];
    if (entry == null) return false;
    if (entry.isExpired) {
      remove(key);
      return false;
    }
    return true;
  }
}

/// Cache entry model
class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final Duration? ttl;

  CacheEntry({
    required this.data,
    required this.timestamp,
    this.ttl,
  });

  bool get isExpired {
    if (ttl == null) return false;
    return DateTime.now().difference(timestamp) > ttl!;
  }

  Duration get age => DateTime.now().difference(timestamp);
}

/// Cache key generator
class CacheKeys {
  static String clients(String userId) => 'clients:$userId';
  static String client(String userId, String clientId) => 'client:$userId:$clientId';
  
  static String projects(String userId) => 'projects:$userId';
  static String project(String userId, String projectId) => 'project:$userId:$projectId';
  static String projectsByClient(String userId, String clientId) => 'projects:$userId:client:$clientId';
  
  static String invoices(String userId) => 'invoices:$userId';
  static String invoice(String userId, String invoiceId) => 'invoice:$userId:$invoiceId';
  static String invoicesByClient(String userId, String clientId) => 'invoices:$userId:client:$clientId';
  
  static String timeEntries(String userId) => 'time_entries:$userId';
  static String timeEntry(String userId, String entryId) => 'time_entry:$userId:$entryId';
  static String runningEntry(String userId) => 'running_entry:$userId';
}
