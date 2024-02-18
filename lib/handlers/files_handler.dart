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
  ///
  /// Returns:
  /// A list of [AddressObject] parsed from the byte array, or null if the fileBytes is null or empty.
  static List<AddressObject>? readExternalWallet(Uint8List? fileBytes) {
    final List<AddressObject> address = [];
    if (fileBytes == null || fileBytes.isEmpty) {
      return null;
    }

    try {
      Uint8List current = fileBytes.sublist(0, 625);
      Uint8List bytes = fileBytes.sublist(626);

      while (current.isNotEmpty) {
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
        if (bytes.length >= 626) {
          current = bytes.sublist(0, 625);
          bytes = bytes.sublist(626);
        } else {
          current = Uint8List(0);
        }

        if (keyPair.isValid()) {
          bool verification = NosoSigner().verifyKeysPair(keyPair);
          if (verification) {
            address.add(addressObject);
          }
        }
      }
      return address.isEmpty ? null : address;
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
        bytes.addAll(nosoMath.doubleToByte(0.0000000)); //Pendings
        bytes.addAll(nosoMath.doubleToByte(0.0000000)); //Score
        bytes.addAll(nosoMath.doubleToByte(0.0000000)); //lastOp
      }

      return bytes.isEmpty ? null : bytes;
    } catch (e) {
      print("Error writeWalletFile: $e");
      return null;
    }
  }

  /// Parses an external wallet file represented by a Uint8List.
  /// The file format is assumed to follow a specific structure:
  /// Each record in the file consists of 625 bytes, starting from the beginning.
  /// The record structure:
  /// Byte 1: Length of the hash (N)
  /// Bytes 2 to (N+1): Hash
  /// Bytes 42 to (41+N): Custom data
  /// Bytes 83 to (82+N): Public Key
  /// Bytes 339 to (338+N): Private Key
  /// The method returns a List<AddressObject> containing parsed AddressObject instances.
  ///
  /// Parameters:
  /// - fileBytes: The Uint8List representing the content of the external wallet file.
  ///
  /// Returns:
  /// A List<AddressObject> containing parsed address objects. An empty list is returned
  /// if the fileBytes are null or empty.
  static List<AddressObject> parseExternalWallet(Uint8List? fileBytes) {
    final List<AddressObject> address = [];
    if (fileBytes == null || fileBytes.isEmpty) {
      return address;
    }
    Uint8List current = fileBytes.sublist(0, 625);
    Uint8List bytes = fileBytes.sublist(626);

    while (current.isNotEmpty) {
      AddressObject addressObject = AddressObject(
          hash: String.fromCharCodes(current.sublist(1, current[0] + 1)),
          custom: String.fromCharCodes(current.sublist(42, 42 + current[41])),
          publicKey:
              String.fromCharCodes(current.sublist(83, 83 + current[82])),
          privateKey:
              String.fromCharCodes(current.sublist(339, 339 + current[338])));

      if (bytes.length >= 626) {
        current = bytes.sublist(0, 625);
        bytes = bytes.sublist(626);
      } else {
        current = Uint8List(0);
      }

      if (addressObject.privateKey.length == 44 &&
          addressObject.publicKey.length == 88) {
        bool verification = NosoSigner().verifyKeysPair(KeyPair(
            publicKey: addressObject.publicKey,
            privateKey: addressObject.privateKey));
        if (verification) {
          address.add(addressObject);
        }
      }
    }
    return address;
  }
}
