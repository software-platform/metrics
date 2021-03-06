// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics/base/presentation/widgets/tappable_area.dart';
import 'package:metrics/common/presentation/colored_bar/widgets/metrics_colored_bar.dart';
import 'package:metrics/common/presentation/metrics_theme/config/dimensions_config.dart';
import 'package:metrics/common/presentation/widgets/in_progress_animated_bar.dart';
import 'package:metrics/dashboard/presentation/view_models/build_result_popup_view_model.dart';
import 'package:metrics/dashboard/presentation/view_models/build_result_view_model.dart';
import 'package:metrics/dashboard/presentation/view_models/finished_build_result_view_model.dart';
import 'package:metrics/dashboard/presentation/view_models/in_progress_build_result_view_model.dart';
import 'package:metrics/dashboard/presentation/widgets/build_result_bar.dart';
import 'package:metrics/dashboard/presentation/widgets/strategy/build_result_bar_appearance_strategy.dart';
import 'package:metrics_core/metrics_core.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:rive/rive.dart';

import '../../../test_utils/presentation/widgets/rive_animation_testbed.dart';

// ignore_for_file: avoid_redundant_argument_values

void main() {
  group("BuildResultBar", () {
    const height = 10.0;

    final popupViewModel = BuildResultPopupViewModel(
      date: DateTime.now(),
      duration: Duration.zero,
      buildStatus: BuildStatus.successful,
    );
    final successfulBuildResult = FinishedBuildResultViewModel(
      buildResultPopupViewModel: popupViewModel,
      date: DateTime.now(),
      duration: const Duration(seconds: 20),
      buildStatus: BuildStatus.successful,
    );
    final inProgressBuildResult = InProgressBuildResultViewModel(
      buildResultPopupViewModel: popupViewModel,
      date: DateTime.now(),
    );

    final metricsColoredBarFinder = find.byWidgetPredicate(
      (widget) => widget is MetricsColoredBar<BuildStatus>,
    );
    final inProgressAnimatedBarFinder = find.byType(InProgressAnimatedBar);

    final mouseRegionFinder = find.ancestor(
      of: find.byType(GestureDetector),
      matching: find.byType(MouseRegion),
    );

    MetricsColoredBar getMetricsColoredBar(WidgetTester tester) {
      return tester.widget<MetricsColoredBar>(metricsColoredBarFinder);
    }

    InProgressAnimatedBar getInProgressAnimatedBar(WidgetTester tester) {
      return tester.widget<InProgressAnimatedBar>(inProgressAnimatedBarFinder);
    }

    Future<void> hoverBar(WidgetTester tester) async {
      final mouseRegion = tester.widget<MouseRegion>(mouseRegionFinder);
      mouseRegion.onEnter(const PointerEnterEvent());
    }

    testWidgets(
      "throws an AssertionError if the given build result view model is null",
      (tester) async {
        await tester.pumpWidget(
          const _BuildResultBarTestbed(
            buildResult: null,
          ),
        );

        expect(tester.takeException(), isAssertionError);
      },
    );

    testWidgets(
      "applies the tappable area",
      (tester) async {
        await tester.pumpWidget(
          _BuildResultBarTestbed(
            buildResult: successfulBuildResult,
          ),
        );

        expect(find.byType(TappableArea), findsOneWidget);
      },
    );

    testWidgets(
      "displays the metrics colored bar if the given build result view model is finished",
      (tester) async {
        await tester.pumpWidget(
          _BuildResultBarTestbed(
            buildResult: successfulBuildResult,
          ),
        );

        expect(metricsColoredBarFinder, findsOneWidget);
      },
    );

    testWidgets(
      "applies the BuildResultBarAppearanceStrategy to the metrics colored bar",
      (tester) async {
        await tester.pumpWidget(
          _BuildResultBarTestbed(
            buildResult: successfulBuildResult,
          ),
        );

        final bar = getMetricsColoredBar(tester);

        expect(bar.strategy, isA<BuildResultBarAppearanceStrategy>());
      },
    );

    testWidgets(
      "applies the hover state to the metrics colored bar",
      (tester) async {
        await tester.pumpWidget(
          _BuildResultBarTestbed(
            buildResult: successfulBuildResult,
          ),
        );

        await hoverBar(tester);
        await mockNetworkImagesFor(() {
          return tester.pumpAndSettle();
        });

        final bar = getMetricsColoredBar(tester);

        expect(bar.isHovered, isTrue);
      },
    );

    testWidgets(
      "applies the minimum height to the metrics colored bar height from the constraints",
      (tester) async {
        await tester.pumpWidget(
          _BuildResultBarTestbed(
            constraints: const BoxConstraints(minHeight: height),
            buildResult: successfulBuildResult,
          ),
        );

        final bar = getMetricsColoredBar(tester);

        expect(bar.height, equals(height));
      },
    );

    testWidgets(
      "displays the metrics colored bar with the build status from the given build result view model",
      (tester) async {
        final expectedStatus = successfulBuildResult.buildStatus;

        await tester.pumpWidget(
          _BuildResultBarTestbed(
            buildResult: successfulBuildResult,
          ),
        );

        final bar = getMetricsColoredBar(tester);

        expect(bar.value, equals(expectedStatus));
      },
    );

    testWidgets(
      "displays the in-progress animated bar if the given build result view model is in-progress",
      (tester) async {
        await tester.pumpWidget(
          _BuildResultBarTestbed(
            buildResult: inProgressBuildResult,
          ),
        );

        expect(inProgressAnimatedBarFinder, findsOneWidget);
      },
    );

    testWidgets(
      "applies the hover state to the in progress animated bar",
      (tester) async {
        await tester.pumpWidget(
          _BuildResultBarTestbed(
            buildResult: inProgressBuildResult,
          ),
        );

        await hoverBar(tester);
        await tester.pump();

        final animatedBar = getInProgressAnimatedBar(tester);

        expect(animatedBar.isHovered, isTrue);
      },
    );

    testWidgets(
      "displays the in-progress animated bar with the simple animation controller",
      (tester) async {
        await tester.pumpWidget(
          _BuildResultBarTestbed(
            constraints: const BoxConstraints(minHeight: height),
            buildResult: inProgressBuildResult,
          ),
        );

        final animatedBar = getInProgressAnimatedBar(tester);
        final controller = animatedBar.controller;

        expect(controller, isA<SimpleAnimation>());
      },
    );

    testWidgets(
      "displays the in-progress animated bar with the right animation name in the animation controller",
      (tester) async {
        const animationName = 'Animation 1';

        await tester.pumpWidget(
          _BuildResultBarTestbed(
            constraints: const BoxConstraints(minHeight: height),
            buildResult: inProgressBuildResult,
          ),
        );

        final animatedBar = getInProgressAnimatedBar(tester);
        final controller = animatedBar.controller as SimpleAnimation;

        expect(controller.animationName, equals(animationName));
      },
    );

    testWidgets(
      "applies the minimum height to the in-progress animated bar height from the constraints",
      (tester) async {
        await tester.pumpWidget(
          _BuildResultBarTestbed(
            constraints: const BoxConstraints(minHeight: height),
            buildResult: inProgressBuildResult,
          ),
        );

        final animatedBar = getInProgressAnimatedBar(tester);

        expect(animatedBar.height, equals(height));
      },
    );

    testWidgets(
      "applies the graph bar width from the dimensions config to the in progress animated bar",
      (tester) async {
        await tester.pumpWidget(
          _BuildResultBarTestbed(
            buildResult: inProgressBuildResult,
          ),
        );

        final animatedBar = getInProgressAnimatedBar(tester);

        expect(animatedBar.width, equals(DimensionsConfig.graphBarWidth));
      },
    );
  });
}

/// A testbed class required to test the [BuildResultBar].
class _BuildResultBarTestbed extends StatelessWidget {
  /// A [BuildResultViewModel] to display.
  final BuildResultViewModel buildResult;

  /// A [BoxConstraints] to apply to this bar in tests.
  final BoxConstraints constraints;

  /// Creates an instance of this testbed.
  /// The [constraints] defaults to a [BoxConstraints] instance with the
  /// [BoxConstraints.minHeight] equal to `10`.
  const _BuildResultBarTestbed({
    Key key,
    this.buildResult,
    this.constraints = const BoxConstraints(minHeight: 10),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: RiveAnimationTestbed(
          child: Container(
            constraints: constraints,
            child: BuildResultBar(
              buildResult: buildResult,
            ),
          ),
        ),
      ),
    );
  }
}
