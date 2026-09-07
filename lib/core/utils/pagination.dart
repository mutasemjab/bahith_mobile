class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => PaginationMeta(
    currentPage: json['current_page'] ?? 1,
    lastPage: json['last_page'] ?? 1,
    perPage: json['per_page'] ?? 15,
    total: json['total'] ?? 0,
  );

  factory PaginationMeta.single(int count) =>
      PaginationMeta(currentPage: 1, lastPage: 1, perPage: count, total: count);

  bool get hasNextPage => currentPage < lastPage;
}

class PaginatedResult<T> {
  final List<T> items;
  final PaginationMeta meta;

  const PaginatedResult({required this.items, required this.meta});
}
