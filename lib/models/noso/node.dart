import 'package:noso_dart/models/noso/seed.dart';

/// Represents a Node in the network with associated information.
///
/// A Node object encapsulates details about a node in the network, including its [seed], [connections], [lastblock],
/// [pendings], [delta], [branch], [version], and [utcTime]. The class provides a constructor for creating Node objects,
/// and a `copyWith` method for creating a copy of the Node with specific properties modified.
///
/// Properties:
///   - [seed]: The seed associated with the Node.
///   - [connections]: The number of connections the Node has in the network.
///   - [lastblock]: The last block processed by the Node.
///   - [pendings]: The number of pending transactions in the Node.
///   - [branch]: The branch information associated with the Node.
///   - [version]: The version of the Node software.
///   - [utcTime]: The UTC time associated with the Node.
///
/// Constructor:
///   - Takes the [seed] parameter as a required argument and initializes other properties with default values.
///
class Node {
  Seed seed;
  int connections;
  int lastblock;
  int pendings;
  int delta;
  String branch;
  String version;
  String lastblockhash;
  String headershash;
  String sumaryhash;
  int utcTime;

  Node({
    required this.seed,
    this.connections = 0,
    this.lastblock = 0,
    this.pendings = 0,
    this.delta = 0,
    this.branch = "",
    this.version = "",
    this.lastblockhash = "",
    this.headershash = "",
    this.sumaryhash = "",
    this.utcTime = 0,
  });

  Node copyWith({
    Seed? seed,
    int? connections,
    int? lastblock,
    int? pendings,
    int? delta,
    String? branch,
    String? version,
    String? lastblockhash,
    String? headershash,
    String? sumaryhash,
    int? utcTime,
  }) {
    return Node(
      seed: seed ?? this.seed,
      connections: connections ?? this.connections,
      lastblock: lastblock ?? this.lastblock,
      pendings: pendings ?? this.pendings,
      delta: delta ?? this.delta,
      branch: branch ?? this.branch,
      version: version ?? this.version,
      lastblockhash: lastblockhash ?? this.lastblockhash,
      headershash: headershash ?? this.headershash,
      sumaryhash: sumaryhash ?? this.sumaryhash,
      utcTime: utcTime ?? this.utcTime,
    );
  }
}
