import 'dart:convert';
import 'dart:typed_data';

import 'package:noso_dart/models/keys_pair.dart';
import 'package:noso_dart/models/noso/address_object.dart';

import '../crypto/noso_signer.dart';
import '../utils/noso_math.dart';

class FileHandler {
  /// Reads an external wallet from a byte array and returns a list of [AddressObject].
  ///
  /// Parameters:
  /// - `fileBytes`: The byte array representing the external wallet file.
  /// - `isIngoreVerification`: ignore the verification of addresses with a signature in order to quickly import large addresses or addresses locked in a file
  ///
  /// Returns:
  /// A list of [AddressObject] parsed from the byte array, or null if the fileBytes is null or empty.
  static List<AddressObject>? readExternalWallet(Uint8List? fileBytes,
      {bool isIngoreVerification = false}) {
    final List<AddressObject> addresses = [];
    if (fileBytes == null || fileBytes.isEmpty) {
      return null;
    }

    try {
      int cursor = 0;

      while (cursor + 625 <= fileBytes.length) {
        Uint8List current = fileBytes.sublist(cursor, cursor + 625);
        cursor += 626;

        var hash = String.fromCharCodes(current.sublist(1, current[0] + 1));
        var custom =
            String.fromCharCodes(current.sublist(42, 42 + current[41]));

        AddressObject addressObject = AddressObject(
            hash: hash,
            custom: custom.isEmpty ? null : custom,
            publicKey:
                String.fromCharCodes(current.sublist(83, 83 + current[82])),
            privateKey:
                String.fromCharCodes(current.sublist(339, 339 + current[338])));

        var keyPair = KeyPair(
            publicKey: addressObject.publicKey,
            privateKey: addressObject.privateKey);

        if (keyPair.isValid()) {
          if (isIngoreVerification) {
            addresses.add(addressObject);
          } else {
            bool verification = NosoSigner().verifyKeysPair(keyPair);
            if (verification) {
              addresses.add(addressObject);
            }
          }
        }
      }
      return addresses.isEmpty ? null : addresses;
    } catch (e) {
      print("Error readExternalWallet: $e");
      return null;
    }
  }

  /// Writes a list of [AddressObject] to a byte array.
  ///
  /// Parameters:
  /// - `addressList`: The list of [AddressObject] to be written.
  ///
  /// Returns:
  /// A [List<int>] representing the byte array of the written data, or null if the addressList is empty.
  static List<int>? writeWalletFile(List<AddressObject> addressList) {
    List<int> bytes = [];
    var nosoMath = NosoMath();

    if (addressList.isEmpty) {
      return null;
    }
    try {
      for (AddressObject wallet in addressList) {
        bytes.add(wallet.hash.length);
        bytes.addAll(utf8.encode(wallet.hash.padRight(40)));

        var custom = wallet.custom ?? "";
        bytes.add(custom.length);

        bytes.addAll(utf8.encode(custom.padRight(40)));

        bytes.add(wallet.publicKey.length);
        bytes.addAll(utf8.encode(wallet.publicKey.padRight(255)));
        bytes.add(wallet.privateKey.length);
        bytes.addAll(utf8.encode(wallet.privateKey.padRight(255)));

        bytes.addAll(
            nosoMath.intToBytes(nosoMath.doubleToBigEndian(wallet.balance)));
        bytes.addAll([0, 0, 0, 0, 0, 0, 0, 0]); //Pendings
        bytes.addAll([0, 0, 0, 0, 0, 0, 0, 0]); //Score
        bytes.addAll([0, 0, 0, 0, 0, 0, 0, 0]); //lastOp
      }

      return bytes.isEmpty ? null : bytes;
    } catch (e) {
      print("Error writeWalletFile: $e");
      return null;
    }
  }
}
