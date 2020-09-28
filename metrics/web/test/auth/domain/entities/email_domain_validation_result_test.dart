import 'package:flutter_test/flutter_test.dart';
import 'package:metrics/auth/domain/entities/email_domain_validation_result.dart';

void main() {
  group("EmailDomainValidationResult", () {
    const isValid = false;

    test("successfully creates with the given required parameters", () {
      expect(
        () => EmailDomainValidationResult(isValid: isValid),
        returnsNormally,
      );
    });

    test(
      "throws an ArgumentError when created with null is valid parameter",
      () {
        expect(
          () => EmailDomainValidationResult(isValid: null),
          throwsArgumentError,
        );
      },
    );
  });
}
