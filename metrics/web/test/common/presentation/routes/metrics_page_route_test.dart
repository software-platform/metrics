import 'package:flutter/material.dart';
import 'package:metrics/common/presentation/routes/metrics_page_route.dart';
import 'package:metrics/common/presentation/routes/route_name.dart';
import 'package:test/test.dart';

import '../../../test_utils/matcher_util.dart';

void main() {
  group('MetricsPageRoute', () {
    test(
      'constructor throws the AssertionError if the builder is null',
      () {
        expect(
          () => MetricsPageRoute(
            builder: null,
            settings: const RouteSettings(name: RouteName.login),
          ),
          MatcherUtil.throwsAssertionError,
        );
      },
    );

    test(
      'constructor throws the AssertionError if the settings is null',
      () {
        expect(
          () => MetricsPageRoute(builder: (_) => Container(), settings: null),
          MatcherUtil.throwsAssertionError,
        );
      },
    );

    test(
      'constructor throws the AssertionError if the maintainState is null',
      () {
        expect(
          () => MetricsPageRoute(
              builder: (_) => Container(),
              settings: const RouteSettings(name: RouteName.login),
              maintainState: null),
          MatcherUtil.throwsAssertionError,
        );
      },
    );

    test(
      'constructor throws the AssertionError if the fullscreenDialog is null',
      () {
        expect(
          () => MetricsPageRoute(
              builder: (_) => Container(),
              settings: const RouteSettings(name: RouteName.login),
              fullscreenDialog: null),
          MatcherUtil.throwsAssertionError,
        );
      },
    );
  });
}
