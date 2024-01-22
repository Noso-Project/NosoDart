/// A class representing seed information for network communication.
///
/// The [Seed] class encapsulates essential details such as IP address, port number,
/// ping response time, online status, and an address identifier. It includes methods
/// for tokenizing raw seed information, converting the instance into a raw string,
/// and parsing seed information from a response string.
///
/// Example:
/// ```dart
/// Seed seed = Seed(ip: "192.168.0.1", port: 8080, ping: 20, online: true, address: "example");
/// print(seed.ip);        // Output: "192.168.0.1"
/// print(seed.port);      // Output: 8080
/// print(seed.address);   // Output: "noso address"
/// ```
class Seed {
  String ip;
  int port;
  String address;
  int ping;
  bool online;

  Seed({
    this.ip = "127.0.0.1",
    this.port = 8080,
    this.address = "",
    this.ping = 0,
    this.online = false,
  });

  /// Tokenizes the provided raw seed information, extracting relevant details.
  ///
  /// Given a verified seed [verSeed] and an optional raw string [rawString],
  /// this method parses and tokenizes the raw information to extract essential
  /// details like IP address and port number. If the [rawString] is null or
  /// its length is less than or equal to 5, the method returns the current
  /// instance without making any changes.
  ///
  /// The expected format of the raw string is assumed to be "ip:port".
  ///
  /// Example:
  /// ```dart
  /// Seed seed = Seed();
  /// seed.tokenizer("122.148.0.3", rawString: "192.168.0.1:8080");
  /// print(seed.ip);   // Output: "192.168.0.1"
  /// print(seed.port); // Output: 8080
  /// ```
  ///
  /// Parameters:
  /// - [verSeed]: A verified seed string.
  /// - [rawString]: An optional raw string containing IP address and port.
  ///
  /// Returns:
  /// The current instance of the Seed class after tokenization.
  Seed tokenizer(String verSeed, {String? rawString}) {
    if (rawString == null || rawString.length <= 5) {
      if (verSeed.isEmpty || verSeed.length <= 5) {
        return this;
      } else {
        rawString = verSeed;
      }
    }
    List<String> seedPart = rawString.split(":");
    return copyWith(ip: seedPart[0], port: int.parse(seedPart[1]));
  }

  /// Converts the essential details of the Seed instance into a raw string.
  ///
  /// This method returns an unprocessed string by combining the IP address
  /// and port number, following the format "ip:port".
  ///
  /// Example:
  /// ```dart
  /// Seed seed = Seed(ip: "192.168.0.1", port: 8080);
  /// print(seed.toTokenizer()); // Output: "192.168.0.1:8080"
  /// ```
  ///
  /// Returns:
  /// An unprocessed raw string representing the IP address and port.
  ///
  String get toTokenizer => "$ip:$port";

  Seed copyWith({
    String? ip,
    int? port,
    String? address,
  }) {
    return Seed(
      ip: ip ?? this.ip,
      port: port ?? this.port,
      address: address ?? this.address,
    );
  }
}
