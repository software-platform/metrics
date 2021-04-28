// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:metrics/common/domain/entities/build_day.dart';
import 'package:metrics_core/metrics_core.dart';

/// A [DataModel] that represents the [BuildDay] entity.
class BuildDayData extends BuildDay implements DataModel {
  /// Creates a new instance of the [BuildDayData] with the
  /// given parameters.
  ///
  /// Throws an [ArgumentError] if any of the given parameters is `null`.
  BuildDayData({
    @required String projectId,
    @required int successful,
    @required int failed,
    @required int unknown,
    @required int inProgress,
    @required Duration totalDuration,
    @required DateTime day,
  }) : super(
          projectId: projectId,
          successful: successful,
          failed: failed,
          unknown: unknown,
          inProgress: inProgress,
          totalDuration: totalDuration,
          day: day,
        );

  /// Creates a new instance of [BuildDateData] using the given [json].
  factory BuildDayData.fromJson(Map<String, dynamic> json) {
    final totalDurationInMilliseconds = json['totalDuration'] as int;

    return BuildDayData(
      projectId: json['projectId'] as String,
      successful: json['successful'] as int,
      failed: json['failed'] as int,
      unknown: json['unknown'] as int,
      inProgress: json['inProgress'] as int,
      totalDuration: Duration(milliseconds: totalDurationInMilliseconds),
      day: (json['day'] as Timestamp).toDate(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'successful': successful,
      'failed': failed,
      'unknown': unknown,
      'inProgress': inProgress,
      'totalDuration': totalDuration,
      'day': Timestamp.fromDate(day),
    };
  }
}
