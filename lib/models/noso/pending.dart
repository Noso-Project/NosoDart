class Pending {
  String orderId;
  String orderType;
  String sender;
  String receiver;
  double amountTransfer;
  double amountFee;

  Pending({
    this.orderId = "",
    this.orderType = "",
    this.sender = "",
    this.receiver = "",
    this.amountTransfer = 0,
    this.amountFee = 0,
  });

  Pending copyWith({
    String? orderId,
    String? orderType,
    String? address,
    String? sender,
    String? receiver,
    double? amountTransfer,
    double? amountFee,
    int? timeStamp,
  }) {
    return Pending(
      orderId: orderId ?? this.orderId,
      orderType: orderType ?? this.orderType,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      amountTransfer: amountTransfer ?? this.amountTransfer,
      amountFee: amountFee ?? this.amountFee,
    );
  }
}
