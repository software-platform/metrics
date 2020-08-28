import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics/common/presentation/constants/duration_constants.dart';
import 'package:metrics/common/presentation/strings/common_strings.dart';
import 'package:metrics/common/presentation/toast/widgets/negative_toast.dart';
import 'package:metrics/project_groups/presentation/pages/project_group_page.dart';
import 'package:metrics/project_groups/presentation/state/project_groups_notifier.dart';
import 'package:metrics/project_groups/presentation/widgets/project_group_view.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../../test_utils/metrics_themed_testbed.dart';
import '../../../test_utils/project_groups_notifier_mock.dart';
import '../../../test_utils/test_injection_container.dart';

void main() {
  group("ProjectGroupPage", () {
    testWidgets(
      "displays the project group text",
      (WidgetTester tester) async {
        await mockNetworkImagesFor(
          () => tester.pumpWidget(const _ProjectGroupPageTestbed()),
        );

        expect(
          find.text(CommonStrings.projectGroups),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      "contains the project group view",
      (WidgetTester tester) async {
        await mockNetworkImagesFor(
          () => tester.pumpWidget(const _ProjectGroupPageTestbed()),
        );

        expect(find.byType(ProjectGroupView), findsOneWidget);
      },
    );

    testWidgets(
      "displays the negative toast with a project group error message if such exists",
      (WidgetTester tester) async {
        const error = "Something went wrong";
        final projectGroupsNotifier = ProjectGroupsNotifierMock();

        await mockNetworkImagesFor(() {
          return tester.pumpWidget(_ProjectGroupPageTestbed(
            projectGroupsNotifier: projectGroupsNotifier,
          ));
        });

        when(projectGroupsNotifier.projectGroupsErrorMessage).thenReturn(error);
        projectGroupsNotifier.notifyListeners();

        await tester.pumpAndSettle();

        final negativeToastFinder = find.widgetWithText(NegativeToast, error);

        expect(negativeToastFinder, findsOneWidget);

        await tester.pump(DurationConstants.toast);
      },
    );
  });
}

/// A testbed widget, used to test the [ProjectGroupPage] widget.
class _ProjectGroupPageTestbed extends StatelessWidget {
  /// The [ProjectGroupsNotifier] to inject and use to test the [ProjectGroupPage].
  final ProjectGroupsNotifier projectGroupsNotifier;

  /// Creates the [_ProjectGroupPageTestbed] with the given [projectGroupsNotifier].
  const _ProjectGroupPageTestbed({
    Key key,
    this.projectGroupsNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TestInjectionContainer(
      projectGroupsNotifier: projectGroupsNotifier,
      child: MetricsThemedTestbed(
        body: ProjectGroupPage(),
      ),
    );
  }
}
