/// Represents a key pair consisting of a public key and a private key.
class KeyPair {
  /// The public key of the key pair.
  String publicKey;

  /// The private key of the key pair.
  String privateKey;

  /// Constructs a [KeyPair] with the specified public and private keys.
  KeyPair({
    required this.publicKey,
    required this.privateKey,
  });

  /// Checks the validity of the key pair represented by this [KeyPair] instance.
  ///
  /// Returns:
  /// - `true` if the length of the public key is 44 characters and the length of the private key is 88 characters,
  ///   indicating a valid key pair.
  /// - `false` otherwise, indicating an invalid key pair.
  ///
  /// This method is useful for quickly verifying the integrity of the key lengths within the context of the KeyPair instance.
  ///

  bool isValid() {
    return publicKey.length == 88 && privateKey.length == 44;
  }

  /// Returns a string representation of the key pair in the format "publicKey privateKey".
  @override
  String toString() {
    return "$publicKey $privateKey";
  }

  /// Creates a [KeyPair] object from a space-separated string containing a public key and a private key.
  ///
  /// Parameters:
  /// - [keys] A space-separated string containing a public key and a private key.
  ///
  /// Returns:
  /// A [KeyPair] object created from the provided string.
  ///
  KeyPair fromString(String keys) {
    List<String> keyParts = keys.split(' ');
    publicKey = keyParts[0];
    privateKey = keyParts[1];
    return this;
  }
}
