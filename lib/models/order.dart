class NewOrder {
  String headRequest;
  String? orderID;
  int? orderLines;
  String? orderType;
  String? timeStamp;
  String? message;
  int? trxLine;
  String? sender;
  String? address;
  String? receiver;
  int? amountFee;
  int? amountTrf;
  String? signature;
  String trfrID;

  NewOrder({
    this.headRequest = "",
    this.orderID,
    this.orderLines,
    this.orderType,
    this.timeStamp,
    this.message = "null",
    this.trxLine,
    this.sender,
    this.address,
    this.receiver,
    this.amountFee,
    this.amountTrf,
    this.signature,
    this.trfrID = "",
  });

  /// Returns the model data as a prepared string
  String _getAllString() {
    return "$headRequest$orderType $orderID ${orderLines.toString()} $orderType ${timeStamp.toString()} $message ${trxLine.toString()} $sender $address $receiver ${amountFee.toString()} ${amountTrf.toString()} $signature $trfrID \$";
  }

  String getRequest() {
    var confirmRequest =
        _getAllString().substring(0, _getAllString().length - 2);
    return "${confirmRequest}\n";
  }
}
