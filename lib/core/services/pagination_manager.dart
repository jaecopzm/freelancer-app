/// Pagination configuration and utilities
class PaginationConfig {
  final int pageSize;
  final int maxPages;

  const PaginationConfig({
    this.pageSize = 20,
    this.maxPages = 100,
  });

  static const small = PaginationConfig(pageSize: 10);
  static const standard = PaginationConfig(pageSize: 20);
  static const large = PaginationConfig(pageSize: 50);
}

/// Paginated result container
class PaginatedResult<T> {
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMore;

  const PaginatedResult({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasMore,
  });

  factory PaginatedResult.empty() {
    return const PaginatedResult(
      items: [],
      currentPage: 0,
      totalPages: 0,
      totalItems: 0,
      hasMore: false,
    );
  }

  /// Create from items and page info
  factory PaginatedResult.fromItems(
    List<T> items, {
    required int page,
    required int pageSize,
    int? totalItems,
  }) {
    final total = totalItems ?? items.length;
    final totalPages = (total / pageSize).ceil();
    
    return PaginatedResult(
      items: items,
      currentPage: page,
      totalPages: totalPages,
      totalItems: total,
      hasMore: page < totalPages,
    );
  }

  /// Merge with another result (for infinite scroll)
  PaginatedResult<T> merge(PaginatedResult<T> other) {
    return PaginatedResult(
      items: [...items, ...other.items],
      currentPage: other.currentPage,
      totalPages: other.totalPages,
      totalItems: other.totalItems,
      hasMore: other.hasMore,
    );
  }
}

/// Pagination helper for Supabase queries
class PaginationHelper {
  /// Calculate range for Supabase query
  static Map<String, int> getRange(int page, int pageSize) {
    final from = page * pageSize;
    final to = from + pageSize - 1;
    return {'from': from, 'to': to};
  }

  /// Get page number from offset
  static int getPageFromOffset(int offset, int pageSize) {
    return (offset / pageSize).floor();
  }

  /// Get offset from page number
  static int getOffsetFromPage(int page, int pageSize) {
    return page * pageSize;
  }
}
