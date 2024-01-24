class NodeRequest {
  /// Returns information about the node according to node.dart
  static const String getNodeStatus = "NODESTATUS\n";

  /// Method that returns a list of working nodes in the current block
  static const String getNodeList = "NSLMNS\n";

  /// Returns the list of pendings in the network, if there are none, returns an empty string. According to the pending.dart model
  static const String getPendingsList = "NSLPENDFULL\n";

  /// Returns a summary.zip in bytes to be unpacked and written according to the summary.dart model
  static const String getSummaryZip = "GETZIPSUMARY\n";

  /// Returns the actual balance of the address
  static String getAddressBalance(String hash) {
    return "NSLBALANCE $hash\n";
  }
}
