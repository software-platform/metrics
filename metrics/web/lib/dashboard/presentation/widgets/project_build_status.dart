import 'package:flutter/material.dart';
import 'package:metrics/common/presentation/metrics_theme/model/project_build_status/style/project_build_status_style.dart';
import 'package:metrics/common/presentation/metrics_theme/widgets/metrics_theme.dart';
import 'package:metrics/dashboard/presentation/view_models/project_build_status_view_model.dart';
import 'package:metrics/dashboard/presentation/widgets/strategy/project_build_status_strategy.dart';
import 'package:metrics_core/metrics_core.dart';

/// A class that displays an image representation of the project build status.
class ProjectBuildStatus extends StatelessWidget {
  /// A [ProjectBuildStatusViewModel] that represents a status of the build
  /// to display.
  final ProjectBuildStatusViewModel buildStatus;

  /// A class that provides a [ProjectBuildStatusStyle] and icon image
  /// based on the [BuildStatus].
  final ProjectBuildStatusStrategy projectBuildStatusStrategy;

  /// Creates an instance of the [ProjectBuildStatus]
  /// with the given [buildStatus] and [strategy].
  ///
  /// Both [buildStatus] and [strategy] must not be null.
  const ProjectBuildStatus({
    Key key,
    @required this.buildStatus,
    @required this.projectBuildStatusStrategy,
  })  : assert(buildStatus != null),
        assert(projectBuildStatusStrategy != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final projectBuildStatus = buildStatus?.value;
    final iconImage = projectBuildStatusStrategy.getIconImage(projectBuildStatus);
    final theme = projectBuildStatusStrategy.getWidgetStyle(
      MetricsTheme.of(context),
      projectBuildStatus,
    );

    return Container(
      height: 40.0,
      width: 40.0,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Image.network(iconImage),
    );
  }
}
