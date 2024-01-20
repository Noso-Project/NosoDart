/// Represents information about the application and protocol version.
///
/// The AppInfo class encapsulates details about the application and protocol version, including the [protocol] version
/// and [appVersion]. It provides a constructor for creating AppInfo objects with default values and is typically used
/// to convey information about the application version when creating orders, where data from this model is transmitted
/// to a node in the network.
///
/// Properties:
///   - [protocol]: The protocol version used by the application. Default is 1.0.
///   - [appVersion]: The version of the application. Default is "0".
///
/// Note: This model is commonly utilized when creating orders, where the information about the application version is
/// transmitted to a node in the network.
class AppInfo {
  double protocol = 1.0;
  String appVersion;

  AppInfo({
    this.appVersion = "0",
  });
}
