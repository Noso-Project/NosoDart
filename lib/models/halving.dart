/// Represents a Halving event with associated information.
///
/// The Halving class contains properties [blocks] and [days] representing the remaining blocks until the next Halving
/// and the corresponding time remaining in days, respectively. The class provides a constructor for creating Halving
/// objects, and a `getHalvingTimer` method for calculating the time remaining until the next Halving based on the
/// provided [lastBlock].
///
/// Properties:
///   - [blocks]: The remaining blocks until the next Halving event.
///   - [days]: The remaining time in days until the next Halving event.
///
/// Constructor:
///   - Takes optional parameters [blocks] and [days], initialized to 0 by default.
///
/// Methods:
///   - [getHalvingTimer]  Calculates the remaining blocks and days until the next Halving event based on the provided
///     [lastBlock]. It considers predefined block intervals for Halving and returns a new Halving object with the
///     calculated values.

class Halving {
  int blocks = 0;
  int days = 0;

  Halving({
    this.blocks = 0,
    this.days = 0,
  });

  /// Calculates the remaining blocks and days until the next Halving event.
  ///
  /// This method takes the [lastBlock] as an argument and calculates the remaining blocks and days until the next
  /// Halving event based on predefined block intervals. It returns a new Halving object with the calculated values.
  ///
  /// Input:
  ///   - [lastBlock] The last processed block in the blockchain.
  ///
  /// Output:
  ///   - [Halving] A new Halving object with the calculated remaining blocks and days until the next Halving.
  ///

  Halving getHalvingTimer(int lastBlock) {
    int halvingTimer;
    if (lastBlock < 210000) {
      halvingTimer = 210000 - lastBlock;
    } else if (lastBlock < 420000) {
      halvingTimer = 420000 - lastBlock;
    } else if (lastBlock < 630000) {
      halvingTimer = 630000 - lastBlock;
    } else if (lastBlock < 840000) {
      halvingTimer = 840000 - lastBlock;
    } else if (lastBlock < 1050000) {
      halvingTimer = 1050000 - lastBlock;
    } else if (lastBlock < 1260000) {
      halvingTimer = 1260000 - lastBlock;
    } else if (lastBlock < 1470000) {
      halvingTimer = 1470000 - lastBlock;
    } else if (lastBlock < 1680000) {
      halvingTimer = 1680000 - lastBlock;
    } else if (lastBlock < 1890000) {
      halvingTimer = 1890000 - lastBlock;
    } else if (lastBlock < 2100000) {
      halvingTimer = 2100000 - lastBlock;
    } else {
      halvingTimer = 0;
    }

    int timeRemaining = halvingTimer * 600;
    int timeRemainingDays = ((timeRemaining / (60 * 60 * 24))).ceil();

    return Halving(blocks: halvingTimer, days: timeRemainingDays);
  }
}
