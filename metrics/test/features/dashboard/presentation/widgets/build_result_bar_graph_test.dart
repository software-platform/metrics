import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics/features/dashboard/domain/entities/build.dart';
import 'package:metrics/features/dashboard/presentation/config/color_config.dart';
import 'package:metrics/features/dashboard/presentation/model/build_result_bar_data.dart';
import 'package:metrics/features/dashboard/presentation/widgets/build_result_bar_graph.dart';
import 'package:metrics/features/dashboard/presentation/widgets/colored_bar.dart';

void main() {
  const buildResults = BuildResultBarGraphTestbed.buildResultBarTestData;

  testWidgets('Displays title text', (WidgetTester tester) async {
    const title = 'Some title';

    await tester.pumpWidget(const BuildResultBarGraphTestbed(title: title));

    expect(find.text(title), findsOneWidget);
  });

  testWidgets(
    'Applies the text style to the title',
    (WidgetTester tester) async {
      const title = 'title';
      const titleStyle = TextStyle(color: Colors.red);

      await tester.pumpWidget(const BuildResultBarGraphTestbed(
        title: title,
        titleStyle: titleStyle,
      ));

      final titleWidget = tester.widget<Text>(find.text(title));

      expect(titleWidget.style, titleStyle);
    },
  );

  testWidgets(
    "Can't create widget without title",
    (WidgetTester tester) async {
      await tester.pumpWidget(const BuildResultBarGraphTestbed(title: null));

      expect(tester.takeException(), isA<AssertionError>());
    },
  );

  testWidgets(
    "Can't create widget without data",
    (WidgetTester tester) async {
      await tester.pumpWidget(const BuildResultBarGraphTestbed(data: null));

      expect(tester.takeException(), isA<AssertionError>());
    },
  );

  testWidgets(
    "Creates the correct number of bars",
    (WidgetTester tester) async {
      await tester.pumpWidget(const BuildResultBarGraphTestbed());

      final barWidgets = tester.widgetList(find.byType(ColoredBar));

      expect(barWidgets.length, buildResults.length);
    },
  );

  testWidgets(
    "Creates bars with ptoper colors",
    (WidgetTester tester) async {
      await tester.pumpWidget(const BuildResultBarGraphTestbed());

      final barWidgets =
          tester.widgetList<ColoredBar>(find.byType(ColoredBar)).toList();

      for (int i = 0; i < buildResults.length; i++) {
        final barWidget = barWidgets[i];
        final buildResult = buildResults[i];

        Color expectedBarColor;

        switch (buildResult.result) {
          case BuildResult.successful:
            expectedBarColor = ColorConfig.accentColor;
            break;
          case BuildResult.canceled:
            expectedBarColor = ColorConfig.cancelColor;
            break;
          case BuildResult.failed:
            expectedBarColor = ColorConfig.errorColor;
            break;
        }

        expect(barWidget.color, expectedBarColor);
      }
    },
  );
}

class BuildResultBarGraphTestbed extends StatelessWidget {
  static const buildResultBarTestData = [
    BuildResultBarData(
      result: BuildResult.successful,
      value: 5,
    ),
    BuildResultBarData(
      result: BuildResult.failed,
      value: 2,
    ),
    BuildResultBarData(
      result: BuildResult.canceled,
      value: 8,
    ),
  ];

  final String title;
  final TextStyle titleStyle;
  final List<BuildResultBarData> data;

  const BuildResultBarGraphTestbed({
    Key key,
    this.title = "Build result graph",
    this.data = buildResultBarTestData,
    this.titleStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: BuildResultBarGraph(
            data: data,
            title: title,
            titleStyle: titleStyle,
          ),
        ),
      ),
    );
  }
}
