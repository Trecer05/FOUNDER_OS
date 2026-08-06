import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/simulation/product_projection_cache.dart';

void main() {
  setUp(ProductProjectionCache.clearForTesting);

  test('identical product configurations reuse immutable projection', () {
    ProductProjectionCache.estimate(
      blueprintId: 'company_website',
      frameworkId: 'static_web',
      languageIds: const <String>['html_css'],
      technologyIds: const <String>[],
      featureIds: const <String>['landing_page'],
    );
    final first = ProductProjectionCache.estimate(
      blueprintId: 'company_website',
      frameworkId: 'static_web',
      languageIds: const <String>['html_css'],
      technologyIds: const <String>[],
      featureIds: const <String>['landing_page'],
    );
    final second = ProductProjectionCache.estimate(
      blueprintId: 'company_website',
      frameworkId: 'static_web',
      languageIds: const <String>['html_css'],
      technologyIds: const <String>[],
      featureIds: const <String>['landing_page'],
    );

    expect(identical(first, second), isTrue);
    expect(ProductProjectionCache.cachedEntryCount, 1);
  });

  test('cache stays bounded', () {
    for (var index = 0; index < 180; index += 1) {
      ProductProjectionCache.estimate(
        blueprintId: 'company_website',
        frameworkId: 'static_web',
        languageIds: List<String>.filled(index + 1, 'html_css'),
        technologyIds: const <String>[],
        featureIds: const <String>['landing_page'],
      );
    }
    expect(
      ProductProjectionCache.cachedEntryCount,
      lessThanOrEqualTo(ProductProjectionCache.maxEntries),
    );
  });
}
