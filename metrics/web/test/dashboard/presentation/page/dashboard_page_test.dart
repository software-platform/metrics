// Use of this source code is governed by the Apache License, Version 2.0 
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics/auth/presentation/state/auth_notifier.dart';
import 'package:metrics/common/presentation/app_bar/widget/metrics_app_bar.dart';
import 'package:metrics/common/presentation/metrics_theme/state/theme_notifier.dart';
import 'package:metrics/common/presentation/metrics_theme/widgets/metrics_theme_builder.dart';
import 'package:metrics/common/presentation/toast/widgets/negative_toast.dart';
import 'package:metrics/dashboard/presentation/pages/dashboard_page.dart';
import 'package:metrics/dashboard/presentation/state/project_metrics_notifier.dart';
import 'package:metrics/dashboard/presentation/widgets/metrics_table.dart';
import 'package:metrics/dashboard/presentation/widgets/project_groups_dropdown_menu.dart';
import 'package:metrics/dashboard/presentation/widgets/project_metrics_search_input.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../../test_utils/project_metrics_notifier_mock.dart';
import '../../../test_utils/test_injection_container.dart';

void main() {
  group("DashboardPage", () {
    ProjectMetricsNotifier projectMetricsNotifier;

    setUp(() {
      projectMetricsNotifier = ProjectMetricsNotifierMock();
    });

    tearDown(() {
      reset(projectMetricsNotifier);
    });

    testWidgets(
      "contains the MetricsAppBar widget",
      (WidgetTester tester) async {
        await mockNetworkImagesFor(() {
          return tester.pumpWidget(const _DashboardTestbed());
        });

        expect(find.byType(MetricsAppBar), findsOneWidget);
      },
    );

    testWidgets(
      "contains the MetricsTable widget",
      (WidgetTester tester) async {
        await mockNetworkImagesFor(() {
          return tester.pumpWidget(const _DashboardTestbed());
        });

        expect(find.byType(MetricsTable), findsOneWidget);
      },
    );

    testWidgets(
      "contains the project groups dropdown menu",
      (WidgetTester tester) async {
        await mockNetworkImagesFor(() {
          return tester.pumpWidget(const _DashboardTestbed());
        });

        expect(find.byType(ProjectGroupsDropdownMenu), findsOneWidget);
      },
    );

    testWidgets(
      "contains the project metrics search input",
      (tester) async {
        await mockNetworkImagesFor(() {
          return tester.pumpWidget(const _DashboardTestbed());
        });

        expect(find.byType(ProjectMetricsSearchInput), findsOneWidget);
      },
    );

    testWidgets(
      "displays the negative toast if there is a projects error message",
      (WidgetTester tester) async {
        const errorMessage = "some error message";

        when(projectMetricsNotifier.isMetricsLoading).thenReturn(false);

        await mockNetworkImagesFor(() {
          return tester.pumpWidget(_DashboardTestbed(
            metricsNotifier: projectMetricsNotifier,
          ));
        });

        when(projectMetricsNotifier.projectsErrorMessage)
            .thenReturn(errorMessage);

        projectMetricsNotifier.notifyListeners();

        await tester.pump();

        expect(
          find.widgetWithText(NegativeToast, errorMessage),
          findsOneWidget,
        );

        ToastManager().dismissAll();
      },
    );
  });
}

/// A testbed widget, used to test the [DashboardPage] widget.
class _DashboardTestbed extends StatelessWidget {
  /// The [ThemeNotifier] to inject and use to test the [DashboardPage].
  final ThemeNotifier themeNotifier;

  /// The [ProjectMetricsNotifier] to inject and use to test the [DashboardPage].
  final ProjectMetricsNotifier metricsNotifier;

  /// The [AuthNotifier] to inject and use to test the [DashboardPage].
  final AuthNotifier authNotifier;

  /// Creates the [_DashboardTestbed] with the given [themeNotifier].
  const _DashboardTestbed({
    Key key,
    this.themeNotifier,
    this.metricsNotifier,
    this.authNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TestInjectionContainer(
      themeNotifier: themeNotifier,
      metricsNotifier: metricsNotifier,
      authNotifier: authNotifier,
      child: Builder(builder: (context) {
        return MaterialApp(
          home: MetricsThemeBuilder(
            builder: (_, __) {
              return const DashboardPage();
            },
          ),
        );
      }),
    );
  }
}
