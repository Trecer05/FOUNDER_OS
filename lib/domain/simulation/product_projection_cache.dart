import 'dart:collection';

import 'product_estimator.dart';

/// Small deterministic LRU cache for immutable product projections.
///
/// Product configuration changes rarely, while simulation ticks request the
/// same projection repeatedly. Keeping this cache outside GameState avoids any
/// snapshot/RNG changes and removes repeated catalog walks from the hot path.
abstract final class ProductProjectionCache {
  static const int maxEntries = 128;
  static final LinkedHashMap<String, ProductProjection> _entries =
      LinkedHashMap<String, ProductProjection>();

  static ProductProjection estimate({
    required String blueprintId,
    required String frameworkId,
    required List<String> languageIds,
    required List<String> technologyIds,
    required List<String> featureIds,
  }) {
    final key = _key(
      blueprintId,
      frameworkId,
      languageIds,
      technologyIds,
      featureIds,
    );
    final cached = _entries.remove(key);
    if (cached != null) {
      _entries[key] = cached;
      return cached;
    }

    final projection = ProductEstimator.estimate(
      blueprintId: blueprintId,
      frameworkId: frameworkId,
      languageIds: languageIds,
      technologyIds: technologyIds,
      featureIds: featureIds,
    );
    _entries[key] = projection;
    if (_entries.length > maxEntries) {
      _entries.remove(_entries.keys.first);
    }
    return projection;
  }

  static int get cachedEntryCount => _entries.length;

  static void clearForTesting() => _entries.clear();

  static String _key(
    String blueprintId,
    String frameworkId,
    List<String> languageIds,
    List<String> technologyIds,
    List<String> featureIds,
  ) {
    const separator = '\u001f';
    const groupSeparator = '\u001e';
    return <String>[
      blueprintId,
      frameworkId,
      languageIds.join(separator),
      technologyIds.join(separator),
      featureIds.join(separator),
    ].join(groupSeparator);
  }
}
