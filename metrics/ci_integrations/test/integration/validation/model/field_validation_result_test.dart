// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:ci_integration/integration/validation/model/field_validation_conclusion.dart';
import 'package:ci_integration/integration/validation/model/field_validation_result.dart';
import 'package:test/test.dart';

// ignore_for_file: avoid_redundant_argument_values

void main() {
  group("FieldValidationResult", () {
    const additionalContext = 'context';
    const data = 'data';

    const successResult = FieldValidationResult.success();
    const failureResult = FieldValidationResult.failure();
    const unknownResult = FieldValidationResult.unknown();

    test(
      ".success() creates an instance with the valid field validation conclusion",
      () {
        expect(
          successResult.conclusion,
          equals(FieldValidationConclusion.valid),
        );
      },
    );

    test(
      ".success() creates an instance with the given parameters",
      () {
        const result = FieldValidationResult.success(
          additionalContext: additionalContext,
          data: data,
        );

        expect(result.additionalContext, equals(additionalContext));
        expect(result.data, equals(data));
      },
    );

    test(
      ".isSuccess returns true if the result is successful",
      () {
        expect(successResult.isSuccess, isTrue);
      },
    );

    test(
      ".isFailure returns false if the result is successful",
      () {
        expect(successResult.isFailure, isFalse);
      },
    );

    test(
      ".isUnknown returns false if the result is successful",
      () {
        expect(successResult.isUnknown, isFalse);
      },
    );

    test(
      ".failure() creates an instance with the invalid field validation conclusion",
      () {
        expect(
          failureResult.conclusion,
          equals(FieldValidationConclusion.invalid),
        );
      },
    );

    test(
      ".failure() creates an instance with the given parameters",
      () {
        const result = FieldValidationResult.failure(
          additionalContext: additionalContext,
          data: data,
        );

        expect(result.additionalContext, equals(additionalContext));
        expect(result.data, equals(data));
      },
    );

    test(
      ".isSuccess returns false if the result is failure",
      () {
        expect(failureResult.isSuccess, isFalse);
      },
    );

    test(
      ".isFailure returns true if the result is failure",
      () {
        expect(failureResult.isFailure, isTrue);
      },
    );

    test(
      ".isUnknown returns false if the result is failure",
      () {
        expect(failureResult.isUnknown, isFalse);
      },
    );

    test(
      ".unknown() creates an instance with the unknown field validation conclusion",
      () {
        expect(
          unknownResult.conclusion,
          equals(FieldValidationConclusion.unknown),
        );
      },
    );

    test(
      ".unknown() creates an instance with the given parameters",
      () {
        const result = FieldValidationResult.unknown(
          additionalContext: additionalContext,
          data: data,
        );

        expect(result.additionalContext, equals(additionalContext));
        expect(result.data, equals(data));
      },
    );

    test(
      ".isSuccess returns false if the result is unknown",
      () {
        expect(unknownResult.isSuccess, isFalse);
      },
    );

    test(
      ".isFailure returns false if the result is unknown",
      () {
        expect(unknownResult.isFailure, isFalse);
      },
    );

    test(
      ".isUnknown returns true if the result is unknown",
      () {
        expect(unknownResult.isUnknown, isTrue);
      },
    );
  });
}
