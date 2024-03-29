import 'dart:typed_data';

import 'package:noso_dart/models/noso/gvt.dart';

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
  static List<Seed> parseDataSeeds(List<int>? response) {
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
  static List<Pending>? parseDataPendings(List<int>? response) {
    if (response == null || response.isEmpty) {
      return null;
    }

    List<String> array = String.fromCharCodes(response).split(" ");
    List<Pending> pendingList = [];

    try {
      for (String value in array) {
        var pending = value.split(",");

        if (pending.length >= 8) {
          pendingList.add(Pending(
            orderId: pending[0],
            orderType: pending[2],
            sender: pending[3],
            receiver: pending[4],
            amountTransfer:
                NosoMath().bigIntToDouble(valueInt: int.parse(pending[5])),
            amountFee:
                NosoMath().bigIntToDouble(valueInt: int.parse(pending[6])),
          ));
        }
      }

      return pendingList;
    } catch (e) {
      return null;
    }
  }

  /// Get a list of seeds from a configuration string.
  ///
  /// The method is designed to process a configuration string and extract
  /// information about seeds. The configuration string should be in a format
  /// where seeds are separated by spaces, represented by the [input] value.
  ///
  /// If [input] is an empty string, the method returns an empty list.
  ///
  /// It is assumed that the configuration string has at least 5 values; otherwise,
  /// the method may return an empty list.
  ///
  /// Each seed is defined by a string in the format "ip;port", where:
  /// - "ip" is the IP address of the seed,
  /// - "port" is the port of the seed (parsed as an integer).
  ///
  /// Objects of the [Seed] class are created and added to the [seedList].
  ///
  /// Returns the [seedList] containing [Seed] objects with information
  /// about seeds from the configuration string.
  static List<Seed> getSeedListFromCFG(String input) {
    if (input.isEmpty) return [];

    List<Seed> seedList = [];
    try {
      List<String> values = input.split(' ');

      if (values.length >= 5) {
        List<String> poolData = values[1].split(':');
        for (String data in poolData) {
          List<String> seed = data.split(';');
          if (seed.length >= 2) {
            seedList.add(Seed(ip: seed[0], port: int.parse(seed[1])));
          }
        }
      }

      return seedList;
    } catch (e) {
      return seedList;
    }
  }

  /// Converts a list of integers representing GVT data into a list of Gvt objects.
  ///
  /// The [gvtFile] parameter is a list of integers representing binary GVT data.
  /// The binary data is parsed in chunks of 105 bytes to extract information about each Gvt.
  /// Each Gvt object consists of three components: 'numer', 'addressHash', and 'hashGvt'.
  ///
  /// The [gvtFile] is expected to have a specific structure where each Gvt entry
  /// occupies 105 bytes with specific offsets for 'numer', 'addressHash', and 'hashGvt'.
  ///
  /// If [gvtFile] is null or empty, an empty list is returned.
  /// If there's an error during parsing, the method returns the parsed Gvt list up to that point.
  ///
  static List<Gvt> getGvtList(List<int>? gvtFile) {
    if (gvtFile == null || gvtFile.isEmpty) {
      return [];
    }
    int index = 20;
    List<Gvt> gvtList = [];
    try {
      var fileBytes = Uint8List.fromList(gvtFile);
      while (index + 105 <= fileBytes.length) {
        String numer =
            String.fromCharCodes(fileBytes.sublist(index + 0, index + 2));
        String hash =
            String.fromCharCodes(fileBytes.sublist(index + 3, index + 33));
        String hashToken =
            String.fromCharCodes(fileBytes.sublist(index + 34, index + 100));
        gvtList.add(Gvt(
            numer: int.parse(numer), addressHash: hash, hashGvt: hashToken));
        index += 105;
      }
      return gvtList;
    } catch (e) {
      return gvtList;
    }
  }
}
