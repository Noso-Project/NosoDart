import 'package:noso_dart/models/noso/address_object.dart';

import '../crypto/noso_core.dart';
import '../crypto/noso_signer.dart';
import '../models/keys_pair.dart';

class AddressHandler {
  /// Imports an AddressObject using a key pair string.
  ///
  /// This method takes a space-separated string containing a public key and a private key,
  /// verifies the validity of the key pair using the NosoSigner, and creates an AddressObject
  /// if the verification is successful and the key lengths are valid.
  ///
  /// Parameters:
  /// - [keys] A space-separated string containing a public key and a private key.
  /// - [keyPair] An optional parameter of type KeyPair to provide a custom KeyPair for verification.
  ///
  /// Returns:
  /// An AddressObject if the key pair is valid; otherwise, returns null.
  ///
  static AddressObject? importAddressForKeysPair(String keys,
      {KeyPair? keyPair}) {
    KeyPair valueKeys = keyPair == null
        ? KeyPair(publicKey: "", privateKey: "").fromString(keys)
        : keyPair;

    if (!valueKeys.isValid()) {
      return null;
    }

    bool verification = NosoSigner().verifyKeysPair(KeyPair(
        publicKey: valueKeys.publicKey, privateKey: valueKeys.privateKey));
    if (!verification) {
      return null;
    }
    return AddressObject(
        hash: NosoCore().getAddressFromPublicKey(valueKeys.publicKey),
        privateKey: valueKeys.privateKey,
        publicKey: valueKeys.publicKey);
  }

  /// Generates a new address using NosoCore's key pair generation.
  ///
  /// This method creates a new key pair using the NosoCore's generateKeyPair method,
  /// and then constructs an AddressObject with the generated public key, private key, and
  /// the derived address from the public key.
  ///
  /// Returns:
  /// An [AddressObject] representing the newly created address.
  static AddressObject createNewAddress() {
    KeyPair keyPair = NosoCore().generateKeyPair();
    return AddressObject(
        publicKey: keyPair.publicKey,
        privateKey: keyPair.privateKey,
        hash: getAddressFromPublicKey(keyPair.publicKey));
  }

  /// Derives an address from a public key.
  ///
  /// This method takes a public key as input and uses NosoCore's getAddressFromPublicKey
  /// method to derive the corresponding address.
  ///
  /// Parameters:
  /// - [publicKey] The public key for which the address needs to be derived.
  ///
  /// Returns:
  /// A string representing the derived address.
  static String getAddressFromPublicKey(String publicKey) {
    return NosoCore().getAddressFromPublicKey(publicKey);
  }
}
