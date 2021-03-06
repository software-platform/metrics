// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:metrics_core/src/util/validation/target_validation_result.dart';
import 'package:metrics_core/src/util/validation/validation_conclusion.dart';
import 'package:metrics_core/src/util/validation/validation_target.dart';
import 'package:test/test.dart';

import '../../test_utils/matchers.dart';

void main() {
  group("TargetValidationResult", () {
    const name = 'name';
    const description = 'description';
    const data = 'data';
    const details = {'test': 'details'};
    const context = {'test': 'context'};
    const target = ValidationTarget(name: name);
    const conclusion = ValidationConclusion(name: name);

    test(
      "throws an AssertionError if the given target is null",
      () {
        expect(
          () => TargetValidationResult(
            target: null,
            conclusion: conclusion,
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      "throws an AssertionError if the given conclusion is null",
      () {
        expect(
          () => TargetValidationResult(
            target: target,
            conclusion: null,
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      "creates an instance with the given parameters",
      () {
        const result = TargetValidationResult(
          target: target,
          conclusion: conclusion,
          description: description,
          details: details,
          context: context,
          data: data,
        );

        expect(result.target, equals(target));
        expect(result.conclusion, equals(conclusion));
        expect(result.description, equals(description));
        expect(result.details, equals(details));
        expect(result.context, equals(context));
        expect(result.data, equals(data));
      },
    );

    test(
      "creates an instance with an empty description if the given description is not specified",
      () {
        const result = TargetValidationResult(
          target: target,
          conclusion: conclusion,
        );

        expect(result.description, isEmpty);
      },
    );

    test(
      "creates an instance with an empty details if the given details are not specified",
      () {
        const result = TargetValidationResult(
          target: target,
          conclusion: conclusion,
        );

        expect(result.details, isEmpty);
      },
    );

    test(
      "creates an instance with an empty context if the given context is not specified",
      () {
        const result = TargetValidationResult(
          target: target,
          conclusion: conclusion,
        );

        expect(result.context, isEmpty);
      },
    );

    test(
      "equals to another TargetValidationResult instance with the same parameters",
      () {
        const result = TargetValidationResult(
          target: target,
          conclusion: conclusion,
          description: description,
          details: details,
          context: context,
          data: data,
        );
        const anotherResult = TargetValidationResult(
          target: target,
          conclusion: conclusion,
          description: description,
          details: details,
          context: context,
          data: data,
        );

        expect(result, equals(anotherResult));
      },
    );
  });
}
