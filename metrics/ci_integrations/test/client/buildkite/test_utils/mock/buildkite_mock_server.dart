// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'dart:io';
import 'dart:math';

import 'package:api_mock_server/api_mock_server.dart';
import 'package:ci_integration/client/buildkite/mappers/buildkite_build_state_mapper.dart';
import 'package:ci_integration/client/buildkite/models/buildkite_artifact.dart';
import 'package:ci_integration/client/buildkite/models/buildkite_build.dart';
import 'package:ci_integration/client/buildkite/models/buildkite_build_state.dart';
import 'package:ci_integration/client/buildkite/models/buildkite_organization.dart';
import 'package:ci_integration/client/buildkite/models/buildkite_pipeline.dart';
import 'package:ci_integration/client/buildkite/models/buildkite_token.dart';
import 'package:ci_integration/client/buildkite/models/buildkite_token_scope.dart';

import '../../../test_utils/mock_server_utils.dart';

/// A mock server for the Buildkite API.
class BuildkiteMockServer extends ApiMockServer {
  /// A path to emulate a download url.
  static const String _downloadPath = '/download';

  /// Returns a base path of the Buildkite API.
  String get basePath => '/organizations/organization_slug';

  @override
  List<RequestHandler> get handlers => [
        RequestHandler.get(
          pathMatcher: ExactPathMatcher(
            '$basePath/pipelines/pipeline_slug/builds',
          ),
          dispatcher: _pipelineBuildsResponse,
        ),
        RequestHandler.get(
          pathMatcher: ExactPathMatcher(
            '$basePath/pipelines/not_found/builds',
          ),
          dispatcher: MockServerUtils.notFoundResponse,
        ),
        RequestHandler.get(
          pathMatcher: ExactPathMatcher(
            '$basePath/pipelines/pipeline_slug/builds/1',
          ),
          dispatcher: _buildResponse,
        ),
        RequestHandler.get(
          pathMatcher: ExactPathMatcher(
            '$basePath/pipelines/not_found/builds/1',
          ),
          dispatcher: MockServerUtils.notFoundResponse,
        ),
        RequestHandler.get(
          pathMatcher: ExactPathMatcher(
            '$basePath/pipelines/pipeline_slug/builds/-1',
          ),
          dispatcher: MockServerUtils.notFoundResponse,
        ),
        RequestHandler.get(
          pathMatcher: ExactPathMatcher(
            '$basePath/pipelines/pipeline_slug/builds/1/artifacts',
          ),
          dispatcher: _pipelineBuildArtifactsResponse,
        ),
        RequestHandler.get(
          pathMatcher: ExactPathMatcher(
            '$basePath/pipelines/pipeline_slug/builds/-1/artifacts',
          ),
          dispatcher: MockServerUtils.notFoundResponse,
        ),
        RequestHandler.get(
          pathMatcher: ExactPathMatcher(
            '/access-token',
          ),
          dispatcher: _accessTokenResponse,
        ),
        RequestHandler.get(
          pathMatcher: ExactPathMatcher(
            basePath,
          ),
          dispatcher: _organizationResponse,
        ),
        RequestHandler.get(
          pathMatcher: ExactPathMatcher(
            '/organizations/not_found',
          ),
          dispatcher: MockServerUtils.notFoundResponse,
        ),
        RequestHandler.get(
          pathMatcher: ExactPathMatcher(
            '$basePath/pipelines/pipeline_slug',
          ),
          dispatcher: _pipelineResponse,
        ),
        RequestHandler.get(
          pathMatcher: ExactPathMatcher(
            '$basePath/pipelines/not_found',
          ),
          dispatcher: MockServerUtils.notFoundResponse,
        ),
        RequestHandler.get(
          pathMatcher: ExactPathMatcher(
            '$basePath/pipelines/pipeline_slug/builds/1/artifacts/artifact_id/download',
          ),
          dispatcher: _downloadArtifactResponse,
        ),
        RequestHandler.get(
          pathMatcher: ExactPathMatcher(
            '$basePath/pipelines/pipeline_slug/builds/1/artifacts/not_found/download',
          ),
          dispatcher: MockServerUtils.notFoundResponse,
        ),
        RequestHandler.get(
          pathMatcher: ExactPathMatcher(_downloadPath),
          dispatcher: MockServerUtils.downloadResponse,
        ),
      ];

  @override
  List<AuthCredentials> get authCredentials => const [
        AuthCredentials(token: 'token'),
      ];

  /// Responses with a list of [BuildkiteBuild]s having the build states
  /// and the finished at specified in the [request] parameters.
  ///
  /// Takes the per page and the page number parameters from the [request]
  /// and returns the per page number of [BuildkiteBuild]s from the page with
  /// the page number.
  Future<void> _pipelineBuildsResponse(HttpRequest request) async {
    final states = _extractBuildStates(request);
    final perPage = _getValidPerPage(_extractPerPage(request));
    final pageNumber = _extractPage(request);
    final finishedFrom = _extractFinishedFrom(request);

    List<BuildkiteBuild> builds = _generateBuilds(states, finishedFrom);

    _setNextPageUrlHeader(request, builds.length, perPage, pageNumber);

    builds = MockServerUtils.paginate(builds, perPage, pageNumber);

    final response = builds.map((build) => build.toJson()).toList();

    await MockServerUtils.writeResponse(request, body: response);
  }

  /// Responses with a [BuildkiteBuild] with the build number extracted from
  /// the given [request].
  Future<void> _buildResponse(HttpRequest request) async {
    final buildNumber = _extractBuildNumber(request);

    final build = BuildkiteBuild(number: buildNumber);
    final data = build.toJson();

    await MockServerUtils.writeResponse(request, body: data);
  }

  /// Responses with a list of [BuildkiteArtifact]s.
  ///
  /// Takes the per page and the page number parameters from the [request]
  /// and returns the per page number of [BuildkiteArtifact]s from the page with
  /// the page number.
  Future<void> _pipelineBuildArtifactsResponse(HttpRequest request) async {
    final perPage = _getValidPerPage(_extractPerPage(request));
    final pageNumber = _extractPage(request);

    List<BuildkiteArtifact> artifacts = _generateArtifacts();

    _setNextPageUrlHeader(request, artifacts.length, perPage, pageNumber);

    artifacts = MockServerUtils.paginate(artifacts, perPage, pageNumber);

    final response = artifacts.map((artifact) => artifact.toJson()).toList();

    await MockServerUtils.writeResponse(request, body: response);
  }

  /// Responses with a [BuildkiteToken].
  Future<void> _accessTokenResponse(HttpRequest request) async {
    const token = BuildkiteToken(
      scopes: [BuildkiteTokenScope.readBuilds],
    );

    final tokenJson = token.toJson();

    await MockServerUtils.writeResponse(request, body: tokenJson);
  }

  /// Responses with a [BuildkiteOrganization].
  Future<void> _organizationResponse(HttpRequest request) async {
    const organization = BuildkiteOrganization(
      id: 'id',
      name: 'name',
      slug: 'slug',
    );

    final organizationJson = organization.toJson();

    await MockServerUtils.writeResponse(request, body: organizationJson);
  }

  /// Responses with a [BuildkitePipeline].
  Future<void> _pipelineResponse(HttpRequest request) async {
    const pipeline = BuildkitePipeline(
      id: 'id',
      name: 'name',
      slug: 'slug',
    );

    final pipelineJson = pipeline.toJson();

    await MockServerUtils.writeResponse(request, body: pipelineJson);
  }

  /// Redirects to the artifact download URL.
  Future<void> _downloadArtifactResponse(HttpRequest request) async {
    final uri = Uri.parse(url);

    await request.response.redirect(
      Uri(host: uri.host, port: uri.port, path: _downloadPath),
      status: HttpStatus.found,
    );

    await request.response.close();
  }

  /// Returns the build number extracted from the path of the given [request].
  int _extractBuildNumber(HttpRequest request) {
    final buildNumber = request.uri.pathSegments.last;

    return int.tryParse(buildNumber);
  }

  /// Returns a [List] of [BuildkiteBuildState]s, based on the `state` query
  /// parameter of the given [request].
  List<BuildkiteBuildState> _extractBuildStates(HttpRequest request) {
    final requestedStates = request.uri.queryParametersAll['state[]'];

    if (requestedStates == null) return null;

    const buildkiteStateMapper = BuildkiteBuildStateMapper();

    return requestedStates
        .map((state) => buildkiteStateMapper.map(state))
        .toList();
  }

  /// Generates a list of [BuildkiteBuild]s with the [BuildkiteBuildState]s
  /// from the given [states] and [finishedFrom].
  ///
  /// If the given [finishedFrom] is `null`, the [DateTime.now] is used.
  /// Selects a [BuildkiteBuildState]s from the given [states] using the
  /// [_selectState] method.
  List<BuildkiteBuild> _generateBuilds([
    List<BuildkiteBuildState> states,
    DateTime finishedFrom,
  ]) {
    return List.generate(100, (index) {
      return BuildkiteBuild(
        id: 'id',
        number: index,
        blocked: false,
        state: _selectState(index, states),
        webUrl: 'url',
        startedAt: DateTime(2020),
        finishedAt: finishedFrom ?? DateTime.now(),
      );
    });
  }

  /// Selects a [BuildkiteBuildState] from the given [states].
  ///
  /// Returns a [BuildkiteBuildState.passed] if the given [states] is `null` or
  /// empty. Otherwise, returns a [BuildkiteBuildState] selected from the given
  /// [states] list.
  BuildkiteBuildState _selectState(
    int buildNumber, [
    List<BuildkiteBuildState> states,
  ]) {
    if (states == null || states.isEmpty) return BuildkiteBuildState.passed;

    final stateIndex = buildNumber % states.length;

    return states[stateIndex];
  }

  /// Generates a list of [BuildkiteArtifact]s.
  List<BuildkiteArtifact> _generateArtifacts() {
    return List.generate(
      100,
      (index) => BuildkiteArtifact(
        id: 'id',
        filename: 'coverage$index',
        downloadUrl: 'url',
        mimeType: 'json',
      ),
    );
  }

  /// Returns the `finished_from` query parameter of the given [request].
  ///
  /// Returns `null` if the `finishedFrom` is `null` or the [DateTime] can't be
  /// parsed from the given `finishedFrom`.
  DateTime _extractFinishedFrom(HttpRequest request) {
    final finishedFrom = request.uri.queryParameters['finished_from'];

    if (finishedFrom == null) return null;

    return DateTime.tryParse(finishedFrom);
  }

  /// Returns a valid per page number based on the given [perPage].
  ///
  /// If the given [perPage] is `null` or less or equal to zero, returns `30`,
  /// otherwise, returns [perPage].
  int _getValidPerPage(int perPage) {
    if (perPage == null || perPage <= 0) return 30;

    return perPage;
  }

  /// Returns the `per_page` query parameter of the given [request].
  ///
  /// Returns `null` if the `perPage` is `null`.
  int _extractPerPage(HttpRequest request) {
    final perPage = request.uri.queryParameters['per_page'];

    if (perPage == null) return null;

    return int.tryParse(perPage);
  }

  /// Returns the `page` query parameter of the given [request].
  ///
  /// Returns `null` if the `page` is `null`.
  int _extractPage(HttpRequest request) {
    final page = request.uri.queryParameters['page'];

    if (page == null) return null;

    return int.tryParse(page);
  }

  /// Sets the next page url header using the given [request], [itemsCount],
  /// [perPage] and [pageNumber].
  void _setNextPageUrlHeader(
    HttpRequest request,
    int itemsCount,
    int perPage,
    int pageNumber,
  ) {
    final lastPageNumber = _getLastPageNumber(itemsCount, perPage);

    if (pageNumber >= lastPageNumber) return;

    final requestUrl = request.requestedUri.toString();
    final indexOfPageParam = requestUrl.indexOf("&page=");
    final nextPageUrl = requestUrl.replaceRange(
      indexOfPageParam,
      requestUrl.length,
      "&page=${pageNumber + 1}",
    );

    request.response.headers.set('link', '<$nextPageUrl> rel="next"');
  }

  /// Returns the last page number.
  ///
  /// Returns `1` if the given [perPage] or [total] parameter is `null`
  /// or the given [perPage] is less than zero.
  int _getLastPageNumber(int total, int perPage) {
    if (perPage == null || perPage <= 0 || total == null) return 1;

    return max((total / perPage).ceil(), 1);
  }
}
