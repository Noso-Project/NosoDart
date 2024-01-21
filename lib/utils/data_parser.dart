import 'dart:typed_data';

import 'package:noso_dart/models/keys_pair.dart';

import '../crypto/noso_signer.dart';
import '../models/noso/address_object.dart';
import '../models/noso/node.dart';
import '../models/noso/pending.dart';
import '../models/noso/seed.dart';
import '../models/noso/summary.dart';
import 'noso_math.dart';

class DataParser {
  /// Extracts SummaryData from a Uint8List of bytes.
  /// Each set of summary data is expected to be 106 bytes.
  /// The method reads the bytes sequentially and creates a list of SummaryData objects.
  /// If the bytes are empty, an empty list is returned.
  /// If any error occurs during the process, an error message is printed to the console.
  ///
  /// Parameters:
  /// - [bytesSummaryPsk]  A Uint8List containing binary data representing summary information.
  ///
  /// Returns:
  /// A List<SummaryData> containing the extracted summary data.
  static List<SummaryData> parseSummaryData(Uint8List bytesSummaryPsk) {
    if (bytesSummaryPsk.isEmpty) {
      return [];
    }
    final List<SummaryData> addressSummary = [];
    int index = 0;
    try {
      while (index + 106 <= bytesSummaryPsk.length) {
        final sumData = SummaryData();

        sumData.hash = String.fromCharCodes(bytesSummaryPsk.sublist(
            index + 1, index + bytesSummaryPsk[index] + 1));

        sumData.custom = String.fromCharCodes(bytesSummaryPsk.sublist(
            index + 42, index + 42 + bytesSummaryPsk[index + 41]));
        sumData.balance = NosoMath().bigIntToDouble(
            fromPsk: bytesSummaryPsk.sublist(index + 82, index + 90));
        final scoreArray = bytesSummaryPsk.sublist(index + 91, index + 98);
        if (!scoreArray.every((element) => element == 0)) {
          sumData.score = NosoMath().bigIntToInt(fromPsk: scoreArray);
        }

        final lastOpArray = bytesSummaryPsk.sublist(index + 99, index + 106);
        if (!lastOpArray.every((element) => element == 0)) {
          //  sumData.lastOP = lastOpArray;
        }

        addressSummary.add(sumData);
        index += 106;
      }
    } catch (e) {
      print('Error reading Summary: $e');
    }
    return addressSummary;
  }

  /// Parses the network response to extract Node information based on the provided active seed.
  ///
  /// This method takes a [response], which is a list of integers representing the raw data received from the network,
  /// and a [seedActive], which is the active seed associated with the Node. It returns a [Node] object if the parsing
  /// is successful, otherwise returns null.
  ///
  /// The [response] is expected to contain space-separated values, and the method attempts to extract relevant information
  /// to construct a [Node] object. If the response is null or does not contain enough values, the method returns null.
  ///
  /// Input:
  ///   - response: List of integers representing the raw data received from the network.
  ///   - seedActive: The active seed associated with the Node.
  ///
  /// Output:
  ///   - [Node] A constructed Node object if parsing is successful, otherwise null.
  ///
  /// Example Usage:
  /// ```dart
  /// List<int> response = ... // Raw network response as a list of integers.
  /// Seed activeSeed = ...    // Active seed associated with the Node.
  /// Node? parsedNode = NodeParser.parseResponseNode(response, activeSeed);
  /// ```
  ///
  /// Note: The method uses try-catch to handle potential exceptions during parsing, returning null in case of an error.

  static Node? parseDataNode(List<int>? response, Seed seedActive) {
    if (response == null) {
      return null;
    }
    try {
      List<String> values = String.fromCharCodes(response).split(" ");

      if (values.length <= 2) {
        return null;
      }

      return Node(
        seed: seedActive,
        connections: int.tryParse(values[1]) ?? 0,
        lastblock: int.tryParse(values[2]) ?? 0,
        pendings: int.tryParse(values[3]) ?? 0,
        delta: int.tryParse(values[4]) ?? 0,
        branch: values[5],
        version: values[6],
        utcTime: int.tryParse(values[7]) ?? 0,
      );
    } catch (e) {
      return null;
    }
  }

  /// Parses Seeds from the response string obtained from the [NodeRequest.getNodeList].
  ///
  /// This method takes a [response], represented as a list of integers, and parses
  /// it into a list of Seeds. The response string is expected to contain seed
  /// information separated by spaces. Each seed is assumed to be in the format
  /// "ip;port:address". The method handles errors gracefully and returns an
  /// empty list if the response is null or empty, or if parsing encounters any issues.
  ///
  /// Example:
  /// ```dart
  /// List<int> response = [105, 112, 49, 50, 55, 46, 48, 46, 48, 46, 49, 58, 56, 48, 56, 48, 32, ...];
  /// List<Seed> parsedSeeds = parseSeeds(response);
  /// print(parsedSeeds.length);  // Output: Number of parsed seeds
  /// ```
  ///
  /// Parameters:
  /// - [response] A list of integers representing the response string.
  ///
  /// Returns:
  /// A list of Seed instances parsed from the response string.
  List<Seed> parseDataSeeds(List<int>? response) {
    if (response == null || response.isEmpty) {
      return [];
    }
    List<String> seeds = String.fromCharCodes(response).split(" ");
    List<Seed> seedsList = [];

    try {
      for (String value in seeds) {
        if (value != seeds[0]) {
          var seed = value.split(":");
          var ipAndPort = seed[0].split(";");

          seedsList.add(Seed(
            ip: ipAndPort[0],
            port: int.parse(ipAndPort[1]),
            address: seed[1],
          ));
        }
      }
      return seedsList;
    } catch (e) {
      return [];
    }
  }

  /// Parses a network response containing pending transaction information into a list of Pending objects.
  ///
  /// This method takes a [response], which is a list of integers representing the raw data received from the network.
  /// It returns a list of [Pending] objects based on the parsed information. If the parsing encounters errors or the response
  /// is null or empty, an empty list is returned.
  ///
  /// Input:
  ///   - response: List of integers representing the raw data received from the network.
  ///
  /// Output:
  ///   - [List<Pending>] A list of Pending objects based on the parsed information.
  ///
  /// Example Usage:
  /// ```dart
  /// List<int> response = ... // Raw network response as a list of integers.
  /// List<Pending> parsedPendings = NodeParser.parsePendings(response);
  /// ```
  ///
  /// Note: The method uses try-catch to handle potential exceptions during parsing, returning an empty list in case of an error.
  static List<Pending> parseDataPendings(List<int>? response) {
    if (response == null || response.isEmpty) {
      return [];
    }

    // Convert the list of integers to a string and split into values.
    List<String> array = String.fromCharCodes(response).split(" ");
    List<Pending> pendingList = [];

    try {
      // Iterate through the array and split each value based on a comma (',') separator.
      for (String value in array) {
        var pending = value.split(",");

        // Construct Pending objects based on the split values, considering different cases (5 or 6 split values).
        if (pending.length == 5) {
          pendingList.add(Pending(
            orderType: pending[0],
            sender: pending[1],
            receiver: pending[2],
            amountTransfer:
                NosoMath().bigIntToDouble(valueInt: int.parse(pending[3])),
            amountFee:
                NosoMath().bigIntToDouble(valueInt: int.parse(pending[4])),
          ));
        } else if (pending.length == 6) {
          pendingList.add(Pending(
            orderId: pending[0],
            orderType: pending[1],
            sender: pending[2],
            receiver: pending[3],
            amountTransfer:
                NosoMath().bigIntToDouble(valueInt: int.parse(pending[4])),
            amountFee:
                NosoMath().bigIntToDouble(valueInt: int.parse(pending[5])),
          ));
        }
      }
      return pendingList;
    } catch (e) {
      // Return an empty list in case of an exception during parsing.
      return [];
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