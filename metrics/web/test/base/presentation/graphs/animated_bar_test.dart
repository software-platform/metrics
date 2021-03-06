// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics/base/presentation/graphs/animated_bar.dart';
import 'package:metrics/base/presentation/widgets/rive_animation.dart';
import 'package:rive/rive.dart';

import '../../../test_utils/presentation/widgets/rive_animation_testbed.dart';

// ignore_for_file: avoid_redundant_argument_values

void main() {
  group("AnimatedBar", () {
    const asset = 'asset';
    final riveAnimationFinder = find.byType(RiveAnimation);

    testWidgets(
      "throws an AssertionError if the given height is null",
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const _AnimatedBarTestbed(
            height: null,
          ),
        );

        expect(tester.takeException(), isAssertionError);
      },
    );

    testWidgets(
      "throws an AssertionError if the given height is negative",
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const _AnimatedBarTestbed(
            height: -1.0,
          ),
        );

        expect(tester.takeException(), isAssertionError);
      },
    );

    testWidgets(
      "throws an AssertionError if the given height equals to zero",
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const _AnimatedBarTestbed(
            height: 0.0,
          ),
        );

        expect(tester.takeException(), isAssertionError);
      },
    );

    testWidgets(
      "throws an AssertionError if the given width is null",
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const _AnimatedBarTestbed(
            width: null,
          ),
        );

        expect(tester.takeException(), isAssertionError);
      },
    );

    testWidgets(
      "throws an AssertionError if the given width is negative",
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const _AnimatedBarTestbed(
            width: -1.0,
          ),
        );

        expect(tester.takeException(), isAssertionError);
      },
    );

    testWidgets(
      "throws an AssertionError if the given width equals to zero",
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const _AnimatedBarTestbed(
            width: 0.0,
          ),
        );

        expect(tester.takeException(), isAssertionError);
      },
    );

    testWidgets(
      "applies the given height to the animated bar",
      (WidgetTester tester) async {
        const expectedHeight = 20.0;

        await tester.pumpWidget(
          const _AnimatedBarTestbed(
            height: expectedHeight,
          ),
        );
        await tester.pump();

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));

        expect(sizedBox.height, equals(expectedHeight));
      },
    );

    testWidgets(
      "applies the given width to the animated bar",
      (WidgetTester tester) async {
        const expectedWidth = 20.0;

        await tester.pumpWidget(
          const _AnimatedBarTestbed(
            width: expectedWidth,
          ),
        );
        await tester.pump();

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));

        expect(sizedBox.width, equals(expectedWidth));
      },
    );

    testWidgets(
      "applies the animation alignment to the rive animation widget",
      (WidgetTester tester) async {
        const expectedAlignment = Alignment.topLeft;

        await tester.pumpWidget(
          const _AnimatedBarTestbed(
            animationAlignment: expectedAlignment,
          ),
        );

        final rive = tester.widget<RiveAnimation>(riveAnimationFinder);

        expect(rive.alignment, equals(expectedAlignment));
      },
    );

    testWidgets(
      "applies the given asset to the rive animation widget",
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const _AnimatedBarTestbed(
            riveAsset: asset,
          ),
        );

        final rive = tester.widget<RiveAnimation>(riveAnimationFinder);

        expect(rive.assetName, equals(asset));
      },
    );

    testWidgets(
      "applies the given controller to the rive animation widget",
      (WidgetTester tester) async {
        final controller = SimpleAnimation('1');

        await tester.pumpWidget(
          _AnimatedBarTestbed(
            controller: controller,
          ),
        );

        final rive = tester.widget<RiveAnimation>(riveAnimationFinder);

        expect(rive.controller, equals(controller));
      },
    );

    testWidgets(
      "applies the given artboard name to the rive animation widget",
      (WidgetTester tester) async {
        const artboardName = 'name';

        await tester.pumpWidget(
          const _AnimatedBarTestbed(
            artboardName: artboardName,
          ),
        );

        final rive = tester.widget<RiveAnimation>(riveAnimationFinder);

        expect(rive.artboardName, equals(artboardName));
      },
    );

    testWidgets(
      "applies the BoxFit.fitWidth to the rive animation widget",
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const _AnimatedBarTestbed(),
        );

        final rive = tester.widget<RiveAnimation>(riveAnimationFinder);

        expect(rive.fit, equals(BoxFit.fitWidth));
      },
    );
  });
}

/// A testbed class required to test the [AnimatedBar] widget.
class _AnimatedBarTestbed extends StatelessWidget {
  /// A width to use in tests.
  final double width;

  /// A height to use in tests.
  final double height;

  /// An animation [Alignment] to use in tests.
  final Alignment animationAlignment;

  /// A rive animation asset to use in tests.
  final String riveAsset;

  /// A [RiveAnimationController] to use in tests.
  final RiveAnimationController controller;

  /// An artboard name to use in tests.
  final String artboardName;

  /// Creates a new instance of this testbed with the given parameters.
  ///
  /// The [riveAsset] defaults to `'asset'`.
  /// The [width] defaults to `10.0`.
  /// The [height] defaults to `10.0`.
  const _AnimatedBarTestbed({
    Key key,
    this.controller,
    this.artboardName,
    this.riveAsset = 'asset',
    this.animationAlignment,
    this.width = 10.0,
    this.height = 10.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: RiveAnimationTestbed(
          child: AnimatedBar(
            height: height,
            width: width,
            animationAlignment: animationAlignment,
            riveAsset: riveAsset,
            controller: controller,
            artboardName: artboardName,
          ),
        ),
      ),
    );
  }
}
