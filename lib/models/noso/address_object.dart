/// Represents an address object in the wallet system.
class AddressObject {
  String hash; // Unique identifier for the address
  String? custom; // Custom alias for the address (optional)
  String publicKey; // Public key associated with the address
  String privateKey; // Private key associated with the address
  double balance; // Current balance of the address
  int score; // Token balance
  int lastOP; // Last operation block
  bool isLocked; // Indicates whether the address is locked
  double incoming; // Total incoming transactions
  double outgoing; // Total outgoing transactions

  /// Returns the hash or alias of the address.
  get nameAddressFull => custom ?? hash;

  /// Available balance to perform paid transactions.
  get availableBalance => outgoing > balance ? 0 : balance - outgoing;

  /// Constructor for creating an AddressObject.
  AddressObject({
    required this.hash,
    this.custom,
    required this.publicKey,
    required this.privateKey,
    this.balance = 0,
    this.score = 0,
    this.lastOP = 0,
    this.isLocked = false,
    this.incoming = 0,
    this.outgoing = 0,
  });

  /// Creates a new instance of AddressObject with optional modifications.
  AddressObject copyWith({
    String? hash,
    String? custom,
    double? balance,
    int? score,
    int? lastOP,
    bool? isLocked,
    double? incoming,
    double? outgoing,
  }) {
    return AddressObject(
      hash: hash ?? this.hash,
      publicKey: this.publicKey,
      privateKey: this.privateKey,
      custom: custom ?? this.custom,
      balance: balance ?? this.balance,
      score: score ?? this.score,
      lastOP: lastOP ?? this.lastOP,
      isLocked: isLocked ?? this.isLocked,
      incoming: incoming ?? this.incoming,
      outgoing: outgoing ?? this.outgoing,
    );
  }

  Map<String, dynamic> toJsonExport() {
    return {
      'publicKey': publicKey,
      'privateKey': privateKey,
    };
  }
}
