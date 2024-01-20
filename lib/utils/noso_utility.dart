import 'dart:typed_data';

class NosoUtility {
  // Static method that returns the count of Monet required to run a node.
  // In this example, the count is hardcoded to 10500.
  static int getCountMonetToRunNode() {
    return 10500;
  }

  // Static method that checks if a given hash is a valid Noso hash.
  // The hash is considered valid if its length is between 3 and 32 characters (inclusive).
  static bool isValidHashNoso(String hash) {
    if (hash.length < 3 || hash.length > 32) {
      return false;
    }
    return true;
  }

  // Static method that removes the ZIP header from a Uint8List of bytes.
  // It searches for the ZIP header signature (0x50 0x4b 0x03 0x04) and returns the index
  // where the header ends. If the signature is not found, it returns 0.
  static int removeZipHeaderPsk(Uint8List bytes) {
    int breakpoint = 0;

    // Iterate through the bytes looking for the ZIP header signature.
    for (var index = 0; index < bytes.length - 4; index++) {
      if (bytes[index] == 0x50 &&
          bytes[index + 1] == 0x4b &&
          bytes[index + 2] == 0x03 &&
          bytes[index + 3] == 0x04) {
        // If the signature is found, set the breakpoint to the current index and exit the loop.
        breakpoint = index;
        break;
      }
    }

    // Return the index where the ZIP header ends (or 0 if the signature is not found).
    return breakpoint;
  }
}
