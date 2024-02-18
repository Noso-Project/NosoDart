import 'dart:convert';
import 'dart:typed_data';

import 'package:noso_dart/models/keys_pair.dart';
import 'package:pointycastle/asn1/primitives/asn1_integer.dart';
import 'package:pointycastle/asn1/primitives/asn1_sequence.dart';
import 'package:pointycastle/export.dart';

import '../const.dart';

class NosoSigner {
  final _algorithmName = Mac("SHA-1/HMAC");
  final _curve = ECCurve_secp256k1();

  /// A method that checks the secret keys for an address
  bool verifyKeysPair(KeyPair keysPair) {
    if (!keysPair.isValid()) {
      return false;
    }
    var signature = signMessage(NosoConst.verifyMessage, keysPair.privateKey);
    if (signature == null) {
      return false;
    }
    return verifyMessage(
        NosoConst.verifyMessage, signature, keysPair.publicKey);
  }

  /// Signs a message using a private key and returns the EC signature.
  /// Reference: https://stackoverflow.com/questions/72641616/how-to-convert-asymmetrickeypair-to-base64-encoding-string-in-dart
  ECSignature? signMessage(String message, String privateKeyBase64) {
    try {
      Uint8List messageBytes = Uint8List.fromList(_nosoBase64Decode(message));
      BigInt privateKeyDecode =
          _bytesToBigInt(Uint8List.fromList(base64.decode(privateKeyBase64)));
      ECPrivateKey privateKey = ECPrivateKey(privateKeyDecode, _curve);

      var signer = ECDSASigner(SHA1Digest(), _algorithmName)
        ..init(true, PrivateKeyParameter<ECPrivateKey>(privateKey));
      ECSignature ecSignature =
          signer.generateSignature(messageBytes) as ECSignature;

      return ecSignature;
    } catch (e) {
      print("Error create signature: $e");
      return null;
    }
  }

  /// Decodes a Base64-encoded string into an [ECSignature] object.
  ///
  /// Parameters:
  /// - [base64Signature] A Base64-encoded string representing an ECDSA signature.
  ///
  /// Returns:
  /// An [ECSignature] object decoded from the provided Base64-encoded string.
  ///
  /// Throws:
  /// - [FormatException] if the decoding process fails.
  ECSignature decodeBase64ToSignature(String base64Signature) {
    // Decode the Base64 string into bytes.
    List<int> decodedBytes = base64Decode(base64Signature);

    // Decode the ASN.1 sequence to retrieve the 'r' and 's' values.
    ASN1Sequence sequence =
        ASN1Sequence.fromBytes(Uint8List.fromList(decodedBytes));
    BigInt r = (sequence.elements![0] as ASN1Integer).integer!;
    BigInt s = (sequence.elements![1] as ASN1Integer).integer!;

    // Create and return the ECSignature object.
    return ECSignature(r, s);
  }

  /// Encodes an EC signature to a Base64-encoded string.
  String encodeSignatureToBase64(ECSignature ecSignature) {
    final encoded = ASN1Sequence(elements: [
      ASN1Integer(ecSignature.r),
      ASN1Integer(ecSignature.s),
    ]).encode();
    return base64Encode(encoded);
  }

  /// Verifies a signed message using the provided EC signature and public key.
  bool verifyMessage(String message, ECSignature signature, String publicKey) {
    try {
      final Uint8List messageBytes =
          Uint8List.fromList(_nosoBase64Decode(message));
      ECPoint? publicKeyPoint =
          _curve.curve.decodePoint(base64.decode(publicKey));
      ECPublicKey publicKeys = ECPublicKey(publicKeyPoint, _curve);

      var verifier = ECDSASigner(SHA1Digest(), _algorithmName)
        ..init(false, PublicKeyParameter<ECPublicKey>(publicKeys));

      return verifier.verifySignature(messageBytes, signature);
    } catch (e) {
      print("Error verify signature: $e");
      return false;
    }
  }

  /// Converts a byte array to a BigInt
  BigInt _bytesToBigInt(Uint8List bytes) {
    BigInt result = BigInt.zero;
    for (int i = 0; i < bytes.length; i++) {
      result = (result << 8) + BigInt.from(bytes[i]);
    }
    return result;
  }

  /// Special Base-64 encoder for Noso coin
  List<int> _nosoBase64Decode(String input) {
    final indexList = <int>[];
    for (var c in input.codeUnits) {
      final it = NosoConst.b64Alphabet.indexOf(String.fromCharCode(c));
      if (it != -1) {
        indexList.add(it);
      }
    }

    final binaryString =
        indexList.map((i) => i.toRadixString(2).padLeft(6, '0')).join();

    var strAux = binaryString;
    final tempByteArray = <int>[];

    while (strAux.length >= 8) {
      final currentGroup = strAux.substring(0, 8);
      final intVal = int.parse(currentGroup, radix: 2);
      tempByteArray.add(intVal);
      strAux = strAux.substring(8);
    }

    return tempByteArray;
  }
}
