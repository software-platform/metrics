// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:ci_integration/client/jenkins/model/jenkins_user.dart';
import 'package:test/test.dart';

void main() {
  group("JenkinsUser", () {
    const id = "id";
    const fullName = "Full Name";

    const userJson = {
      'id': id,
      'fullName': fullName,
    };

    const user = JenkinsUser(id: id, fullName: fullName);

    test(
      "creates an instance with the given parameters",
      () {
        const user = JenkinsUser(id: id, fullName: fullName);

        expect(user.fullName, equals(fullName));
        expect(user.id, equals(id));
      },
    );

    test(
      ".fromJson() returns null if the given json is null",
      () {
        final user = JenkinsUser.fromJson(null);

        expect(user, isNull);
      },
    );

    test(
      ".fromJson() creates an instance from the given json",
      () {
        final actualUser = JenkinsUser.fromJson(userJson);

        expect(actualUser, equals(user));
      },
    );

    test(
      ".listFromJson() returns null if the given list is null",
      () {
        final list = JenkinsUser.listFromJson(null);

        expect(list, isNull);
      },
    );

    test(
      ".listFromJson() returns an empty list if the given one is empty",
      () {
        final list = JenkinsUser.listFromJson([]);

        expect(list, isEmpty);
      },
    );

    test(
      ".listFromJson() creates a list of Jenkins users from the given list of JSON encodable objects",
      () {
        const anotherJson = {
          'id': '',
          'fullName': '',
        };
        const anotherUser = JenkinsUser(
          id: '',
          fullName: '',
        );
        const jsonList = [userJson, anotherJson];
        const expectedList = [user, anotherUser];

        final userList = JenkinsUser.listFromJson(jsonList);

        expect(userList, equals(expectedList));
      },
    );

    test(
      ".toJson() converts an instance to the json encodable map",
      () {
        final json = user.toJson();

        expect(json, equals(userJson));
      },
    );
  });
}
