/// The switches behind Settings → Developer, for trying offline and error
/// states on purpose.
///
/// They live behind an interface in `core/network/`, like the API services,
/// so nothing outside this folder touches the fake backend directly.
abstract interface class DeveloperToolsService {
  /// Whether every request fails, as if offline.
  bool get failsRequests;

  set failsRequests(bool value);

  /// Revokes the current token, so the next request answers 401.
  Future<void> expireSession();
}
