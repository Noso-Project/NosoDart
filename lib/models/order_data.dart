import 'package:noso_dart/models/noso/address_object.dart';

import 'app_info.dart';

/// Represents data related to an order, including information about the current
/// address, receiver, current block, message, amount, and additional app-specific
/// details.
class OrderData {
  final AddressObject currentAddress; // The current address associated with the order.
  final String receiver; // The recipient of the order.
  final String currentBlock; // The current block relevant to the order.
  final String message; // A message associated with the order (default is "null").
  final int amount; // The amount related to the order.
  final AppInfo appInfo; // Additional information specific to the application.

  OrderData({
    required this.currentAddress,
    required this.receiver,
    required this.currentBlock,
    this.message = "null",
    required this.amount,
    required this.appInfo,
  });


  OrderData copyWith({
    AddressObject? currentAddress,
    String? receiver,
    String? currentBlock,
    String? message,
    int? amount,
    AppInfo? appInfo,
  }) {
    return OrderData(
      currentAddress: currentAddress ?? this.currentAddress,
      receiver: receiver ?? this.receiver,
      currentBlock: currentBlock ?? this.currentBlock,
      message: message ?? this.message,
      amount: amount ?? this.amount,
      appInfo: appInfo ?? this.appInfo,
    );
  }
}

