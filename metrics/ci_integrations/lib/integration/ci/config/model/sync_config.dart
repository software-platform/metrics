// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// A class that represents a configuration of the synchronization process.
@immutable
class SyncConfig extends Equatable {
  /// A unique identifier of the source project to load the project builds from.
  final String sourceProjectId;

  /// A unique identifier of the destination project to save the project
  /// builds to.
  final String destinationProjectId;

  /// A number of builds to fetch from the source during project's
  /// initial synchronization.
  final int initialSyncLimit;

  /// A [Duration] that defines the timeout for in-progress builds.
  final Duration inProgressTimeout;

  /// A flag that indicates whether to fetch coverage data for builds or not.
  final bool coverage;

  @override
  List<Object> get props => [
        sourceProjectId,
        destinationProjectId,
        initialSyncLimit,
        inProgressTimeout,
        coverage,
      ];

  /// Creates an instance of the [SyncConfig] with the given parameters.
  ///
  /// Throws an [ArgumentError] if any of the given parameters is `null`.
  ///
  /// Throws an [ArgumentError] if the given [initialSyncLimit] is
  /// less than or equal to `0`.
  /// Throws an [ArgumentError] if the given [inProgressTimeout] is negative.
  SyncConfig({
    @required this.sourceProjectId,
    @required this.destinationProjectId,
    @required this.coverage,
    @required this.initialSyncLimit,
    @required this.inProgressTimeout,
  }) {
    ArgumentError.checkNotNull(sourceProjectId, 'sourceProjectId');
    ArgumentError.checkNotNull(destinationProjectId, 'destinationProjectId');
    ArgumentError.checkNotNull(coverage, 'coverage');

    if (initialSyncLimit == null || initialSyncLimit <= 0) {
      throw ArgumentError(
        'The initial sync limit must be an integer value grater than 0',
      );
    }

    if (inProgressTimeout == null || inProgressTimeout.isNegative) {
      throw ArgumentError(
        'The in-progress timeout must be a non-negative duration.',
      );
    }
  }
}
