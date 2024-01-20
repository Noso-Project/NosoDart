import 'package:noso_dart/models/order_data.dart';
import 'package:noso_dart/noso_enum.dart';
import 'package:pointycastle/ecc/api.dart';

import '../const.dart';
import '../crypto/noso_core.dart';
import '../crypto/noso_signer.dart';
import '../models/order.dart';
import '../utils/noso_math.dart';

class OrderHandler {
  /// Sending a string to change the alias address. Format NSLCUSTOM String
  final String _sendAliasOrder = "NSLCUSTOM";

  /// Sending a line to create a payment order. Format NSLORDER String
  final String _sendPaymentOrder = "NSLORDER";

  final Map<OrderType, String> _orderTypes = {
    OrderType.TRFR: "TRFR",
    OrderType.CUSTOM: "CUSTOM",
    // OrderType.SNDGVT: "SNDGVT",
  };

  /// Generates a new order based on the provided [orderData] and [orderType].
  ///
  /// The method calculates necessary parameters, such as current time, commission,
  /// and signatures, and then constructs a [NewOrder] object representing the order.
  ///
  /// Parameters:
  /// - [orderData]: Information related to the order, including addresses, amounts,
  ///   and application details.
  /// - [orderType]: The type of the order, such as CUSTOM or TRFR.
  ///
  /// Returns:
  /// - A [NewOrder] object if the generation is successful; otherwise, returns null.
  ///
  /// Throws:
  /// - An exception if an error occurs during the order generation process.

  NewOrder? generateNewOrder(OrderData orderData, OrderType orderType) {
    final String currentTime = _getCurrentTimeUser();
    final int trxLine = 1;
    final String orderTypeString = _getOrderTypeString(orderType);
    var signature = ECSignature(
      BigInt.zero,
      BigInt.zero,
    );
    String trfrID = "";
    String nodeRequest;
    int commission;

    try {
      // Switch statement to handle different order types.
      switch (orderType) {
        case OrderType.CUSTOM:
          // Custom order-specific configurations.
          nodeRequest = _sendAliasOrder;
          commission = NosoConst.customizationFee;
          var nSignature = NosoSigner().signMessage(
              'Customize this ${orderData.currentAddress.hash} ${orderData.receiver}',
              orderData.currentAddress.privateKey);
          if (nSignature == null) {
            return null;
          }
          signature = nSignature;
          trfrID = NosoCore().getTransferHash(
              currentTime + orderData.currentAddress.hash + orderData.receiver);

          break;

        case OrderType.TRFR:
          // Transfer order-specific configurations.
          nodeRequest = _sendPaymentOrder;
          commission = NosoMath().getFee(orderData.amount);
          var messageSignature = (currentTime +
              orderData.currentAddress.hash +
              orderData.receiver +
              orderData.amount.toString() +
              commission.toString() +
              trxLine.toString());
          var nSignature = NosoSigner().signMessage(
              messageSignature, orderData.currentAddress.privateKey);
          if (nSignature == null) {
            return null;
          }
          signature = nSignature;
          trfrID = NosoCore().getTransferHash(currentTime +
              orderData.currentAddress.hash +
              orderData.receiver +
              orderData.amount.toString() +
              orderData.currentBlock);
          break;

        default:
          return null;
      }

      // Construct and return a new order object using the calculated parameters.
      NewOrder newOrder = NewOrder(
          headRequest:
              "$nodeRequest ${orderData.appInfo.protocol} ${orderData.appInfo.appVersion} ${_getCurrentTimeUser()} ORDER $trxLine \$",
          orderID: NosoCore().getOrderHash("$trxLine${currentTime + trfrID}"),
          orderLines: trxLine,
          orderType: orderTypeString,
          timeStamp: currentTime,
          message: orderData.message,
          trxLine: trxLine,
          sender: orderData.currentAddress.publicKey,
          address: orderData.currentAddress.hash,
          receiver: orderData.receiver,
          amountFee: commission,
          amountTrf: orderData.amount,
          signature: NosoSigner().encodeSignatureToBase64(signature),
          trfrID: trfrID);

      return newOrder;
    } catch (e) {
      print("Generate string Order error ${e}");
      return null;
    }
  }

  String _getOrderTypeString(OrderType value) {
    return _orderTypes[value] ?? "";
  }

  _getCurrentTimeUser() {
    return (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
  }
}
