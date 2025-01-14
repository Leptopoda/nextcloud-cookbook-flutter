part of 'services.dart';

class VersionProvider {
  late ApiVersion _currentApiVersion;
  bool warningWasShown = false;

  Future<ApiVersion> fetchApiVersion() async {
    warningWasShown = false;

    final AppAuthentication appAuthentication =
        UserRepository().currentAppAuthentication;

    final response = await appAuthentication.authenticatedClient
        .get("${appAuthentication.server}/index.php/apps/cookbook/api/version");

    if (response.statusCode == 200 &&
        !response.data.toString().startsWith("<!DOCTYPE html>")) {
      try {
        _currentApiVersion = ApiVersion.fromJson(response.data.toString());
      } catch (e) {
        _currentApiVersion = ApiVersion(0, 0, 0, 0, 0);
        _currentApiVersion.loadFailureMessage = e.toString();
      }
    } else {
      _currentApiVersion = ApiVersion(0, 0, 0, 0, 0);
    }

    return _currentApiVersion;
  }

  ApiVersion getApiVersion() {
    return _currentApiVersion;
  }
}

class ApiVersion {
  static const int confirmedMajorAPIVersion = 1;
  static const int confirmedMinorAPIVersion = 1;

  final int majorApiVersion;
  final int minorApiVersion;
  final int majorAppVersion;
  final int minorAppVersion;
  final int patchAppVersion;

  String loadFailureMessage = "";

  ApiVersion(
    this.majorApiVersion,
    this.minorApiVersion,
    this.majorAppVersion,
    this.minorAppVersion,
    this.patchAppVersion,
  );

  factory ApiVersion.fromJson(String jsonString) {
    final data = json.decode(jsonString) as Map<String, dynamic>;

    if (!(data.containsKey("cookbook_version") &&
        data.containsKey("api_version"))) {
      throw Exception("Required Fields not present!\n$jsonString");
    }

    final appVersion = (data["cookbook_version"] as List).cast<int>();
    final apiVersion = data["api_version"] as Map<String, dynamic>;

    if (!(appVersion.length == 3 &&
        apiVersion.containsKey("major") &&
        apiVersion.containsKey("minor"))) {
      throw Exception("Required Fields not present!\n$jsonString");
    }

    return ApiVersion(
      apiVersion["major"] as int,
      apiVersion["minor"] as int,
      appVersion[0],
      appVersion[1],
      appVersion[2],
    );
  }

  /// Returns a VersionCode that indicates the app which endpoints to call.
  /// Versions only need to be adapted if backwards comparability is required.
  AndroidApiVersion getAndroidVersion() {
    if (majorApiVersion == 0 && minorApiVersion == 0) {
      return AndroidApiVersion.beforeApiEndpoint;
    } else {
      return AndroidApiVersion.categoryApiTransition;
    }
  }

  bool isVersionAboveConfirmed() {
    if (majorApiVersion > confirmedMajorAPIVersion ||
        (majorApiVersion == confirmedMajorAPIVersion &&
            minorApiVersion > confirmedMinorAPIVersion)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  String toString() {
    return "ApiVersion: $majorApiVersion.$minorApiVersion  AppVersion: $majorAppVersion.$minorAppVersion.$patchAppVersion";
  }
}

enum AndroidApiVersion { beforeApiEndpoint, categoryApiTransition }
