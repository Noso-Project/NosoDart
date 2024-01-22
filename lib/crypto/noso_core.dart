import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:noso_dart/const.dart';
import 'package:pointycastle/export.dart';

import '../models/keys_pair.dart';

class _DivResult {
  BigInt coefficient = BigInt.zero;
  BigInt remainder = BigInt.zero;
}

class NosoCore {
  /// Returns the generated transfer hash for a given value.
  ///
  /// This method takes a value as input, computes its SHA-256 hash, encodes the hash
  /// using base58 encoding with a base of 58, calculates the checksum, converts the
  /// checksum to base58, and constructs the transfer hash with the prefix "tr".
  ///
  /// Parameters:
  /// - value: The value for which the transfer hash needs to be generated.
  ///
  /// Returns:
  /// A string representing the generated transfer hash.
  String getTransferHash(String value) {
    var hash256 = getSha256HashToString(value);
    hash256 = base58Encode(hash256, BigInt.from(58));
    var sumatoria = base58Checksum(hash256);
    final bd58 = base58DecimalTo58(sumatoria.toString());
    return "tr$hash256$bd58";
  }

  /// Returns the generated order hash for a given value.
  ///
  /// This method takes a value as input, computes its SHA-256 hash, encodes the hash
  /// using base58 encoding with a base of 36, and constructs the order hash with
  /// the prefix "OR".
  ///
  /// Parameters:
  /// - value: The value for which the order hash needs to be generated.
  ///
  /// Returns:
  /// A string representing the generated order hash.
  String getOrderHash(String value) {
    var sha256 = getSha256HashToString(value);
    sha256 = base58Encode(sha256, BigInt.from(36));
    return "OR$sha256";
  }

  /// Generates a random key pair.
  KeyPair generateKeyPair() {
    final secureRandom = FortunaRandom()
      ..seed(KeyParameter(Uint8List.fromList(
          List.generate(32, (_) => Random.secure().nextInt(256)))));

    final curve = ECCurve_secp256k1();
    final domainParams = ECKeyGeneratorParameters(curve);

    final keyGenerator = ECKeyGenerator()
      ..init(ParametersWithRandom(domainParams, secureRandom));

    final keyPair = keyGenerator.generateKeyPair();

    final privateKey = keyPair.privateKey as ECPrivateKey;
    final publicKey = keyPair.publicKey as ECPublicKey;

    final privateKeyBytes =
        privateKey.d!.toRadixString(16).toUpperCase().padLeft(64, '0');
    final publicKeyBytes = publicKey.Q!.getEncoded(false);

    return KeyPair(
        privateKey: base64.encode(hex.decode(privateKeyBytes)),
        publicKey: base64.encode(publicKeyBytes));
  }

  /// Derives an address from a public key using multiple hashing algorithms.
  String getAddressFromPublicKey(String publicKey) {
    final pubSHAHashed = getSha256HashToString(publicKey);
    final hash1 = _getMd160HashToString(pubSHAHashed);
    final hash1Encoded = base58Encode(hash1, BigInt.from(58));
    final sum = base58Checksum(hash1Encoded);
    final key = base58DecimalTo58(sum.toString());
    final hash2 = hash1Encoded + key;
    return NosoConst.coinChar + hash2;
  }

  /// Base58 encodes a hexadecimal number using the specified alphabet.
  String base58Encode(String hexNumber, BigInt alphabetNumber) {
    BigInt decimalValue = _hexToDecimal(hexNumber);
    String result = '';
    String alphabetUsed;

    if (alphabetNumber == BigInt.from(36)) {
      alphabetUsed = NosoConst.b36Alphabet;
    } else {
      alphabetUsed = NosoConst.b58Alphabet;
    }

    while (decimalValue.bitLength >= 2) {
      _DivResult divResult = _divideBigInt(decimalValue, alphabetNumber);
      decimalValue = divResult.coefficient;
      int remainder = divResult.remainder.toInt();
      result = alphabetUsed[remainder] + result;
    }

    if (decimalValue >= alphabetNumber) {
      _DivResult divResult = _divideBigInt(decimalValue, alphabetNumber);
      decimalValue = divResult.coefficient;
      int remainder = divResult.remainder.toInt();
      result = alphabetUsed[remainder] + result;
    }

    if (decimalValue > BigInt.zero) {
      int value = decimalValue.toInt();
      result = alphabetUsed[value] + result;
    }

    return result;
  }

  /// Computes the checksum of a Base58-encoded string.
  int base58Checksum(String input) {
    int total = 0;
    for (var i = 0; i < input.length; i++) {
      var currentChar = input[i];
      var foundIndex = NosoConst.b58Alphabet.indexOf(currentChar);
      if (foundIndex != -1) {
        total += foundIndex;
      }
    }
    return total;
  }

  /// Converts a decimal number to Base58 using the specified alphabet.
  String base58DecimalTo58(String number) {
    var decimalValue = BigInt.parse(number);
    _DivResult resultDiv;
    String remainder;
    String result = '';

    while (decimalValue.bitLength >= 2) {
      resultDiv = _divideBigInt(decimalValue, BigInt.from(58));
      decimalValue = resultDiv.coefficient;
      remainder = resultDiv.remainder.toInt().toString();
      result = NosoConst.b58Alphabet[int.parse(remainder)] + result;
    }

    if (decimalValue >= BigInt.from(58)) {
      resultDiv = _divideBigInt(decimalValue, BigInt.from(58));
      decimalValue = resultDiv.coefficient;
      remainder = resultDiv.remainder.toInt().toString();
      result = NosoConst.b58Alphabet[int.parse(remainder)] + result;
    }

    if (decimalValue > BigInt.zero) {
      result = NosoConst.b58Alphabet[decimalValue.toInt()] + result;
    }

    return result;
  }

  /// Calculates the SHA-256 hash of a given public key.
  String getSha256HashToString(String publicKey) {
    final sha256 = SHA256Digest();
    final bytes = utf8.encode(publicKey);
    final digest = sha256.process(Uint8List.fromList(bytes));
    final result = hex.encode(digest);
    return result.replaceAll('-', '').toUpperCase();
  }

  /// Calculates the RIPEMD-160 hash of a given SHA-256 hash.
  String _getMd160HashToString(String hash256) {
    final hash = RIPEMD160Digest();
    final bytes = Uint8List.fromList(hash256.codeUnits);
    final hashResult = hash.process(bytes);
    final hashHex = hex.encode(hashResult);
    return hashHex.toUpperCase();
  }

  /// Converts a hexadecimal number to a BigInt.
  BigInt _hexToDecimal(String hexNumber) {
    final bytes = <int>[];
    for (var i = 0; i < hexNumber.length; i += 2) {
      final byteString = hexNumber.substring(i, i + 2);
      final byte = int.parse(byteString, radix: 16);
      bytes.add(byte);
    }
    final hexString =
        bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
    return BigInt.parse(hexString, radix: 16);
  }

  /// Divides a BigInt by another BigInt and returns the quotient and remainder.
  _DivResult _divideBigInt(BigInt numerator, BigInt denominator) {
    _DivResult result = _DivResult();
    result.coefficient = numerator ~/ denominator;
    result.remainder = numerator % denominator;
    return result;
  }
}
