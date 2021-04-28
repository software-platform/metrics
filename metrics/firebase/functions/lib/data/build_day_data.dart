// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/data/build_day_status_field.dart';

/// A class that represents a build day to save in the [Firestore].
class BuildDayData {
  /// An identifier of the project, a build day relates to.
  final String projectId;

  /// A [Timestamp] that represents the day start a build day aggregation
  /// belongs to.
  final Timestamp day;

  /// A total builds duration.
  final FieldValue totalDuration;

  /// A [List] of [BuildDayStatusField]s, a [Firestore] increment applies to.
  final List<BuildDayStatusField> statusIncrements;

  /// Creates a new instance of the [BuildDayData] with the given parameters.
  BuildDayData({
    this.projectId,
    this.day,
    this.totalDuration,
    this.statusIncrements,
  });

  /// Converts this [BuildDayData] into the [Map].
  Map<String, dynamic> toMap() {
    final statusIncrementsMap = {};

    statusIncrements.forEach((status) {
      statusIncrementsMap.addAll(status.toMap());
    });

    return {
      'projectId': projectId,
      'day': day,
      'totalDuration': totalDuration,
      ...statusIncrementsMap,
    };
  }
}