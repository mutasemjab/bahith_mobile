/// Parses a value that may arrive as a num, a numeric string, or null —
/// several endpoints on this API return numeric fields (price, ratings)
/// as strings inconsistently.
double? toDoubleOrNull(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

double toDouble(dynamic value) => toDoubleOrNull(value) ?? 0;

/// Same defensive handling as [toDoubleOrNull], for fields (mainly `id`)
/// that are supposed to be ints but occasionally arrive as numeric
/// strings.
int? toIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

int toInt(dynamic value) => toIntOrNull(value) ?? 0;

/// Several endpoints return related-entity fields (subject, teacher,
/// category, class) as a plain name string on list views but as a nested
/// object elsewhere — handle both without crashing.
String? relatedName(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is Map) return value['name'] as String?;
  return null;
}

/// Detail endpoints on this API tend to wrap the primary resource under
/// a key matching its name alongside sibling lists, e.g.
/// `{ "category": {...}, "children": [...], "subjects": [...] }` rather
/// than spreading the resource's own fields at the top level. Unwraps
/// that nesting when present, falling back to the raw map otherwise so
/// callers don't crash if an endpoint turns out to be flat after all.
Map<String, dynamic> unwrapResource(Map<String, dynamic> data, String key) {
  final nested = data[key];
  if (nested is Map<String, dynamic>) return nested;
  return data;
}
