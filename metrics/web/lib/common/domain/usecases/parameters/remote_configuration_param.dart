import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Represents the remote configuration parameter.
class RemoteConfigurationParam extends Equatable {
  /// Indicates whether to show the login form.
  final bool isLoginFormEnabled;

  /// Indicates whether the FPS monitor feature is enabled.
  final bool isFpsMonitorEnabled;

  /// Indicates whether the renderer display feature is enabled.
  final bool isRendererDisplayEnabled;

  @override
  List<Object> get props => [
        isLoginFormEnabled,
        isFpsMonitorEnabled,
        isRendererDisplayEnabled,
      ];

  /// Creates a new instance of the [RemoteConfigurationParam]
  /// with the given [isLoginFormEnabled], [isFpsMonitorEnabled],
  /// and [isRendererDisplayEnabled].
  ///
  /// Throws an [AssertionError] if either [isLoginFormEnabled],
  /// [isFpsMonitorEnabled] or [isRendererDisplayEnabled] is null.
  const RemoteConfigurationParam({
    @required this.isLoginFormEnabled,
    @required this.isFpsMonitorEnabled,
    @required this.isRendererDisplayEnabled,
  })  : assert(isLoginFormEnabled != null),
        assert(isFpsMonitorEnabled != null),
        assert(isRendererDisplayEnabled != null);
}
